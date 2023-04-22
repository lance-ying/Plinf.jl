using Julog, PDDL, Gen, Printf
using Plinf

include("render_new.jl")
# include("render.jl")
include("utils.jl")
include("ascii.jl")

PDDL.Arrays.register!()

# Load domain and problem

# problem 1
path = joinpath(dirname(pathof(Plinf)), "..", "domains", "multi-agent")
domain = load_domain(joinpath(path, "domain.pddl"))

function viz(traj, domain;splitpoints::Vector{Int64},  problem::String)

    split_array = [1]
    append!(split_array, splitpoints)
    push!(split_array, length(traj))

    for (i, t_start) in enumerate(split_array[1:end-1])
        t_stop = split_array[i+1]
        states = traj[t_start:t_stop]
        # Render animation
        anim = anim_trajectory(renderer, domain, states, format="gif",  framerate=3)
        # Save animation with loop=-1 to get rid of GIF looping
        save("/Users/lance/Documents/GitHub/HRI/public/stimuli/$(problem)_$(i).gif", anim, framerate=3, loop=-1)
    end

end

function run_demo()

    problem = load_problem(joinpath(path, "demo2.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))

    num_gems=4
    # goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plan = @pddl("(left human)", "(up robot)", "(left human)", "(right robot)", "(left human)", "(pickup robot key1)", "(left human)", "(down robot)", "(left human)", "(left robot)", "(down human)", "(left robot)", "(down human)", "(left robot)", "(noop human)", "(unlock robot key1 door1)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickup human gem2)")
 
    traj = PDDL.simulate(domain, state, plan)

    # plan = collect(Term, plan)

    # captions = Dict(
    # 1 => "Human: \"Pick up the red key and unlock the red door for me.\""
    # )

    # anim = anim_trajectory(renderer, domain, traj, captions= captions, format="gif", framerate=3)
    # save("/Users/lance/Documents/GitHub/HRI/public/stimuli/demo-language.gif", anim)
    anim = anim_trajectory(renderer, domain, traj[1:1], format="gif", framerate=3)
    save("/Users/lance/Documents/GitHub/HRI/public/stimuli/demo_1.gif", anim, framerate=3, loop=-1)

    # anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, problem="demo")

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
    # captions = ["...","Human: \"Can you pass me the blue key?\"","...","...", "..."]

    # anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1, 3, 23, 30], problem="tutorial")

    # viz( traj, domain, splitpoints= [1, 3, 23, 30] , captions=captions, problem="tutorial_lan")
    viz( traj, domain, splitpoints= [1, 3, 23, 30] ,problem="tutorial")


end



function run_problem_1(option::Integer)

    problem = load_problem(joinpath(path, "p1.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))

    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    if option == 1
        plan = @pddl("(right human)", "(left robot)", "(right human)", "(left robot)", "(right human)", "(pickup robot key1)", "(up human)", "(unlock robot key1 door1)","(up human)", "(noop robot)","(left human)", "(noop robot)","(left human)", "(noop robot)","(left human)", "(noop robot)","(up human)", "(noop robot)","(up human)", "(noop robot)","(up human)", "(noop robot)","(up human)", "(noop robot)","(up human)", "(noop robot)","(pickup human gem1)" )
        traj = PDDL.simulate(domain, state, plan)

        plan = collect(Term, plan)        
        # print(splitpoints)
        viz(traj, domain,splitpoints=[1,10, 20], problem="p1_g1")
        # anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,8, 16],problem="p1_g1")
    end

    if option == 2
        plan = @pddl("(right human)", "(right robot)", "(right human)", "(right robot)", "(right human)", "(right robot)", "(up human)", "(pickup robot key2)", "(up human)", "(left robot)", "(up human)", "(unlock robot key2 door2)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)", "(noop robot)","(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(up human)","(noop robot)",  "(pickup human gem2)")       
        traj = PDDL.simulate(domain, state, plan)

        plan = collect(Term, plan)
        viz(splitpoints=[1,10, 20, 24], traj, domain, problem="p1_g2")
        # anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan)
    end


    if option == 3
        plan = @pddl("(right human)", "(right robot)", "(right human)", "(right robot)", "(right human)", "(right robot)", "(up human)", "(pickup robot key2)", "(up human)", "(left robot)", "(up human)", "(unlock robot key2 door2)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)","(noop robot)", "(right human)","(noop robot)", "(right human)","(noop robot)", "(right human)","(noop robot)","(pickup human gem3)")
        traj = PDDL.simulate(domain, state, plan)

        plan = collect(Term, plan)
        viz(splitpoints=[1,10, 20, 24], traj, domain, problem="p1_g3")

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
        plan = @pddl("(right human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(down robot)", "(right human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(up human)", "(noop robot)", "(unlock human key2 door3)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickup human key1)", "(noop robot)", "(right human)", "(noop robot)", "(unlock human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem1)")
        traj = PDDL.simulate(domain, state, plan)

        plan =  collect(Term, plan)
        viz(splitpoints=[1,10, 20, 34], traj, domain, problem="p2_g1")
        # anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,10, 24, 36],problem="p2_g1")
    end

    if option  == 2
        plan = @pddl("(right human)", "(left robot)", "(right human)", "(up robot)", "(down human)", "(pickup robot key2)", "(down human)", "(down robot)", "(down human)", "(left robot)", "(left human)", "(left robot)", "(left human)","(left robot)" , "(pickup human key4)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(handover robot human key2)", "(up human)", "(noop robot)", "(unlock human key2 door3)",  "(noop robot)","(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlock human key4 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickup human gem2)")
        traj = PDDL.simulate(domain, state, plan)

        plan =  collect(Term, plan)

        # plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
        viz(splitpoints=[1,12, 28, 38], traj, domain, problem="p2_g2")
        # anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,12, 28, 38],problem="p2_g2")
    end

    if option == 3
        plan = @pddl("(right human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(down robot)", "(right human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(up human)", "(noop robot)", "(unlock human key2 door3)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem3)")
        traj = PDDL.simulate(domain, state, plan)

        plan =  collect(Term, plan)

        plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
        viz(traj, domain;splitpoints=[1,8,17, 30],problem="p2_g3")
    end


end




function run_problem_3(option::Integer)

    problem = load_problem(joinpath(path, "p3.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))


    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plt = render(state; start=start_pos, gem_colors=gem_colors)

    if option == 1
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(up human)", "(left robot)", "(right human)", "(left robot)", "(right human)", "(left robot)", "(pickup human key2)", "(handover robot human key1)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key1 door3)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key2 door1)","(noop robot)", "(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)", "(pickup human gem1)" )
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        viz(traj, domain; splitpoints=[1,18, 28, 34],problem="p3_g1")
    end

    if option == 5
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(pickup robot key3)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)","(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)" , "(handover robot human key1)", "(noop human)", "(handover robot human key3)","(noop human)","(noop robot)", "(up human)","(noop robot)", "(unlock human key1 door3)","(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key3 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickup human gem1)")

        plan = collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan) 
        viz(traj, domain; splitpoints=[1,18, 28, 34],problem="p3_g5")
        # anim = anim_traj(traj, domain; splitpoints=[1,18, 28, 34],problem="p3_g5")
    end

    if option == 4
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(unlock human key1 door4)", "(handover robot human key2)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlock human key2 door5)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem4)")
        plan = collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan) 

        viz(traj, domain;splitpoints=[1,18, 29, 34, 42],problem="p3_g4")
    end

    if option == 2
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(up human)", "(noop robot)", "(unlock human key1 door2)","(noop robot)", "(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)", "(pickup human gem2)" )
        plan = collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        viz(traj, domain; splitpoints=[1,18, 28, 34],problem="p3_g2")
    end

    if option == 3
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(unlock human key1 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickup human gem3)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        viz(traj, domain;splitpoints=[1,19, 28, 34],problem="p3_g3")
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

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))

    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    if option ==1
        plan = @pddl("(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(pickup robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key1)", "(right human)","(noop robot)","(right human)","(noop robot)","(unlock human key1 door1)","(noop robot)","(right human)", "(noop robot)","(right human)", "(noop robot)","(pickup human gem1)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        viz(traj, domain;splitpoints=[1,10, 18, 25], problem="p4_g1")
    end

    if option ==2

        plan = @pddl("(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(down robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key2)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlock human key2 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickup human gem2)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        viz(traj, domain;splitpoints=[1,10, 18, 35], problem="p4_g2")
    end

    if option ==3
        plan = @pddl("(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(pickup robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key1)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlock human key1 door5)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickup human gem3)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        viz(traj, domain; splitpoints=[1,6, 18, 28], problem="p4_g3")
    end

    if option == 4
        plan = @pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(right human)", "(pickup robot key1)", "(right human)", "(down robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key2)", "(unlock human key2 door2)", "(handover robot human key1)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(down human)", "(noop robot)", "(unlock human key1 door3)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickup human gem4)")
    
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        viz(traj,domain;  splitpoints=[1,6, 18, 28, 40],problem="p4_g4")
    end


end

# problem 5
function run_problem_5(option::Integer)

    problem = load_problem(joinpath(path, "p5.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))



    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    # plt = render(state; start=start_pos, gem_colors=gem_colors)

    if option == 1
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickup robot key3)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key3)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key3 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(unlock human key2 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem1)")
                plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        viz(traj, domain;splitpoints=[1,6, 18, 28, 40],problem="p5_g1")

    end
    if option == 2
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickup robot key3)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key3)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key3 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)","(right human)", "(noop robot)","(right human)", "(noop robot)","(right human)", "(noop robot)","(pickup human gem2)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        viz(traj, domain;splitpoints=[1,7, 16, 28, 40],problem="p5_g2")

    end

    if option == 3
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickup robot key3)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key3)", "(noop human)", "(handover robot human key2)", "(unlock human key2 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key3 door5)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickup human gem3)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        viz(traj, domain;splitpoints=[1,8, 18, 28, 37, 42],problem="p5_g3")

    end

    if option == 4
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(unlock human key2 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem4)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        viz(traj, domain; splitpoints=[1,8, 18, 28, 35],problem="p5_g4")

    end

end