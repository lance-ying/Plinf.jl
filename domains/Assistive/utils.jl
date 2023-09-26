using DataStructures: OrderedDict
using Base: @kwdef

import SymbolicPlanners: compute, get_goal_terms

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
    goals = get_goal_terms(spec)
    has_goals = [g for g in goals if g.name == :has]
    n_agents = length(heuristic.agents)
    if spec isa MinActionCosts
        noop_cost = spec.costs[:noop]
    elseif spec isa MinPerAgentActionCosts
        noop_cost = spec.costs[heuristic.agents[2].name][:noop]
    else
        noop_cost = 1
    end
    dists = map(has_goals) do goal
        if state[goal] return 0 end
        agent, item = goal.args
        item_loc = get_obj_loc(state, item; check_has=true)
        agent_loc = get_obj_loc(state, agent)
        agent_item_dist = sum(abs.(agent_loc .- item_loc))
        min_other_dist = Inf
        for other in heuristic.agents
            other == agent && continue
            other_loc = get_obj_loc(state, other)
            other_dist = agent_item_dist
            if !state[Compound(:has, Term[other, item])]
                other_item_dist = sum(abs.(other_loc .- item_loc))
                other_dist += other_item_dist * (n_agents - 1) + 1
            end
            min_other_dist = min(min_other_dist, other_dist)
        end
        agent_dist = agent_item_dist * (1 + noop_cost * (n_agents - 1))
        return min(agent_dist, min_other_dist)
    end
    min_dist = length(dists) > 0 ? minimum(dists) : 0
    return min_dist
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

