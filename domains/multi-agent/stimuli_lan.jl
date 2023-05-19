using Julog, PDDL, Gen, Printf
using Plinf

include("render_new.jl")
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
"p4_g1"=>@pddl("(noop human)", "(noop robot)","(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key1)", "(right human)","(noop robot)","(right human)","(noop robot)","(unlockh human key1 door1)","(noop robot)","(right human)", "(noop robot)","(right human)", "(noop robot)","(pickuph human gem1)"),
"p4_g2"=>@pddl("(noop human)", "(noop robot)","(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(down robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key2)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlockh human key2 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickuph human gem2)"),
"p4_g3"=>@pddl("(noop human)", "(noop robot)","(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key1)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlockh human key1 door5)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickuph human gem3)"),
"p4_g4"=>@pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(down robot)", "(right human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key2)", "(unlockh human key2 door2)", "(handover robot human key1)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(down human)", "(noop robot)", "(unlockh human key1 door3)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickuph human gem4)"),
"p5_g1"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(right human)", "(right robot)", "(right human)", "(up robot)", "(right human)", "(pickupr robot key1)", "(pickuph human key3)", "(down robot)", "(left human)", "(down robot)", "(unlockh human key3 door3)", "(down robot)", "(noop human)", "(handover robot human key2)", "(noop human)", "(handover robot human key1)","(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key2 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(unlockh human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem1)"),
"p5_g2"=>@pddl("(noop human)", "(noop robot)","(right human)", "(up robot)", "(right human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(right human)", "(right robot)", "(pickuph human key3)", "(down robot)", "(left human)", "(noop robot)", "(unlockh human key3 door3)", "(down robot)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key2 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem2)"),
"p5_g3"=>@pddl("(noop human)", "(noop robot)","(right human)", "(up robot)", "(right human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(right human)", "(right robot)", "(pickuph human key3)", "(down robot)", "(left human)", "(noop robot)", "(unlockh human key3 door3)", "(down robot)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key2 door4)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem3)"),
"p5_g4"=>@pddl("(noop human)", "(noop robot)","(right human)", "(up robot)", "(right human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(right human)", "(right robot)", "(pickuph human key3)", "(up robot)", "(left human)", "(pickupr robot key1)", "(unlockh human key3 door3)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key1)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlockh human key1 door5)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlockh human key2 door6)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem4)"),
"p6_g1" => @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(up human)", "(up robot)", "(up human)", "(left robot)", "(right human)", "(left robot)", "(up human)", "(left robot)", "(noop human)","(left robot)", "(noop human)", "(handover robot human key1)", "(unlockh human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)"),
"p6_g3" => @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(down human)", "(down robot)", "(down human)", "(down robot)", "(down human)", "(down robot)", "(down human)", "(down robot)", "(left human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)","(noop human)",  "(up robot)","(noop human)", "(handover robot human key2)",  "(unlockh human key2 door3)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem3)"))

# problem 1
path = joinpath(dirname(pathof(Plinf)), "..", "domains", "multi-agent")
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
        save("/Users/lance/Documents/GitHub/HRI_l/public/stimuli/$(problem)_$(i).gif", anim, framerate=3, loop=-1)
    end

end



function run_demo_lan()

    problem = load_problem(joinpath(path, "demo2.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))

    num_gems=4
    # goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plan = @pddl("(left human)", "(up robot)", "(left human)", "(right robot)", "(left human)", "(pickup robot key1)", "(left human)", "(down robot)", "(left human)", "(left robot)", "(down human)", "(left robot)", "(down human)", "(left robot)", "(noop human)", "(unlock robot key1 door1)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickup human gem2)")
 
    traj = PDDL.simulate(domain, state, plan)

    plan = collect(Term, plan)

    captions = Dict(
    1 => "Human: \"Pick up the red key and unlock the red door for me.\"",
    15 => "..."
    )

    anim = anim_trajectory(renderer, domain, traj, captions= captions,caption_size= 28, format="gif", framerate=3)
    save("/Users/lance/Documents/GitHub/HRI_l/public/stimuli/demo.gif", anim)
    # anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1], problem="demo")

end


function run_tutorial()

    problem = load_problem(joinpath(path, "demo1.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))

    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    # plt = render(state; start=start_pos, gem_colors=gem_colors)
    plan = @pddl("(right human)", "(noop robot)","(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key2)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlock human key2 door2)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickup human gem3)")
    traj = PDDL.simulate(domain, state, plan)

    plan = collect(Term, plan)
    captions = ["...","Human: \"Can you pass me the blue key?\"","...","...", "..."]

    # anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1, 3, 23, 30], problem="tutorial")

    viz_l( traj, domain, splitpoints= [1, 3, 23, 30] , captions=captions, problem="tutorial_lan")
    # viz( traj, domain, splitpoints= [1, 3, 23, 30] ,problem="tutorial")


end


function run_problem_1(option::Integer)

    problem = load_problem(joinpath(path, "p1.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))

    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    if option == 1
        plan = plan_dict["p1_g1"]
        # plan = @pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(left human)", "(left robot)", "(left human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(down robot)", "(left human)", "(unlock robot key1 door1)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)")
        traj = PDDL.simulate(domain, state, plan)

        plan = collect(Term, plan)
        captions = ["Human: \"Can you unlock the red door?\"","Human: \"Can you unlock the red door?\"","Human: \"Can you unlock the red door?\"","...", "..."]
        
        # print(splitpoints)
        viz_l(traj, domain,splitpoints=[1,10, 20, 25], captions=captions, problem="p1_g1")
        # anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,8, 16],problem="p1_g1")
    end

    if option == 2
        plan = plan_dict["p1_g2"]
        # plan = @pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(up human)", "(right robot)", "(up human)", "(right robot)", "(right human)", "(right robot)", "(right human)", "(unlock robot key2 door2)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem2)")
        traj = PDDL.simulate(domain, state, plan)

        plan = collect(Term, plan)
        captions = ["Human: \"Can you help me unlock the blue door?\"","Human: \"Can you help me unlock the blue door?\"","Human: \"Can you help me unlock the blue door?\"","...", "...","..."]
        viz_l(splitpoints=[1,10, 20, 30, 39], traj, domain, captions=captions, problem="p1_g2")
        # anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan)
    end


    if option == 3
        plan = plan_dict["p1_g3"]
        # plan = @pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(up human)", "(down robot)", "(right human)", "(right robot)", "(right human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(unlock robot key2 door2)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem3)")
        traj = PDDL.simulate(domain, state, plan)

        plan = collect(Term, plan)
        captions = ["Human: \"Can you unlock the blue door for me?\"","Human: \"Can you unlock the blue door for me?\"","Human: \"Can you unlock the blue door for me?\"","...", "...","..."]
        viz_l(splitpoints=[1,10, 20, 30, 39], traj, domain, captions=captions, problem="p1_g3")

        # anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints,problem="p1_g3")
    end

end


# problem 2
function run_problem_2(option::Integer)

    problem = load_problem(joinpath(path, "p2.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))

    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    if option == 1
        plan = plan_dict["p2_g1"]
        # plan = @pddl("(right human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(down robot)", "(right human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(up human)", "(noop robot)", "(unlock human key2 door3)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickup human key1)", "(noop robot)", "(right human)", "(noop robot)", "(unlock human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem1)")
        traj = PDDL.simulate(domain, state, plan)

        plan =  collect(Term, plan)

        captions = ["Human: \"Can you pass me the red key?\"","Human: \"Can you pass me the red key?\"","...","...", "...", "..."]

        viz_l(splitpoints=[1,12, 20, 28, 42], traj, domain,captions=captions, problem="p2_g1")
        # anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,10, 24, 36],problem="p2_g1")
    end

    if option  == 2
        plan = plan_dict["p2_g2"]
        # plan = @pddl("(right human)", "(left robot)", "(right human)", "(up robot)", "(down human)", "(pickup robot key2)", "(down human)", "(down robot)", "(down human)", "(left robot)", "(left human)", "(left robot)", "(left human)","(left robot)" , "(pickup human key4)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(handover robot human key2)", "(up human)", "(noop robot)", "(unlock human key2 door3)",  "(noop robot)","(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlock human key4 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickup human gem2)")
        traj = PDDL.simulate(domain, state, plan)

        plan =  collect(Term, plan)
        captions = ["Human: \"Can you give me the red and the yellow key?\"","Human: \"Can you give me the red and the yellow key?\"","...","...","...", "..."]
        # plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
        viz_l(splitpoints=[1,12, 28, 38, 50], traj, domain, captions=captions,problem="p2_g2")
        # anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,12, 28, 38],problem="p2_g2")
    end

    if option == 3
        plan = plan_dict["p2_g3"]
        # plan = @pddl("(right human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(down robot)", "(right human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(up human)", "(noop robot)", "(unlock human key2 door3)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem3)")
        traj = PDDL.simulate(domain, state, plan)

        plan =  collect(Term, plan)
        captions = ["Human: \"Can you pass me the red key?\"","Human: \"Can you pass me the red key?\"","...", "...","..."]
        viz_l(traj, domain;splitpoints=[1,12, 20, 38],captions=captions,problem="p2_g3")
    end


end




function run_problem_3(option::Integer)

    problem = load_problem(joinpath(path, "p3.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))


    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    # plt = render(state; start=start_pos, captions=captions,gem_colors=gem_colors)

    if option == 1
        plan = plan_dict["p3_g1"]
        # plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(up human)", "(left robot)", "(right human)", "(left robot)", "(right human)", "(left robot)", "(pickup human key2)", "(handover robot human key1)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key1 door3)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key2 door1)","(noop robot)", "(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)", "(pickup human gem1)" )
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        captions = ["Human: \"Can I have the blue key?\"","Human: \"Can I have the blue key?\"","...","...", "..."]
        viz_l(traj, domain; splitpoints=[1,10, 23, 34],captions=captions,problem="p3_g1")
    end

    if option == 2
        plan = plan_dict["p3_g2"]
        # plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(up human)", "(noop robot)", "(unlock human key1 door2)","(noop robot)", "(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)", "(pickup human gem2)" )
        plan = collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        captions = ["Human: \"Can you pass me the red key?\"","Human: \"Can you pass me the red key?\"","...","...", "..."]
        viz_l(traj, domain; splitpoints=[1,10, 23, 30],captions=captions,problem="p3_g2")
    end

    if option == 3
        plan = plan_dict["p3_g3"]
        # plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(unlock human key1 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickup human gem3)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        captions = ["Human: \"Can you pass me the red key?\"","Human: \"Can you pass me the red key?\"","...","...", "..."]
        viz_l(traj, domain;splitpoints=[1,10, 23, 30],captions=captions,problem="p3_g3")
    end


    if option == 4
        plan = plan_dict["p3_g4"]
        # plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(unlock human key1 door4)", "(handover robot human key2)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlock human key2 door5)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem4)")
        plan = collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan) 
        captions = ["Human: \"Can you give me the red and the blue key?\"","Human: \"Can you give me the red and the blue key?\"","...", "...","..."]
        viz_l(traj, domain;splitpoints=[1, 10, 16, 37],captions=captions,problem="p3_g4")
    end




    # plan =  collect(Term, plan)

    # plan  = Term[ pddl"(noop human)", pddl"(up robot)", pddl"(noop human)", pddl"(up robot)", pddl"(right human)", pddl"(pickup robot key1)", pddl"(noop human)", pddl"(down robot)", pddl"(right human)", pddl"(down robot)", pddl"(up human)", pddl"(down robot)", pddl"(pickup human key5)", pddl"(down robot)", 
    # pddl"(down human)", pddl"(down robot)", pddl"(noop human)", pddl"(down robot)", pddl"(noop human)", pddl"(left robot)", pddl"(noop human)", pddl"(left robot)", pddl"(handover human robot key5)", pddl"(handover robot human key1)", pddl"(left human)", pddl"(left robot)", pddl"(left human)"]
    # print(typeof(plan))

    # traj = PDDL.simulate(domain, state, plan)

    # plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
    # viz(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan)

end

# problem 4

function run_problem_4(option::Integer)

    problem = load_problem(joinpath(path, "p4.pddl"))

    state = initstate(domain, problem)

    # start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))
    # captions = ["Human: \"Can you pass me the red key?\"","...","...","...", "..."]
    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    if option ==1
        plan = plan_dict["p4_g1"]
        # plan = @pddl("(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(pickup robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key1)", "(right human)","(noop robot)","(right human)","(noop robot)","(unlock human key1 door1)","(noop robot)","(right human)", "(noop robot)","(right human)", "(noop robot)","(pickup human gem1)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        captions = ["Human: \"Can you pass me the red key?\"","Human: \"Can you pass me the red key?\"","...","...","..." ]
        viz_l(traj, domain;splitpoints=[1,16, 23, 28],captions=captions, problem="p4_g1")
    end

    if option ==2
        plan = plan_dict["p4_g2"]
        # plan = @pddl("(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(down robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key2)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlock human key2 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickup human gem2)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        captions = ["Human: \"Can you pass me the yellow key?\"","Human: \"Can you pass me the yellow key?\"","...","...","...", "..."]
        viz_l(traj, domain;splitpoints=[1,10, 18, 27, 44],captions=captions, problem="p4_g2")
    end

    if option ==3
        plan = plan_dict["p4_g3"]
        # plan = @pddl("(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(pickup robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key1)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlock human key1 door5)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickup human gem3)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        captions = ["Human: \"Can you pass me the red key?\"","Human: \"Can you pass me the red key?\"","...","...", "..."]
        viz_l(traj, domain; splitpoints=[1,10, 23, 28], captions=captions,problem="p4_g3")
    end

    if option == 4
        plan = plan_dict["p4_g4"]
        # plan = @pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(right human)", "(pickup robot key1)", "(right human)", "(down robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key2)", "(unlock human key2 door2)", "(handover robot human key1)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(down human)", "(noop robot)", "(unlock human key1 door3)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickup human gem4)")
    
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        captions = ["Human: \"Pass me the red and yellow key.\"","Human: \"Pass me the red and yellow key.\"","...","...", "...", "..."]
        viz_l(traj,domain;  splitpoints=[1,8, 30, 41],captions=captions,problem="p4_g4")
    end


end

# problem 5
function run_problem_5(option::Integer)

    problem = load_problem(joinpath(path, "p5.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))



    # num_gems=4
    # goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    # plt = render(state; start=start_pos, gem_colors=gem_colors)

    if option == 1
        plan = plan_dict["p5_g1"]
        # plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickup robot key3)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key3)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key3 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(unlock human key2 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem1)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)  
        captions = ["Human: \"Can you pass me a red and blue key?\"","Human: \"Can you pass me a red and blue key?\"","...","...", "...", "..."]
 
        viz_l(traj, domain;splitpoints=[1,8, 18, 28, 40],captions=captions,problem="p5_g1")

    end
    if option == 2
        plan = plan_dict["p5_g2"]
        # plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickup robot key3)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key3)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key3 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)","(right human)", "(noop robot)","(right human)", "(noop robot)","(right human)", "(noop robot)","(pickup human gem2)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        captions = ["Human: \"Can you pass me the blue key?\"","Human: \"Can you pass me the blue key?\"","...","...",  "..."]
 
        viz_l(traj, domain;splitpoints=[1,7, 22, 33],captions=captions,problem="p5_g2")

    end

    if option == 3
        plan = plan_dict["p5_g3"]
        # plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickup robot key3)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key3)", "(noop human)", "(handover robot human key2)", "(unlock human key2 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key3 door5)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickup human gem3)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        captions = ["Human: \"Can you pass me the blue key?\"","Human: \"Can you pass me the blue key?\"","...","...", "..."]

        viz_l(traj, domain;splitpoints=[1,9, 24, 32],captions=captions,problem="p5_g3")

    end

    if option == 4
        plan = plan_dict["p5_g4"]
        # plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(unlock human key2 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem4)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan) 
        captions = ["Human: \"Pass me the red and blue key.\"","Human: \"Pass me the red and blue key.\"","...","...", "...", "..."]
  
        viz_l(traj, domain; splitpoints=[1,9, 22, 30, 37],captions=captions,problem="p5_g4")

    end

end

# problem 6
function run_problem_6(option::Integer)

    problem = load_problem(joinpath(path, "p6.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))



    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    # plt = render(state; start=start_pos, gem_colors=gem_colors)

    if option == 1
        plan = plan_dict["p6_g1"]
        # plan = @pddl("(up human)", "(down robot)", "(up human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(unlock human key1 door1)",  "(noop robot)","(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        captions = ["Human: \"Can you pass me the red key?\"","Human: \"Can you pass me the red key?\"","...","...", "..."]
        viz_l(traj, domain;splitpoints=[1,8, 18, 30],captions=captions,problem="p6_g1")

    end


    if option == 3
        plan = plan_dict["p6_g3"]
        # plan = @pddl("(down human)", "(down robot)", "(down human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)",  "(unlock human key2 door3)", "(noop robot)","(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem3)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan) 
        captions = ["Human: \"Can you pass me the yellow key?\"","Human: \"Can you pass me the yellow key?\"","...","...", "..."]  
        viz_l(traj, domain; splitpoints=[1,8, 18, 30],captions=captions,problem="p6_g3")

    end

end

function run_all()
    for i in [1,2,3]
        run_problem_1(i)
        run_problem_2(i)
    end

    for i in [1,2,3,4]
        run_problem_3(i)
        run_problem_4(i)
        run_problem_5(i)
    end
end


function run_test()
    problem = load_problem(joinpath(path, "plan1.pddl"))

    state = initstate(domain, problem)

    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)
    plan = @pddl("(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)","(down human)", "(noop robot)")        
    plan =  collect(Term, plan)

    traj = PDDL.simulate(domain, state, plan)   
    captions = ["...","Human: \"Can you pass me the red key?\"","..."]
    viz_l(traj, domain;splitpoints=[1,5],captions=captions, problem="ptest")

end
