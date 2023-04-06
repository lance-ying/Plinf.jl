using Julog, PDDL, Gen, Printf
using Plinf

include("render.jl")
include("utils.jl")
include("ascii.jl")

PDDL.Arrays.register!()

# Load domain and problem

# problem 1
path = joinpath(dirname(pathof(Plinf)), "..", "domains", "multi-agent")
domain = load_domain(joinpath(path, "domain.pddl"))

function run_problem_1(option::Integer)

    problem = load_problem(joinpath(path, "p1.pddl"))

    state = initstate(domain, problem)


    num_gems=3
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plt = render(state; start=start_pos, gem_colors=gem_colors)


    # plan = Term[pddl"(noop human)", pddl"(noop robot)",pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(up human)", pddl"(pickup robot key2)", pddl"(up human)", pddl"(left robot)", pddl"(up human)", pddl"(unlock robot key2 door2)"]
    plan = Term[pddl"(noop human)", pddl"(noop robot)",pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(up human)", pddl"(pickup robot key2)", pddl"(up human)", pddl"(left robot)", pddl"(left human)", pddl"(unlock robot key2 door2)"]
    traj = PDDL.simulate(domain, state, plan)

    plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
    anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan)

end


# problem 2
function run_problem_2(option::Integer)

    problem = load_problem(joinpath(path, "p2.pddl"))

    state = initstate(domain, problem)


    num_gems=5
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plt = render(state; start=start_pos, gem_colors=gem_colors)


    if option == 3
        plan = Term[pddl"(right human)", pddl"(left robot)", pddl"(right human)", pddl"(up robot)", pddl"(right human)", pddl"(pickup robot key2)", pddl"(down human)", pddl"(down robot)", pddl"(down human)", pddl"(left robot)", pddl"(down human)", pddl"(left robot)", pddl"(left human)", pddl"(left robot)", pddl"(left human)",
        pddl"(left robot)", pddl"(pickup human key4)", pddl"(left robot)", pddl"(right human)", pddl"(left robot)", pddl"(right human)", pddl"(left robot)", pddl"(up human)", pddl"(noop robot)", pddl"(up human)", pddl"(handover robot human key2)", pddl"(up human)", pddl"(up robot)", pddl"(handover human robot key2)", 
        pddl"(noop robot)", pddl"(up human)", pddl"(unlock robot key2 door4)", pddl"(up human)", pddl"(noop robot)", pddl"(up human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)",
        pddl"(right human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(unlock human key4 door3)", pddl"(noop robot)", pddl"(up human)", pddl"(noop robot)", pddl"(up human)", pddl"(noop robot)", pddl"(up human)", pddl"(noop robot)", pddl"(pickup human gem3)"]
    
    end

    if option  == 2
        plan = Term[pddl"(right human)", pddl"(left robot)", pddl"(noop human)", pddl"(up robot)", pddl"(noop human)", pddl"(pickup robot key2)", pddl"(noop human)", pddl"(down robot)", pddl"(noop human)", pddl"(left robot)", pddl"(noop human)", pddl"(left robot)", pddl"(noop human)", pddl"(left robot)", pddl"(noop human)",
        pddl"(left robot)", pddl"(noop human)", pddl"(left robot)", pddl"(right human)", pddl"(left robot)", pddl"(right human)", pddl"(handover robot human key2)", pddl"(up human)", pddl"(noop robot)", pddl"(unlock human key2 door4)", pddl"(noop robot)", pddl"(up human)", pddl"(noop robot)", pddl"(up human)", pddl"(noop robot)",
        pddl"(left human)", pddl"(noop robot)", pddl"(left human)", pddl"(noop robot)", pddl"(left human)", pddl"(noop robot)", pddl"(pickup human key1)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(unlock human key1 door2)", pddl"(noop robot)", pddl"(up human)", pddl"(noop robot)", pddl"(up human)", 
        pddl"(noop robot)", pddl"(up human)", pddl"(noop robot)", pddl"(pickup human gem2)"] 
    end

    if option  == 4
        plan = Term[pddl"(right human)", pddl"(left robot)", pddl"(noop human)", pddl"(up robot)", pddl"(noop human)", pddl"(pickup robot key2)", pddl"(noop human)", pddl"(down robot)", pddl"(right human)", pddl"(left robot)", pddl"(right human)", pddl"(left robot)", pddl"(noop human)", pddl"(left robot)", pddl"(noop human)", 
        pddl"(left robot)", pddl"(noop human)", pddl"(left robot)", pddl"(noop human)", pddl"(left robot)", pddl"(noop human)", pddl"(handover robot human key2)", pddl"(up human)", pddl"(noop robot)", pddl"(unlock human key2 door4)", pddl"(noop robot)", pddl"(up human)", pddl"(noop robot)", pddl"(up human)", pddl"(noop robot)", 
        pddl"(right human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(right human)", 
        pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(pickup human gem4)"]
    end

    if option == 5
        plan = Term[pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(pickup robot key3)", pddl"(right human)", pddl"(left robot)", pddl"(right human)", pddl"(left robot)", pddl"(right human)", pddl"(left robot)", pddl"(right human)", pddl"(up robot)", pddl"(right human)", 
        pddl"(pickup robot key2)", pddl"(right human)", pddl"(down robot)", pddl"(right human)", pddl"(down robot)", pddl"(down human)", pddl"(unlock robot key2 door5)", pddl"(down human)", pddl"(handover robot human key3)", pddl"(down human)", pddl"(noop robot)", pddl"(unlock human key3 door6)", pddl"(noop robot)", pddl"(right human)", 
        pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(pickup human gem5)"]
    end
    traj = PDDL.simulate(domain, state, plan)

    plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
    anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan)

end


# problem 3

function run_problem_3a(option::Integer)

    problem = load_problem(joinpath(path, "p3.pddl"))

    state = initstate(domain, problem)


    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plt = render(state; start=start_pos, gem_colors=gem_colors)

    plan  = Term[pddl"(noop human)", pddl"(up robot)", pddl"(noop human)", pddl"(up robot)", pddl"(right human)", pddl"(pickup robot key1)", pddl"(noop human)", pddl"(down robot)", pddl"(right human)", pddl"(down robot)", pddl"(up human)", pddl"(down robot)", pddl"(pickup human key5)", pddl"(down robot)", 
    pddl"(down human)", pddl"(down robot)", pddl"(noop human)", pddl"(down robot)", pddl"(noop human)", pddl"(left robot)", pddl"(noop human)", pddl"(left robot)", pddl"(handover human robot key5)", ppdl"(handover robot human key1)", pddl"(left human)", pddl"(left robot)", pddl"(left human)", pddl"(left robot)", 
    pddl"(unlock human key1 door4)", pddl"(handover robot human key5)", pddl"(down human)", pddl"(noop robot)", pddl"(down human)", pddl"(noop robot)", pddl"(left human)", pddl"(noop robot)", pddl"(left human)", pddl"(noop robot)", pddl"(pickup human gem3)"]

    traj = PDDL.simulate(domain, state, plan)

    plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
    anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan)

end

# problem 3.5

function run_problem_3b(path::Integer)

    problem = load_problem(joinpath(path, "p3.pddl"))

    state = initstate(domain, problem)


    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plt = render(state; start=start_pos, gem_colors=gem_colors)


    plan = Term[pddl"(noop human)", pddl"(noop robot)",pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(up human)", pddl"(pickup robot key2)", pddl"(up human)", pddl"(left robot)", pddl"(up human)", pddl"(unlock robot key2 door2)"]
    traj = PDDL.simulate(domain, state, plan)

    plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
    anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan)

end

# problem 4
function run_problem_4(path::Integer)

    problem = load_problem(joinpath(path, "p4.pddl"))

    state = initstate(domain, problem)


    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plt = render(state; start=start_pos, gem_colors=gem_colors)


    plan = Term[pddl"(noop human)", pddl"(noop robot)",pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(up human)", pddl"(pickup robot key2)", pddl"(up human)", pddl"(left robot)", pddl"(up human)", pddl"(unlock robot key2 door2)"]
    traj = PDDL.simulate(domain, state, plan)

    plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
    anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan)

end

# problem 5
function run_problem_5(path::Integer)

    problem = load_problem(joinpath(path, "p5.pddl"))

    state = initstate(domain, problem)


    num_gems=4
    goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

    plt = render(state; start=start_pos, gem_colors=gem_colors)


    plan = Term[pddl"(noop human)", pddl"(noop robot)",pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(right human)", pddl"(right robot)", pddl"(up human)", pddl"(pickup robot key2)", pddl"(up human)", pddl"(left robot)", pddl"(up human)", pddl"(unlock robot key2 door2)"]
    traj = PDDL.simulate(domain, state, plan)

    plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
    anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan)

end