using Julog, PDDL, Gen, Printf
using Plinf
using GenParticleFilters
using PDDLViz, GLMakie

include("render.jl")
include("utils.jl")
# include("render.jl")
# include("utils.jl")
include("ascii.jl")

PDDL.Arrays.register!()

# Load domain and problem
#--- Initial Setup ---#
# problem 1
path = joinpath(dirname(pathof(Plinf)), "..", "domains", "Assistive")
domain = load_domain(joinpath(path, "domain.pddl"))
astar = AStarPlanner(GoalManhattan(), save_search=true)
# costs = (
#     pickuph=10.0,pickup=1.0, pickupr=1.0, handover=1.0, unlockh=1.0,unlockr=10.0, 
#     up=1.0, down=1.0, left=1.0, right=1.0, noop=0.2
# )

costs = (
    pickuph=2.0, pickupr=1.0, handover=1.0, unlockh=1.0, unlockr=2.0, 
    up=1.0, down=1.0, left=1.0, right=1.0, noop=0.1
)

costs_d = (
    pickuph=1.0,pickup=1.0, pickupr=1.0, handover=1.0, unlockh=10.0,unlockr=1.0, 
    up=1.0, down=1.0, left=1.0, right=1.0, noop=0
)

path_dict = Dict()


function run_problem_1(option::Integer; complete=false)


    problem = load_problem(joinpath(path, "1.pddl"))

    state = initstate(domain, problem)
    plan = @pddl("(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)", "(noop robot)","(left human)")
    traj = PDDL.simulate(domain, state, plan)

    sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem2)", costs))

    path_dict["1.1"] = sol

end


# problem 2
function run_problem_2(option::Integer; complete = false)
    

    problem = load_problem(joinpath(path, "2.pddl"))

    state = initstate(domain, problem)

    costs = (
    pickuph=5.0, pickupr=1.0, handover=1.0, unlockh=1.0, unlockr=2.0, 
    up=1.0, down=1.0, left=1.0, right=1.0, noop=0.1)

    if option == 1

        plan = @pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)

        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem2)", costs))
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p2_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                10 => "Human: \"Can you pass me the red key?\""
                )
                anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
                save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p2_1.gif", anim, framerate=3, loop=-1)
        end    
    end

    if option == 2

        plan = @pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem2)", costs))
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p2_2_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                18 => "Human: \"Can you hand me that key?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p2_2.gif", anim, framerate=3, loop=-1)    
    end
end

end


function run_problem_3(option::Integer; complete = false)
    domain = load_domain(joinpath(path, "domain.pddl"))

    problem = load_problem(joinpath(path, "3.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = action_dict["3.1"]
        traj = PDDL.simulate(domain, state, plan)

        if complete == true
            sol = @pddl("(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key5)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(pickupr robot key4)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key4)", "(unlockh human key4 door3)", "(handover robot human key5)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)", "(noop robot)", "(unlockh human key5 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)")
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15,captions=captions ,show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p3_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                10 => "Human: \"Can you pass me the red keys?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p3_1.gif", anim, framerate=3, loop=-1)    
        end
    end

    if option == 2

        plan =  action_dict["3.2"]
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            captions = Dict(
                1 => "..."
                )
            sol = @pddl("(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key5)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(pickupr robot key4)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key4)", "(unlockh human key4 door3)", "(handover robot human key5)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)", "(noop robot)", "(unlockh human key5 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)")

            # sol = @pddl("(right robot)", "(noop human)", "(up robot)", "(noop human)","(pickupr robot key2)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)","(down robot)", "(noop human)","(down robot)", "(noop human)","(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(unlockh human key1 door2)", "(handover robot human key2)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key2 door1)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem1)")
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15,captions=captions ,show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p3_2_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                10 => "Human: \"Give me a red key for this door?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p3_2.gif", anim, framerate=3, loop=-1)    
        end
    end

    if option == 3
        plan =  action_dict["3.3"]
        # plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(up human)", "(noop robot)", "(unlock human key1 door2)","(noop robot)", "(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)", "(pickup human gem2)" )
        plan = collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan) 
        if complete == true
            captions = Dict(
                1 => "..."
                )
            sol = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(unlockh human key1 door4)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key2 door5)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickuph human gem3)")
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15 ,captions=captions,show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p3_3_complete.gif", anim, framerate=4, loop=-1)
        else  
            captions = Dict(
                1 => "...",
                8 => "Human: \"I need a key for this yellow door.\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p3_3.gif", anim, framerate=3, loop=-1) 
    
        end   
    end
end

# problem 4

function run_problem_4(option::Integer; complete = false)
    
    domain = load_domain(joinpath(path, "domain.pddl"))
    problem = load_problem(joinpath(path, "4.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)", "(noop robot)","(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            captions = Dict(
                1 => "...",
                )
            sol = @pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key3)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key4)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key3)", "(noop human)", "(handover robot human key4)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlockh human key3 door3)", "(noop robot)", "(down human)", "(noop robot)", "(unlockh human key4 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem3)")
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15 ,captions=captions,show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p4_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                8 => "Human: \"Can you pass me the red keys?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p4_1.gif", anim, framerate=3, loop=-1)    
        end
    end



    if option == 2

        plan = @pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)", "(noop robot)","(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            sol = @pddl("(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key5)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key6)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key5)", "(noop human)", "(handover robot human key6)", "(right human)", "(noop robot)", "(unlockh human key5 door1)", "(noop robot)", "(right human)", "(noop robot)", "(unlockh human key6 door2)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)")
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p4_2_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                8 => "Human: \"Can I have the blue keys?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p4_2.gif", anim, framerate=3, loop=-1)   
        end 
    end
end

function run_problem_5(option::Integer; complete = false)
    

    problem = load_problem(joinpath(path, "5.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(down human)",  "(noop robot)", "(down human)",  "(noop robot)", "(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem4)", costs))
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p5_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                6 => "Human: \"Can you pass me the blue key?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p5_1.gif", anim, framerate=3, loop=-1)   
        end 
    end

    # if option == 2

    #     plan = @pddl("(down human)",  "(noop robot)", "(down human)",  "(noop robot)", "(right human)",  "(noop robot)")
    #     traj = PDDL.simulate(domain, state, plan)
    #     captions = Dict(
    #         1 => "...",
    #         6 => "Human: \"Give me the blue and red keys.\""
    #         )
    #     anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
    #     save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p5_2.gif", anim, framerate=3, loop=-1)    
    # end

end


# problem 6

function run_problem_6(option::Integer; complete = false)
    

    problem = load_problem(joinpath(path, "6.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(left human)",  "(noop robot)", "(left human)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem4)", costs))
            captions = Dict(
                1 => "...\n...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p6_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...\n...",
                3 => "Human: \"I'm going for the red key, \n can you get the yellow key?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p6_1.gif", anim, framerate=3, loop=-1) 
        end   
    end

    if option == 2

        plan = @pddl("(left human)",  "(noop robot)", "(left human)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem2)", costs))
            captions = Dict(
                1 => "...\n...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p6_2_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...\n...",
                3 => "Human: \"On my way to pick up the blue key, \n can you find a yellow key?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p6_2.gif", anim, framerate=3, loop=-1) 
        end   
    end

end

function run_problem_7(option::Integer; complete = false)
    

    problem = load_problem(joinpath(path, "7.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(right human)",  "(noop robot)", "(right human)","(noop robot)","(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true

            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem2)", costs))
            captions = Dict(
                1 => "...\n...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p7_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...\n...",
                6 => "Human: \"I'm picking up the yellow key. \n Can you get a red key?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p7_1.gif", anim, framerate=3, loop=-1) 
        end   
    end

end


function run_problem_8(option::Integer; complete = false)
    


    if option == 1
        problem = load_problem(joinpath(path, "8.pddl"))

        state = initstate(domain, problem)

        plan = @pddl("(right human)","(noop robot)","(right human)","(noop robot)")
        traj = PDDL.simulate(domain, state, plan)

        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem4)", costs))
            captions = Dict(
                1 => "...\n...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p8_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "Human: \"I'll get the blue key. \n Can you pick up a red key?\"",
                2 => "Human: \"I'll get the blue key. \n Can you pick up a red key?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p8_1.gif", anim, framerate=3, loop=-1) 
        end   
    end

    if option == 2
        problem = load_problem(joinpath(path, "8b.pddl"))

        state = initstate(domain, problem)

        plan = @pddl("(down human)","(noop robot)","(down human)","(noop robot)")
        
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem4)", costs))
            captions = Dict(
                1 => "...\n...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p8_2_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "Human: \"I will pick up the red key. \n Can you get a blue one?\"",
                2 => "Human: \"I will pick up the red key. \n Can you get a blue one?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p8_2.gif", anim, framerate=3, loop=-1)
        end    
    end
end


function run_problem_9(option::Integer; complete = false)

    problem = load_problem(joinpath(path, "9.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)", "(noop robot)","(down human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem2)", costs))
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p9_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                8 => "Human: \"Can you go get the red key?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p9_1.gif", anim, framerate=3, loop=-1)  
        end  
    end
end


function run_problem_10(option::Integer; complete = false)
    domain = load_domain(joinpath(path, "domain.pddl"))

    problem = load_problem(joinpath(path, "10.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(noop human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem1)", costs))
            captions = Dict(
                1 => "...\n...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p10_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                    1 => "Human: \"I will pick up this red key. \n Can you find a yellow one?\"",
                    2 => "Human: \"I will pick up this red key. \n Can you find a yellow one?\""
                    )
                
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p10_1.gif", anim, framerate=3, loop=-1) 
        end   
    end

    if option == 2

        # plan = @pddl("(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)", "(noop robot)","(left human)",  "(noop robot)","(left human)",  "(noop robot)","(pickuph human key1)",  "(noop robot)", "(noop human)", "(noop robot)" )
        plan = @pddl("(noop human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem4)", costs))
            captions = Dict(
                1 => "...\n...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p10_2_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                    1 => "Human: \"I will pick up the blue key. \n Can you get the yellow key?\"",
                    2 => "Human: \"I will pick up the blue key. \n Can you get the yellow key?\""
                    )
                
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p10_2.gif", anim, framerate=3, loop=-1)  
        end  
    end

end

function run_problem_11(option::Integer; complete = false)
    

    problem = load_problem(joinpath(path, "11.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(up human)", "(noop robot)","(up human)",  "(noop robot)","(right human)",  "(noop robot)","(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem1)", costs))
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p11_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                12 => "Human: \"Can you get the key for this door?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p11_1.gif", anim, framerate=3, loop=-1)
        end    
    end


    if option == 2

        plan = @pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)","(right human)",  "(noop robot)","(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem4)", costs))
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p11_2_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                8 => "Human: \"Can you get me a key for this door?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p11_2.gif", anim, framerate=3, loop=-1)    
        end
    end

end



function run_problem_12(option::Integer; complete = false)
    

    problem = load_problem(joinpath(path, "12.pddl"))

    state = initstate(domain, problem)

    if option == 1
        plan = @pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = @pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(right human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(unlockr robot key1 door3)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem2)")
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer_door, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p12_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                8 => "Human: \"Can you come and unlock this door?\""
                )
            anim = anim_trajectory(renderer_door, domain, traj, format="gif", trail_length = 15,captions=captions,caption_size=28,  show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p12_1.gif", anim, framerate=3, loop=-1)
        end  
    end

    if option == 2
        plan = @pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem1)", costs))
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer_door, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p12_2_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                8 => "Human: \"Can you go and unlock that door?\""
                )
            anim = anim_trajectory(renderer_door, domain, traj, format="gif", trail_length = 15 , captions=captions,caption_size=28,  show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p12_2.gif", anim, framerate=3, loop=-1)
        end    
    end

end

function run_problem_13(option::Integer; complete = false)

    problem = load_problem(joinpath(path, "13.pddl"))

    costs_d = (
    pickuph=1.0,pickup=1.0, pickupr=1.0, handover=1.0, unlockh=1.0,unlockr=2.0, 
    up=1.0, down=1.0, left=1.0, right=1.0, noop=0.1
)

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(down human)",  "(noop robot)", "(down human)",  "(noop robot)","(pickuph human key3)",  "(noop robot)", "(up human)",  "(noop robot)",  "(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem3)", costs_d))
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer_door, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p13_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                10 => "Human: \"Can you open the blue door?\""
                )
            anim = anim_trajectory(renderer_door, domain, traj, format="gif", trail_length = 15 ,captions=captions,caption_size=28, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p13_1.gif", anim, framerate=3, loop=-1)
        end    
    end

    if option == 2

        plan = @pddl("(down human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)","(pickuph human key2)",  "(noop robot)", "(right human)",  "(noop robot)",  "(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)

        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem1)", costs_d))
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer_door, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p13_2_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                16 => "Human: \"Can you help me unlock \n the blue door there?\""
                )
            anim = anim_trajectory(renderer_door, domain, traj, format="gif", trail_length = 15 ,captions=captions,caption_size=28, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p13_2.gif", anim, framerate=3, loop=-1)
        end    
    end
end

function run_problem_14(option::Integer; complete = false)
    

    problem = load_problem(joinpath(path, "14.pddl"))
    state = initstate(domain, problem)

    if option == 1

        # plan = @pddl("(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)", "(noop robot)","(left human)",  "(noop robot)","(left human)",  "(noop robot)","(pickuph human key1)",  "(noop robot)", "(noop human)", "(noop robot)" )
        plan = @pddl("(noop human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)

        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem4)", costs))
            captions = Dict(
                1 => "...\n...",
                )
            anim = anim_plan(renderer_door, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p14_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                    1 => "Human: \"I'm picking up the red key. \n Can you get the blue door?\"",
                    2 => "Human: \"I'm picking up the red key. \n Can you get the blue door?\""
                    )
            anim = anim_plan(renderer_door, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p14_1.gif", anim, framerate=3, loop=-1)
        end    
    end
end

function run_problem_15(option::Integer; complete = false)
    
    domain = load_domain(joinpath(path, "domain.pddl"))
    problem = load_problem(joinpath(path, "15.pddl"))

    state = initstate(domain, problem)

    if option == 1

        # plan = @pddl("(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)", "(noop robot)","(left human)",  "(noop robot)","(left human)",  "(noop robot)","(pickuph human key1)",  "(noop robot)", "(noop human)", "(noop robot)" )
        plan = @pddl("(noop human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem3)", costs))
            captions = Dict(
                1 => "...\n...",
                )
            anim = anim_plan(renderer_door, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p15_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                    1 => "Human: \"I'm gonna get the blue key. \n Can you open the red door?\"",
                    2 => "Human: \"I'm gonna get the blue key. \n Can you open the red door?\""
                    )
                
            anim = anim_plan(renderer_door, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p15_1.gif", anim, framerate=3, loop=-1)  
        end  
    end
end

function run_problem_16(option::Integer; complete = false)
    

    problem = load_problem(joinpath(path, "16.pddl"))

    state = initstate(domain, problem)

    if option == 1

        # plan = @pddl("(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)", "(noop robot)","(left human)",  "(noop robot)","(left human)",  "(noop robot)","(pickuph human key1)",  "(noop robot)", "(noop human)", "(noop robot)" )
        plan = @pddl("(noop human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)

        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem3)", costs))
            captions = Dict(
                1 => "...\n...",
                )
            anim = anim_plan(renderer_door, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p16_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                    1 => "Human: \"Can you get the blue door there?\n I'll pick up the key for the red door.\"",
                    2 => "Human: \"Can you get the blue door there?\n I'll pick up the key for the red door.\""
                    )
                
            anim = anim_plan(renderer_door, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p16_1.gif", anim, framerate=3, loop=-1)  
        end  
    end
end



function run_problem_17(option::Integer; complete = false)
    
    costs = (
    pickuph=1.0,pickup=1.0, pickupr=1.0, handover=1.0, unlockh=1.0,unlockr=1.0, 
    up=1.0, down=1.0, left=1.0, right=1.0, noop=0.1
)
    problem = load_problem(joinpath(path, "17.pddl"))

    state = initstate(domain, problem)

    if option == 1
        plan = @pddl("(down human)",  "(noop robot)", "(down human)",  "(noop robot)","(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem2)", costs))
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer_door, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p17_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                4 => "Human: \"Can you come and get this red door?\""
                )
            anim = anim_plan(renderer_door, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p17_1.gif", anim, framerate=3, loop=-1)
        end    
    end
end



function run_problem_18(option::Integer; complete = false)

    problem = load_problem(joinpath(path, "18.pddl"))

    state = initstate(domain, problem)

    if option == 1
        plan = @pddl("(left human)",  "(noop robot)", "(up human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem1)", costs_d))
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer_door, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p18_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                4 => "Human: \"Can you unlock this red door?\""
                )
            anim = anim_plan(renderer_door, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p18_1.gif", anim, framerate=3, loop=-1) 
        end   
    end
end

function run_problem_19(option::Integer; complete = false )
    
    problem = load_problem(joinpath(path, "19.pddl"))
    state = initstate(domain, problem)

    if option == 1
        plan = @pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem2)", costs))
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p19_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                4 => "Human: \"Can you pass me the blue key?\""
                )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p19_1.gif", anim, framerate=3, loop=-1)  
        end  
    end
end


function run_problem_20(option::Integer; complete = false)
    

    problem = load_problem(joinpath(path, "20.pddl"))

    state = initstate(domain, problem)

    if option == 1
        plan = @pddl("(down human)",  "(noop robot)", "(down human)",  "(noop robot)", "(left human)",  "(noop robot)", "(pickuph human key1)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        if complete == true
            astar = AStarPlanner(GoalManhattan(), save_search=true)
            sol = astar(domain, traj[end], MinActionCosts(pddl"(has human gem2)", costs))
            captions = Dict(
                1 => "...",
                )
            anim = anim_plan(renderer_door, domain, traj[end], sol, trail_length = 15, captions=captions, show_inventory = true, framerate=4, caption_color = :white ,caption_size=28)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part2/p20_1_complete.gif", anim, framerate=4, loop=-1)
        else
            captions = Dict(
                1 => "...",
                12 => "Human: \"Can you come and get this blue door?\""
                )
            anim = anim_plan(renderer_door, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/part1/p20_1.gif", anim, framerate=3, loop=-1)  
        end  
    end
end

function c(option::Integer)
    convert_ascii_problem("/Users/lance/Documents/GitHub/Plinf.jl-refactor/domains/Assistive/$option.txt")
end



function run_all(complete=false)
    run_problem_1(1; complete)
    run_problem_2(1; complete)
    run_problem_2(2; complete)
    run_problem_3(1; complete)
    run_problem_3(2; complete)
    run_problem_3(3; complete)
    run_problem_4(1; complete)
    run_problem_4(2; complete)

end

function run_2(complete=false)
    run_problem_5(1; complete)
    println("5.1")
    run_problem_6(1; complete)
    println("6.1")
    run_problem_6(2; complete)
    println("6.2")
    run_problem_7(1; complete)
    println("7.1")
    run_problem_8(1; complete)
    println("8.1")
    run_problem_8(2; complete)
    println("8.2")
    run_problem_9(1; complete)
    println("9.1")
    run_problem_10(1; complete)
    println("10.1")
    run_problem_10(2; complete)
    println("10.2")
    run_problem_11(1; complete)
    println("11.1")
    run_problem_11(2; complete)
    println("11.2")
    run_problem_12(1; complete)
    println("12.1")
    run_problem_12(2; complete)
    println("12.2")
    run_problem_13(1; complete)
    println("13.1")
    run_problem_13(2; complete)
    println("13.2")
    run_problem_14(1; complete)
    println("14.1")
    run_problem_15(1; complete)
    println("15.1")
    run_problem_16(1; complete)
    println("16.1")
    run_problem_17(1; complete)
    println("17.1")
    run_problem_18(1; complete)
    println("18.1")
    run_problem_19(1; complete)
    println("19.1")
    run_problem_20(1; complete)
    println("20.1")
end

run_all(false)
run_all(true)

run_problem_5(1, complete = false)
run_problem_6(1, complete = false)

run_2(true)

run_demo(true)