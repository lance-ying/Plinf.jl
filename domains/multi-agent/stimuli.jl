using Julog, PDDL, Gen, Printf
using Plinf

include("render_new.jl")
include("render.jl")
include("utils.jl")
include("ascii.jl")

PDDL.Arrays.register!()

# Load domain and problem

# problem 1
path = joinpath(dirname(pathof(Plinf)), "..", "domains", "multi-agent")
domain = load_domain(joinpath(path, "domain.pddl"))

function run_demo()

    problem = load_problem(joinpath(path, "demo2.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))


    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plan = @pddl("(left human)", "(up robot)", "(left human)", "(right robot)", "(left human)", "(pickup robot key1)", "(left human)", "(down robot)", "(left human)", "(left robot)", "(down human)", "(left robot)", "(down human)", "(left robot)", "(noop human)", "(unlock robot key1 door1)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickup human gem2)")
 
    traj = PDDL.simulate(domain, state, plan)

    plan = collect(Term, plan)

    # plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
    anim = anim_trajectory(renderer, domain, traj, format="gif", framerate=3)
    save("anim-1.gif", anim, framerate=3, loop=-1)
    # anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1], problem="demo")

end


function run_tutorial()

    problem = load_problem(joinpath(path, "demo1.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))


    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plt = render(state; start=start_pos, gem_colors=gem_colors)
    plan = @pddl("(right human)", "(noop robot)","(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key2)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlock human key2 door2)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickup human gem3)")
    traj = PDDL.simulate(domain, state, plan)

    plan = collect(Term, plan)

    anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1, 3, 23, 30], problem="tutorial")
 

    # plan = Term[pddl"(noop human)", pddl"(noop robot)",pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(up human)", pddl"(pickup robot key2)", pddl"(up human)", pddl"(left robot)", pddl"(up human)", pddl"(unlock robot key2 door2)"]
    # plan = Term[pddl"(noop human)", pddl"(noop robot)",pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(up human)", pddl"(pickup robot key2)", pddl"(up human)", pddl"(left robot)", pddl"(left human)", pddl"(unlock robot key2 door2)"]


end



function run_problem_1(option::Integer)

    problem = load_problem(joinpath(path, "p1.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))


    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plt = render(state; start=start_pos, gem_colors=gem_colors)
    if option == 1
        plan = @pddl("(right human)", "(left robot)", "(right human)", "(left robot)", "(right human)", "(pickup robot key1)", "(up human)", "(unlock robot key1 door1)","(up human)", "(noop robot)","(left human)", "(noop robot)","(left human)", "(noop robot)","(left human)", "(noop robot)","(up human)", "(noop robot)","(up human)", "(noop robot)","(up human)", "(noop robot)","(up human)", "(noop robot)","(up human)", "(noop robot)")
        traj = PDDL.simulate(domain, state, plan)

        plan = collect(Term, plan)

        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,8, 16],problem="p1_g1")
    end

    if option == 2
        plan = @pddl("(right human)", "(right robot)", "(right human)", "(right robot)", "(right human)", "(right robot)", "(up human)", "(pickup robot key2)", "(up human)", "(left robot)", "(up human)", "(unlock robot key2 door2)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)","(noop robot)", "(right human)","(noop robot)", "(right human)","(noop robot)", "(right human)","(noop robot)")
        traj = PDDL.simulate(domain, state, plan)

        plan = collect(Term, plan)
    
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,10, 20],problem="p1_g2")
    end

end


# problem 2
function run_problem_2(option::Integer)

    problem = load_problem(joinpath(path, "p2.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))

    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plt = render(state; start=start_pos, gem_colors=gem_colors)
    # plan = Term[]


    if option == 1
        plan = @pddl("(right human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(down robot)", "(right human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(up human)", "(noop robot)", "(unlock human key2 door3)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickup human key1)", "(noop robot)", "(right human)", "(noop robot)", "(unlock human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem1)")
        traj = PDDL.simulate(domain, state, plan)

        plan =  collect(Term, plan)
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,10, 24, 36],problem="p2_g1")
    end

    if option  == 2
        plan = @pddl("(right human)", "(left robot)", "(right human)", "(up robot)", "(down human)", "(pickup robot key2)", "(down human)", "(down robot)", "(down human)", "(left robot)", "(left human)", "(left robot)", "(left human)","(left robot)" , "(pickup human key4)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(handover robot human key2)", "(up human)", "(noop robot)", "(unlock human key2 door3)",  "(noop robot)","(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlock human key4 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickup human gem2)")
        traj = PDDL.simulate(domain, state, plan)

        plan =  collect(Term, plan)

        plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,12, 28, 38],problem="p2_g2")
    end

    if option == 3
        plan = @pddl("(right human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(down robot)", "(right human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(up human)", "(noop robot)", "(unlock human key2 door3)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem3)")
        traj = PDDL.simulate(domain, state, plan)

        plan =  collect(Term, plan)

        plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan,splitpoints=[1,18, 30],problem="p2_g3")
    end

    if option  == 4
        plan = @pddl("(right human)", "(right robot)", "(right human)",  "(right robot)", "(right human)", "(pickup robot key3)", "(right human)", "(noop robot)", "(right human)","(noop robot)","(right human)","(noop robot)" , "(up human)", "(left robot)", "(pickup human key2)", "(left robot)", "(down human)", "(left robot)", "(down human)", "(down robot)", "(unlock human key2 door4)", "(down robot)", "(down human)", "(down robot)", "(down human)", "(unlock robot key3 door5)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem4)")
        traj = PDDL.simulate(domain, state, plan)

        plan =  collect(Term, plan)

        plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,18, 28],problem="p2_g4")
    end



end


# problem 3

function run_problem_3(option::Integer)

    problem = load_problem(joinpath(path, "p3.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))


    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plt = render(state; start=start_pos, gem_colors=gem_colors)

    if option == 1
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(up human)", "(left robot)", "(right human)", "(left robot)", "(right human)", "(left robot)", "(pickup human key3)", "(handover robot human key1)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key1 door3)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key3 door1)","(noop robot)", "(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)", "(pickup human gem1)" )
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,18, 28, 34],problem="p3_g1")
    end

    if option == 2
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(up human)", "(noop robot)", "(unlock human key1 door2)","(noop robot)", "(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)", "(pickup human gem2)" )
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,18, 28, 32],problem="p3_g2")
    end

    if option == 3
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(unlock human key1 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickup human gem3)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,18, 28],problem="p3_g3")
    end

    if option == 4
        plan = @pddl("(right human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(right human)", "(down robot)", "(up human)", "(down robot)", "(pickup human key3)", "(down robot)", "(down human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key1 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlock human key3 door5)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem4)") 
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,8,18, 28, 36],problem="p3_g4")
    end


    plan =  collect(Term, plan)

    # plan  = Term[ pddl"(noop human)", pddl"(up robot)", pddl"(noop human)", pddl"(up robot)", pddl"(right human)", pddl"(pickup robot key1)", pddl"(noop human)", pddl"(down robot)", pddl"(right human)", pddl"(down robot)", pddl"(up human)", pddl"(down robot)", pddl"(pickup human key5)", pddl"(down robot)", 
    # pddl"(down human)", pddl"(down robot)", pddl"(noop human)", pddl"(down robot)", pddl"(noop human)", pddl"(left robot)", pddl"(noop human)", pddl"(left robot)", pddl"(handover human robot key5)", pddl"(handover robot human key1)", pddl"(left human)", pddl"(left robot)", pddl"(left human)"]
    # print(typeof(plan))

    traj = PDDL.simulate(domain, state, plan)

    plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
    anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan)

end

# problem 4

function run_problem_4(option::Integer)

    problem = load_problem(joinpath(path, "p4.pddl"))

    state = initstate(domain, problem)

    start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))



    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plt = render(state; start=start_pos, gem_colors=gem_colors)

    if option ==1
        plan = @pddl("(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(pickup robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key1)", "(right human)","(noop robot)","(right human)","(noop robot)","(unlock human key1 door1)","(noop robot)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,10, 18, 28], problem="p4_g1")
    end
    
    if option == 4
        plan = @pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(right human)", "(pickup robot key1)", "(right human)", "(down robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key2)", "(unlock human key2 door2)", "(handover robot human key1)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(down human)", "(noop robot)", "(unlock human key1 door3)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickup human gem4)")
    
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,6, 18, 28, 40],problem="p4_g4")
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
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key2 door2)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)",  "(up human)", "(noop robot)",  "(right human)","(noop robot)", "(right human)", "(noop robot)", "(pickup human gem1)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,10, 24, 40, 46],problem="p5_g1")

    end
    if option == 2
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door2)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key2 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)","(right human)", "(noop robot)","(right human)", "(noop robot)", "(pickup human gem2)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,6, 18, 28, 42],problem="p5_g2")

    end

    if option == 3
        plan = @pddl("(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(pickup robot key3)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door2)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key3)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key3 door3)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickup human gem3)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,6, 18, 28],problem="p5_g3")

    end

    if option == 4
        plan = @pddl("(down human)", "(noop robot)", "(down human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickup human gem4)")
        plan =  collect(Term, plan)

        traj = PDDL.simulate(domain, state, plan)   
        anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan, splitpoints=[1,6, 18, 28],problem="p5_g4")

    end

end