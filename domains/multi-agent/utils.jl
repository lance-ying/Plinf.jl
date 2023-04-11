using DataStructures: OrderedDict

pos_to_terms(pos) = @julog([xpos == $(pos[1]), ypos == $(pos[2])])

function get_agent_pos(state::State; flip_y::Bool=false)
    x_human, y_human = state[pddl"(xloc human)"], state[pddl"(yloc human)"]
    x_robot, y_robot = state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]
    if !flip_y
        return Dict("human"=>(x_human, y_human), "robot"=>(x_robot, y_robot))
    else
        height = size(state[pddl"(walls)"])[1]
        return Dict("human"=>(x_human, height-y_human+1), "robot"=>(x_robot, height-y_robot+1))
    end
end

function get_color(state::State, obj::Const)
    color_vec=PDDL.get_objects(state, :color)
    for c in color_vec
        if state[Compound(:iscolor, Term[obj,c])]
            return c
        end
    end
end

function generate_gems(num_gems:: Integer)
    if num_gems == 3
        goal_colors = [colorant"#D41159", colorant"#FFC20A", colorant"#1A85FF"]
        gem_terms = @pddl("gem1", "gem2", "gem3")
        return goal_colors, gem_terms, Dict(zip(gem_terms, goal_colors))
    elseif num_gems == 4
        goal_colors = [colorant"#D41159", colorant"#FFC20A", colorant"#1A85FF",colorant"#24D60C"]
        gem_terms = @pddl("gem1", "gem2", "gem3", "gem4")
        return goal_colors, gem_terms, Dict(zip(gem_terms, goal_colors))
    else
        goal_colors = [colorant"#D41159", colorant"#FFC20A", colorant"#1A85FF",colorant"#24D60C",colorant"#A56AA0"]
        gem_terms = @pddl("gem1", "gem2", "gem3", "gem4", "gem5")
        return goal_colors, gem_terms, Dict(zip(gem_terms, goal_colors))
    end

end

function return_goals(num_gems:: Integer)
    if num_gems == 3
        return @pddl("(has human gem1)", "(has human gem2)", "(has human gem3)")
    elseif num_gems == 4
        return @pddl("(has human gem1)", "(has human gem2)", "(has human gem3)","(has human gem4)")
    else 
        return @pddl("(has human gem1)", "(has human gem2)", "(has human gem3)","(has human gem4)","(has human gem5)")
    end
end

function get_obj_loc(state::State, obj::Const;
    check_has::Bool=false, flip_y::Bool=false)

    x, y = state[Compound(:xloc, Term[obj])], state[Compound(:yloc, Term[obj])]
    if check_has && PDDL.get_objtype(state, obj) in [:gem, :key]
        for agent in PDDL.get_objects(state, :agent)
            if state[Compound(:has, Term[agent, obj])]
                x, y = get_obj_loc(state, agent; flip_y=flip_y)
                break
            end
        end
    end
    if !flip_y
        return (x, y)
    else
        height = size(state[pddl"(walls)"])[1]
        return (x, height-y+1)
    end
end

"Custom relaxed distance heuristic to goal objects."
struct GemHeuristic <: Heuristic end

function Plinf.compute(heuristic::GemHeuristic,
      domain::Domain, state::State, spec::Specification)
    goals = Plinf.get_goal_terms(spec)
    has_goals = [g for g in goals if g.name == :has]
    n_agents = length(PDDL.get_objects(state, :agent))
    noop_cost = spec isa MinActionCosts ? spec.costs[:noop] : 1
    dists = map(has_goals) do goal
        if state[goal] return 0 end
        # print(goal)
        agent, item = goal.args
        item_loc = get_obj_loc(state, item; check_has=true)
        agent_loc = get_obj_loc(state, agent)
        agent_item_dist = sum(abs.(agent_loc .- item_loc))
        min_other_dist = Inf
        for other in PDDL.get_objects(state, :agent)
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


# function get_obj_loc(state::State, obj::Const; flip_y::Bool=false)
#     x, y = state[Compound(:xloc, Term[obj])], state[Compound(:yloc, Term[obj])]
#     if !flip_y
#         return (x, y)
#     else
#         height = size(state[pddl"(walls)"])[1]
#         return (x, height-y+1)
#     end
# end

# "Custom relaxed distance heuristic to goal objects."
# struct GemHeuristic <: Heuristic end

# function Plinf.compute(heuristic::GemHeuristic,
#                        domain::Domain, state::State, spec::Specification)
#     goals = Plinf.get_goal_terms(spec)
#     goal_objs = [g.args[1] for g in goals if g.name == :has]
#     locs = [(state[Compound(:xloc, Term[o])], state[Compound(:yloc, Term[o])])
#             for o in goal_objs]
#     pos = (state[pddl"xpos"], state[pddl"ypos"])
#     dists = [sum(abs.(pos .- l)) for l in locs]
#     min_dist = length(dists) > 0 ? minimum(dists) : 0
#     return min_dist + GoalCountHeuristic()(domain, state, spec)
# end


"Maze distance heuristic to location of goal gem."
struct GemMazeDist <: Heuristic
    planner::Planner
end

GemMazeDist() = GemMazeDist(AStarPlanner(heuristic=GemHeuristic()))

function Plinf.compute(heuristic::GemMazeDist,
                       domain::Domain, state::State, spec::Specification)
    relaxed_state = copy(state)
    for d in PDDL.get_objects(domain, state, :door)
        relaxed_state[Compound(:locked, Term[d])] = false
    end
    relaxed_plan = heuristic.planner(domain, relaxed_state, spec)[1]
    return length(relaxed_plan)
end

function get_goal_probs(traces, weights, goal_idxs=[])
    goal_probs = OrderedDict{Any,Float64}(g => 0.0 for g in goal_idxs)
    for (tr, w) in zip(traces, weights)
        goal_idx = tr[:init => :agent => :goal => :goal]
        prob = get(goal_probs, goal_idx, 0.0)
        goal_probs[goal_idx] = prob + exp(w)
    end
    return goal_probs
end

function print_goal_probs(goal_probs)
    for (goal, prob) in sort(goal_probs)
        @printf("%.3f\t", prob)
    end
    print("\n")
end
