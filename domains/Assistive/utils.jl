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
    x = state[Compound(:xloc, Term[obj])]::Int
    y = state[Compound(:yloc, Term[obj])]::Int
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
