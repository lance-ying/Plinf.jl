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
plan_dict=Dict("p1_g1"=>@pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(left human)", "(left robot)", "(left human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(down robot)", "(left human)", "(unlockr robot key1 door1)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)"),
"p1_g2"=>@pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(up human)", "(right robot)", "(up human)", "(right robot)", "(right human)", "(right robot)", "(right human)", "(unlockr robot key2 door2)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem2)"),
"p1_g3"=>@pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(up human)", "(down robot)", "(right human)", "(right robot)", "(right human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(unlockr robot key2 door2)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem3)"),
"p2_g1"=>@pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(right human)", "(up robot)", "(right human)", "(handover robot human key2)", "(unlockh human key2 door3)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human key1)", "(noop robot)", "(right human)", "(noop robot)", "(unlockh human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem1)"),
"p2_g2"=>@pddl("(noop human)", "(left robot)", "(right human)", "(left robot)", "(right human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(down robot)", "(noop human)","(down robot)", "(noop human)", "(down robot)", "(noop human)", "(pickupr robot key4)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(handover robot human key2)", "(unlockh human key2 door3)", "(handover robot human key4)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlockh human key4 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem2)"),
"p2_g3"=>@pddl("(noop human)", "(left robot)", "(right human)", "(left robot)", "(right human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(handover robot human key2)", "(unlockh human key2 door3)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem3)"),
"p3_g1"=>@pddl("(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)"),
"p3_g2"=>@pddl("(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(up human)", "(noop robot)", "(unlockh human key2 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem2)"),
"p3_g3"=>@pddl("(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key2 door3)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem3)"),
"p3_g4"=>@pddl("(down human)", "(down robot)", "(down human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(left robot)", "(right human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key1)", "(unlockh human key1 door4)", "(handover robot human key2)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlockh human key2 door5)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem4)"),
"p4_g1"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key1)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(unlockh human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)"),
"p4_g2"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlockh human key2 door3)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickuph human gem2)"),
"p4_g3"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key1)","(noop human)", "(down robot)", "(noop human)" ,"(pickupr robot key2)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(noop human)",  "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key2)","(noop human)",  "(handover robot human key1)",  "(down human)", "(noop robot)" ,  "(unlockh human key2 door2)","(noop robot)" , "(down human)", "(noop robot)", "(unlockh human key1 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickuph human gem3)"),
"p4_g4"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key1)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlockh human key1 door5)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickuph human gem4)"),
"p5_g1"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(right human)", "(right robot)", "(right human)", "(up robot)", "(right human)", "(pickupr robot key1)", "(pickuph human key3)", "(down robot)", "(left human)", "(down robot)", "(unlockh human key3 door3)", "(down robot)", "(noop human)", "(handover robot human key2)", "(noop human)", "(handover robot human key1)","(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key2 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(unlockh human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem1)"),
"p5_g3"=>@pddl("(noop human)", "(noop robot)","(right human)", "(up robot)", "(right human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(right human)", "(right robot)", "(pickuph human key3)", "(down robot)", "(left human)", "(noop robot)", "(unlockh human key3 door3)", "(down robot)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key2 door4)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem3)"),
"p5_g4"=>@pddl("(noop human)", "(noop robot)","(right human)", "(up robot)", "(right human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(right human)", "(right robot)", "(pickuph human key3)", "(up robot)", "(left human)", "(pickupr robot key1)", "(unlockh human key3 door3)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key1)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlockh human key1 door5)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlockh human key2 door6)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem4)"),
"p6_g1" => @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(up human)", "(up robot)", "(up human)", "(left robot)", "(right human)", "(left robot)", "(up human)", "(left robot)", "(noop human)","(left robot)", "(noop human)", "(handover robot human key1)", "(unlockh human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)"),
"p6_g1" => @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(up human)", "(up robot)", "(up human)", "(left robot)", "(right human)", "(left robot)", "(up human)", "(left robot)", "(noop human)","(left robot)", "(noop human)", "(handover robot human key1)", "(unlockh human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)"),
"p6_g3" => @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(down human)", "(down robot)", "(down human)", "(down robot)", "(down human)", "(down robot)", "(down human)", "(down robot)", "(left human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)","(noop human)",  "(up robot)","(noop human)", "(handover robot human key2)",  "(unlockh human key2 door3)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem3)"))

# problem 1
path = joinpath(dirname(pathof(Plinf)), "..", "domains", "Assistive")
domain = load_domain(joinpath(path, "domain.pddl"))

function viz_l(traj, domain;splitpoints::Vector{Int64},  problem::String, captions::Vector{String})

    split_array = [1]
    append!(split_array, splitpoints)
    push!(split_array, length(traj))

    print(split_array)

    for (i, t_start) in enumerate(split_array[1:end-1])
        t_stop = split_array[i+1]
        states = traj[t_start:t_stop]
        # Render animation
        anim = anim_trajectory(renderer, domain, states, format="gif", captions=[captions[i]],caption_size= 28, framerate=3)
        # Save animation with loop=-1 to get rid of GIF looping
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/$(problem)_$(i).gif", anim, framerate=3, loop=-1)
    end

end



function run_demo()
    problem = load_problem(joinpath(path, "demo.pddl"))
    state = initstate(domain, problem)
    plan = @pddl("(down human)",  "(noop robot)", "(right human)",  "(noop robot)")
    traj = PDDL.simulate(domain, state, plan)
    captions = Dict(
        1 => "...",
        4 => "Human: \"Can you pass me a yellow key?\""
        )
    anim = anim_trajectory(renderer, domain, traj, format="gif", captions=captions,caption_size=28, framerate=3)
    save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/demo_1.gif", anim, framerate=3, loop=-1)  

    problem = load_problem(joinpath(path, "demo1.pddl"))
    state = initstate(domain, problem)
    plan = @pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)",  "(noop robot)")
    traj = PDDL.simulate(domain, state, plan)
    captions = Dict(
        1 => "...",
        6 => "Human: \"Can you pass me a red key?\""
        )
    anim = anim_trajectory(renderer, domain, traj, format="gif", captions=captions,caption_size=28, framerate=3)
    save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/demo_2.gif", anim, framerate=3, loop=-1)  

end


function run_show(option::Integer)

    problem = load_problem(joinpath(path, "show.pddl"))

    state = initstate(domain, problem)
    if option == 1
        plan = @pddl("(noop human)",  "(left robot)", "(noop human)",  "(left robot)", "(noop human)",  "(left robot)","(noop human)",  "(left robot)","(noop human)", "(left robot)","(noop human)",  "(pickupr robot key1)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "Human: \"Can you go get the green gem?\"",
            8 => "Human: \"Can you go get the green gem?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/show_1.gif", anim, framerate=3, loop=-1)
    end
    if option == 2
        plan = @pddl("(noop human)",  "(right robot)", "(noop human)",  "(right robot)", "(noop human)", "(right robot)","(noop human)", "(pickupr robot key2)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "Human: \"Can you go get the green gem?\"",
            8 => "Human: \"Can you go get the green gem?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/show_2.gif", anim, framerate=3, loop=-1)
    end
end


function run_problem_1(option::Integer)

    problem = load_problem(joinpath(path, "1.pddl"))

    state = initstate(domain, problem)
    plan = @pddl("(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)", "(noop robot)","(left human)")
    traj = PDDL.simulate(domain, state, plan)
    captions = Dict(
        1 => "...",
        8 => "Human: \"Can you pass me the red key?\""
        )
    anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
    # anim_trajectory(renderer, domain, traj, format="gif", trail_length = 15, captions=captions,caption_size=28, framerate=3)
    save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p1_1.gif", anim, framerate=3, loop=-1)
end


# problem 2
function run_problem_2(option::Integer)
    

    problem = load_problem(joinpath(path, "2.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            10 => "Human: \"Can you pass me the red key?\""
            )
            anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
            save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p2_1.gif", anim, framerate=3, loop=-1)    
    end

    if option == 2

        plan = @pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            12 => "Human: \"Can you pass me the red key?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p2_2.gif", anim, framerate=3, loop=-1)    
    end

    if option == 3

        plan = @pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            18 => "Human: \"Can you hand me that key?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p2_3.gif", anim, framerate=3, loop=-1)    
    end

end




function run_problem_3(option::Integer)

    problem = load_problem(joinpath(path, "3.pddl"))

    state = initstate(domain, problem)

    # plt = render(state; start=start_pos, captions=captions,gem_colors=gem_colors)

    if option == 1

        plan = @pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(up human)", "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            6 => "Human: \"Can you pass me two keys?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p3_1.gif", anim, framerate=3, loop=-1)    
    end

    if option == 2

        plan = @pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(up human)", "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            6 => "Human: \"Can you pass me a red key?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p3_2.gif", anim, framerate=3, loop=-1)    
    end

    if option == 3
        plan = @pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(down human)", "(noop robot)","(down human)", "(noop robot)")
        # plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(up human)", "(noop robot)", "(unlock human key1 door2)","(noop robot)", "(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)", "(pickup human gem2)" )
        plan = collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        captions = Dict(
            1 => "...",
            8 => "Human: \"Can you pick up a red key for me?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p3_3.gif", anim, framerate=3, loop=-1) 
    end
end

# problem 4

function run_problem_4(option::Integer)
    

    problem = load_problem(joinpath(path, "4.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(down human)",  "(noop robot)", "(down human)",  "(noop robot)", "(down human)", "(noop robot)","(down human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            8 => "Human: \"Can you pass me the red keys?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p4_1.gif", anim, framerate=3, loop=-1)    
    end
end

function run_problem_5(option::Integer)
    

    problem = load_problem(joinpath(path, "5.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(down human)",  "(noop robot)", "(down human)",  "(noop robot)", "(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            6 => "Human: \"Can you pass me the blue key?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p5_1.gif", anim, framerate=3, loop=-1)    
    end

end


# problem 6

function run_problem_6(option::Integer)
    

    problem = load_problem(joinpath(path, "6.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(left human)",  "(noop robot)", "(left human)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...\n...",
            3 => "Human: \"I will pick up the red key, \n can you get the yellow key?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p6_1.gif", anim, framerate=3, loop=-1)    
    end

    if option == 2

        plan = @pddl("(left human)",  "(noop robot)", "(left human)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...\n...",
            3 => "Human: \"I will pick up the blue key, \n can you get the yellow key?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p6_2.gif", anim, framerate=3, loop=-1)    
    end

end

function run_problem_7(option::Integer)
    

    problem = load_problem(joinpath(path, "7.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(right human)",  "(noop robot)", "(right human)","(noop robot)","(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...\n...",
            6 => "Human: \"I will pick up the yellow key. \n Can you get the red key?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p7_1.gif", anim, framerate=3, loop=-1)    
    end

    if option == 2

        plan = @pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)",  "(noop robot)","(pickuph human key2)",)
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            15 => "Human: \"Can you pass me the red key?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p7_2.gif", anim, framerate=3, loop=-1)    
    end

    if option == 3

        plan = @pddl("(right human)",  "(noop robot)", "(right human)","(noop robot)","(right human)","(noop robot)","(right human)","(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            8 => "Human: \"Can you get the blue key for me?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p7_3.gif", anim, framerate=3, loop=-1)    
    end

end


function run_problem_8(option::Integer)
    
    problem = load_problem(joinpath(path, "8.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(noop human)","(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "Human: \"I will pick up the blue key. \n Can you get the red key?\"",
            2 => "Human: \"I will pick up the blue key. \n Can you get the red key?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p8_1.gif", anim, framerate=3, loop=-1)    
    end

    if option == 2

        plan = @pddl("(noop human)","(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "Human: \"I will pick up the red key. \n Can you get the blue key?\"",
            2 => "Human: \"I will pick up the red key. \n Can you get the blue key?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p8_2.gif", anim, framerate=3, loop=-1)    
    end
end


function run_problem_9(option::Integer)
    

    problem = load_problem(joinpath(path, "9.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)", "(noop robot)","(down human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            8 => "Human: \"Can you go get the red key?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p9_1.gif", anim, framerate=3, loop=-1)    
    end
end


function run_problem_10(option::Integer)
    

    problem = load_problem(joinpath(path, "10.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)", "(noop robot)","(left human)",  "(noop robot)","(left human)",  "(noop robot)","(pickuph human key1)",  "(noop robot)", "(noop human)", "(noop robot)" )
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            12 => "Human: \"Can you get the yellow key?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p10_1.gif", anim, framerate=3, loop=-1)    
    end

    if option == 2

        plan = @pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)", "(noop robot)","(right human)",  "(noop robot)","(right human)",  "(noop robot)","(pickuph human key2)",  "(noop robot)","(noop human)", "(noop robot)" )
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            12 => "Human: \"Can you get the yellow key?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = true, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p10_2.gif", anim, framerate=3, loop=-1)    
    end
end

function run_problem_11(option::Integer)
    

    problem = load_problem(joinpath(path, "11.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(up human)", "(noop robot)","(up human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            8 => "Human: \"Can you get the blue key for me?\""
            )
        anim = anim_plan(renderer, domain, state, plan, trail_length = 15 ,captions=captions,caption_size=28, show_inventory = false, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p11_1.gif", anim, framerate=3, loop=-1)    
    end
end



function run_all()
    run_problem_1(1)
    run_problem_2(1)
    run_problem_2(2)
    run_problem_2(3)
    run_problem_3(1)
    run_problem_3(2)
    run_problem_3(3)
    run_problem_4(1)
    run_problem_5(1)
    run_problem_6(1)
    run_problem_6(2)
    run_problem_7(1)
    run_problem_7(2)
    run_problem_7(3)
    run_problem_8(1)
    run_problem_8(2)
    run_problem_9(1)
    run_problem_10(1)
    run_problem_10(2)
    run_problem_11(1)
end

function run_problem_12(option::Integer)
    

    problem = load_problem(joinpath(path, "12.pddl"))

    state = initstate(domain, problem)

    if option == 1
        plan = @pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            8 => "Human: \"Can you come and unlock this door?\""
            )
        anim = anim_trajectory(renderer, domain, traj, format="gif", trail_length = 15,captions=captions,caption_size=28, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p12_1.gif", anim, framerate=3, loop=-1)    
    end

    if option == 2
        plan = @pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            8 => "Human: \"Can you go and unlock that door?\""
            )
        anim = anim_trajectory(renderer, domain, traj, format="gif", trail_length = 15 , captions=captions,caption_size=28, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p12_2.gif", anim, framerate=3, loop=-1)    
    end

end

function run_problem_13(option::Integer)

    problem = load_problem(joinpath(path, "13.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(down human)",  "(noop robot)", "(down human)",  "(noop robot)","(pickuph human key3)",  "(noop robot)", "(up human)",  "(noop robot)",  "(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            10 => "Human: \"Can you open the blue door?\""
            )
        anim = anim_trajectory(renderer, domain, traj, format="gif", trail_length = 15 ,captions=captions,caption_size=28, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p13_1.gif", anim, framerate=3, loop=-1)    
    end

    if option == 2

        plan = @pddl("(down human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)","(pickuph human key2)",  "(noop robot)", "(right human)",  "(noop robot)",  "(right human)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        captions = Dict(
            1 => "...",
            16 => "Human: \"Can you open the blue door?\""
            )
        anim = anim_trajectory(renderer, domain, traj, format="gif", trail_length = 15 ,captions=captions,caption_size=28, framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/p13_2.gif", anim, framerate=3, loop=-1)    
    end

end


function run_problem_b1(option::Integer)
    

    problem = load_problem(joinpath(path, "belief1.pddl"))

    state = initstate(domain, problem)

    if option == 1

        plan = @pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)","(left human)",  "(noop robot)","(pickuph human key3)",  "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)
        anim = anim_trajectory(renderer, domain, traj, format="gif", framerate=3)
        save("/Users/lance/Documents/GitHub/assistive-agent/stimuli/b1.gif", anim, framerate=3, loop=-1)    
    end
end