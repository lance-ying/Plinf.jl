using DataStructures: OrderedDict
using Base: @kwdef

import SymbolicPlanners: compute, get_goal_terms

"""
    sys_sample_map!(f, items, probs, n_samples)

Applies `f` via systematic sampling of `items` with probabilities `probs`. For
each item, calls `f(item, frac)` where `frac` is the fraction of samples that
item should be included in. 
"""
function sys_sample_map!(f, items, probs, n_samples::Int)
    @assert length(items) == length(probs)
    @assert n_samples > 0
    count = 0
    total_prob = 0.0
    u = rand() / n_samples
    for (item, prob) in zip(items, probs)
        count == n_samples && break
        n_copies = 0
        total_prob += prob
        while u < total_prob
            n_copies += 1
            count += 1
            u += 1 / n_samples
        end
        n_copies == 0 && continue
        frac = n_copies / n_samples
        f(item, frac)
    end
    return nothing
end

"Returns the color of an object."
function get_obj_color(state::State, obj::Const)
    for color in PDDL.get_objects(state, :color)
        if state[Compound(:iscolor, Term[obj, color])]
            return color
        end
    end
    return Const(:none)
end

"Returns the location of an object."
function get_obj_loc(state::State, obj::Const; check_has::Bool=false)
    x = state[Compound(:xloc, Term[obj])]
    y = state[Compound(:yloc, Term[obj])]
    # Check if object is held by an agent, and return agent's location if so
    if check_has && PDDL.get_objtype(state, obj) in (:gem, :key)
        agents = (PDDL.get_objects(state, :human)...,
                  PDDL.get_objects(state, :robot)...)
        for agent in agents
            if state[Compound(:has, Term[agent, obj])]
                x, y = get_obj_loc(state, agent)
                break
            end
        end
    end
    return (x, y)
end

"Rollout a planning solution to get a sequence of future actions."
function rollout_sol(
    domain::Domain, planner::Planner,
    state::State, sol::Solution, spec::Specification;
    max_steps::Int = 2^10
)
    # Special case handling of RTHS policies
    if planner isa RTHS && sol isa TabularVPolicy
        heuristic = planner.heuristic
        planner.heuristic = PolicyValueHeuristic(sol)
        search_sol = planner.planner(domain, state, spec)
        planner.heuristic = heuristic
        return collect(search_sol)
    elseif sol isa NullSolution # If no solution, return empty vector
        return Vector{Compound}()
    else # Otherwise just rollout the policy greedily
        actions = Vector{Compound}()
        for _ in 1:max_steps
            act = best_action(sol, state)
            if ismissing(act) break end
            state = transition(domain, state, act)
            push!(actions, act)
            if is_goal(spec, domain, state) break end
        end
        return actions
    end
end

"""
    GoalManhattan

Custom relaxed distance heuristic to goal objects. Estimates the cost of 
collecting all goal objects by computing the distance between all goal objects
and the agent, then returning the minimum distance plus the number of remaining
goals to satisfy.
"""
struct GoalManhattan <: Heuristic
    agents::Vector{Const}
end

GoalManhattan() = GoalManhattan([pddl"(human)", pddl"(robot)"])
GoalManhattan(domain::Domain, state::State) =
    GoalManhattan(PDDL.get_objects(domain, state, :agent))

function compute(heuristic::GoalManhattan,
                 domain::Domain, state::State, spec::Specification)
    goals = _decompose_goals(domain, state, spec)
    n_agents = length(heuristic.agents)
    # Look up movement and no-op costs for each agent
    move_costs = Float64[]
    noop_costs = Float64[]
    for agent in heuristic.agents
        if has_action_cost(spec)
            move_cost = minimum((:up, :down, :left, :right)) do act
                get_action_cost(spec, Compound(act, Term[agent]))
            end
            noop_cost = get_action_cost(spec, Compound(:noop, Term[agent]))
            push!(move_costs, move_cost)
            push!(noop_costs, noop_cost)
        else
            push!(move_costs, 1.0)
            push!(noop_costs, 1.0)
        end
    end
    dists = map(goals) do goal
        if state[goal] return 0.0 end
        # Compute distance from focal agent to goal item
        agent, item = goal.args
        agent_idx = findfirst(==(agent), heuristic.agents)
        item_loc = get_obj_loc(state, item; check_has=true)
        agent_loc = get_obj_loc(state, agent)
        agent_item_dist = sum(abs.(agent_loc .- item_loc))
        # Compute minimum distance for other agents to pick up and pass item
        min_other_dist = Inf
        for (other_idx, other) in enumerate(heuristic.agents)
            # Skip if object is not an item
            PDDL.get_objtype(state, item) == :door && continue
            # Skip focal agent
            other == agent && continue 
            # Skip if other agent cannot pick up item
            state[Compound(:forbidden, Term[other, item])] && continue
            # Add distance from item to focal agent
            other_dist = agent_item_dist * minimum(move_costs)
            # Add distance from other agent to item
            if !state[Compound(:has, Term[other, item])]
                other_loc = get_obj_loc(state, other)
                other_item_dist = sum(abs.(other_loc .- item_loc))
                other_dist += other_item_dist * move_costs[other_idx]
                # Add costs of other agents' no-ops
                for idx in 1:n_agents
                    idx == other_idx && continue
                    other_dist += other_item_dist * noop_costs[idx]
                end
            end
            min_other_dist = min(min_other_dist, other_dist)
        end
        # Compute movement cost for focal agent
        agent_dist = agent_item_dist * move_costs[agent_idx]
        # Add costs of other agents' no-ops
        for other_idx in 1:n_agents
            other_idx == agent_idx && continue
            agent_dist += agent_item_dist * noop_costs[other_idx]
        end
        return min(agent_dist, min_other_dist)
    end
    # Compute minimum distance to any goal
    min_dist = length(dists) > 0 ? minimum(dists) : 0.0
    return min_dist
end

function _decompose_goals(domain::Domain, state::State, spec::Specification)
    goals = get_goal_terms(spec)
    return _decompose_goals(domain, state, goals)
end

function _decompose_goals(domain::Domain, state::State, goals::AbstractVector{<:Term})
    if goals[1].name == Symbol("do-action") # Handle action goals
        action = goals[1].args[1]
        new_goals = Term[]
        if PDDL.is_ground(action)
            ground_actions = [action]
        else
            constraints = goals[1].args[2]
            substs = satisfiers(domain, state, constraints)
            ground_actions = [PDDL.substitute(action, s) for s in substs]
        end
        for act in ground_actions
            if act.name == :pickup
                # Pickup cost is equivalent to cost of agent having the time
                agent = act.args[1]
                item = act.args[2]
                push!(new_goals, Compound(:has, Term[agent, item]))
            elseif action.name == :handover
                # Handover cost is underestimated by assuming either agent has item
                a1, a2 = act.args[1:2]
                item = act.args[3]
                push!(new_goals, Compound(:has, Term[a1, item]))
                push!(new_goals, Compound(:has, Term[a2, item]))
            elseif action.name == :unlock
                # Unlock cost is underestimated by the cost of agent having the key
                agent = act.args[1]
                key = act.args[2]
                push!(new_goals, Compound(:has, Term[agent, key]))
            end
        end
        return new_goals
    else # Handle regular goals
        new_goals = Term[]
        for goal in goals
            if goal.name in (:has, Symbol("unlocked-by"))
                push!(new_goals, goal)
            elseif goal.name in (:and, :or)
                subgoals = _decompose_goals(domain, state, goal.args)
                append!(new_goals, subgoals)
            end
        end
        return unique!(new_goals)
    end
end

"""
    RelaxedMazeDist([planner::Planner])

Custom relaxed distance heuristic. Estimates the cost of achieving the goal 
by removing all doors from the state, then computing the length of the plan 
to achieve the goal in the relaxed state.

A `planner` can specified to compute the relaxed plan. By default this is
`AStarPlanner(heuristic=GoalManhattan())`.
"""
function RelaxedMazeDist()
    planner = AStarPlanner(GoalManhattan())
    return RelaxedMazeDist(planner)
end

function RelaxedMazeDist(heuristic::Heuristic)
    planner = AStarPlanner(heuristic)
    return RelaxedMazeDist(planner)
end

function RelaxedMazeDist(planner::Planner)
    heuristic = PlannerHeuristic(planner, s_transform=unlock_doors)
    heuristic = memoized(heuristic)
    return heuristic
end

"Unlocks all doors in the state."
function unlock_doors(state::State)
    state = copy(state)
    for d in PDDL.get_objects(state, :door)
        state[Compound(:locked, Term[d])] = false
    end
    return state
end

