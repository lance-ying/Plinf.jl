using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie
using CSV, DataFrames
using HDF5, JLD

include("utils.jl")
# include("ascii.jl")
include("render.jl")
# include("load_plans.jl")
# include("utterance_model.jl")

# costs = (
#     pickuph=3.0, pickupr=1.0, handover=1.0, unlockh=1.0, unlockr=1.0, 
#     up=1.0, down=1.0, left=1.0, right=1.0, noop=0.01
# )

costs = (
    get_h=10.0,get_r=1.0, move=20, noop=0.6
)

costs = (
    takeout_h=10.0,takeout_r=1.0, putdown_h=10.0,putdown_r=1.0, noop=0.6
)

costs = (human = (
    move=10, grab=10, noop=0.6
),

robot = (
    move=5, grab=1, noop=0.6
))


p=1
# Register PDDL array theory
PDDL.Arrays.register!()

# Set problem to load

# problem_id = 3

# Load domain and problem
domain = load_domain(joinpath(@__DIR__, "domain1.pddl"))
problem = load_problem(joinpath(@__DIR__, "room.pddl"))

# Initialize state
state = initstate(domain, problem)

# Compile and cache domain for faster performance
domain, state = PDDL.compiled(domain, state)
domain = CachedDomain(domain)

traj = PDDL.simulate(domain, state, @pddl("(move human table1 fridge1)","(noop robot)","(grab human chicken1 fridge1)","(noop robot)","(grab human cucumber1 fridge1)"))


heuristic = memoized(precomputed(FFHeuristic(), domain, state))
# Check that A* heuristic search correctly solves the problem
astar = AStarPlanner(heuristic,  max_nodes=50000, h_mult=1.5)

goal = pddl"(and (delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(delivered cutleryfork4) (delivered cutleryknife1)(delivered cutleryknife2)(delivered cutleryknife3)(delivered cutleryknife4) (delivered plate1)(delivered plate2)(delivered plate3)(delivered plate4))"

spec = Specification(goal)
spec = MinPerAgentActionCosts(goal, costs)


@time sol = astar(domain, traj[end], spec)

plan_dict = Dict()

costs = (human = (
    move=5, grab=1.2, noop=0.6
),

robot = (
    move=5, grab=1, noop=0.6
))

pid="2.8"
goal = goal_dict[pid_dict[pid]]
plan = action_dict[pid]
# print(plan)
if plan isa Term
    plan = [plan]
end
# if length(plan)==1
#     plan = pddl"(noop human)"
# end
traj = PDDL.simulate(domain, state, plan)
spec = MinPerAgentActionCosts(goal, costs)
sol = astar(domain, traj[end], spec)
show(write_pddl.(sol))
# plan_dict[pid] = write_pddl.(sol)

for pid in ["3.8","2.7","3.7"]
    costs = (human = (
    move=5, grab=1.2, noop=0.6
),

robot = (
    move=5, grab=1, noop=0.6
))
    goal = goal_dict[pid_dict[pid]]
    plan = action_dict[pid]
    # print(plan)
    if plan isa Term
        plan = [plan]
    end
    # if length(plan)==1
    #     plan = pddl"(noop human)"
    # end
    traj = PDDL.simulate(domain, state, plan)
    spec = MinPerAgentActionCosts(goal, costs)
    sol = astar(domain, traj[end], spec)
    show(write_pddl.(sol))
    plan_dict[pid] = write_pddl.(sol)

end

for pid in ["1.4","2.8"]
    costs = (robot = (
    move=8, grab=1.2, noop=0.6
),

human = (
    move=8, grab=1, noop=0.6
))
    goal = goal_dict[pid_dict[pid]]
    plan = action_dict[pid]
    # print(plan)
    if plan isa Term
        plan = [plan]
    end
    # if length(plan)==1
    #     plan = pddl"(noop human)"
    # end
    traj = PDDL.simulate(domain, state, plan)
    spec = MinPerAgentActionCosts(goal, costs)
    sol = astar(domain, traj[end], spec)
    show(write_pddl.(sol))
    plan_dict[pid] = write_pddl.(sol)

end

for pid in keys(pid_dict)
    costs = (robot = (
    move=8, grab=1, noop=0.6
),

human = (
    move=8, grab=8, noop=0.6
))
    goal = goal_dict[pid_dict[pid]]
    plan = action_dict[pid]
    # print(plan)
    if plan isa Term
        plan = [plan]
    end
    # if length(plan)==1
    #     plan = pddl"(noop human)"
    # end
    traj = PDDL.simulate(domain, state, plan)
    spec = MinPerAgentActionCosts(goal, costs)
    sol = astar(domain, traj[end], spec)
    show(write_pddl.(sol))
    plan_dict[pid] = write_pddl.(sol)

end

plan = action_dict[p]
traj = PDDL.simulate(domain, state, plan)


# Visualize initial state
# canvas = renderer(domain, state)

#--- Visualize Plans ---#

sol = astar(domain, state, MinActionCosts(goals[1], costs))





# Construct goal specification
spec = Specification(pddl"(and (has cutleryfork1)(has cutleryfork2)(has cutleryfork3) (has cutleryknife1)(has cutleryknife2)(has cutleryknife3) (has plate1)(has plate2)(has plate3) (has bowl1)(has bowl2)(has bowl3))")
spec = Specification(pddl"(and (on onion1 table1) (on potato1 table1) (on potato1 table1) (on wine1 table1))")

# spec = Specification(pddl"(exist ?o - onion ?b - potato ?c - carrot ?p - potato ?w - wine)(and (on ?o table1) (on ?c table1) (on ?p table1) (on ?w table1))")
spec = Specification(pddl"(and (has human onion1) (has human carrot1))")
# spec = Specification(pddl"(has human onion1)")

# Visualize solution 
# plan = collect(sol)

# anim = anim_plan(renderer, domain, state, plan)

#--- Goal Inference Setup ---#

# Specify possible goals
goal_idxs = collect(1:length(goals))
goal_names = [write_pddl(g) for g in goals]
# goal_colors = gem_colors[goal_idxs]

# Define uniform prior over possible goals
@gen function goal_prior()
    goal ~ uniform_discrete(1, length(goals))
    return MinActionCosts(Term[goals[goal]], costs)
end

# Construct iterator over goal choicemaps for stratified sampling
goal_addr = :init => :agent => :goal => :goal
goal_strata = choiceproduct((goal_addr, 1:length(goals)))

# Use RTHS planner that updates value estimates of all neighboring states
# at each timestep, using full-horizon heuristic search to estimate the value
# heuristic = GoalManhattan()
# planner = RTHS(heuristic=heuristic, n_iters=1, max_nodes=1000) 
# heuristic = RelaxedMazeDist(GoalManhattan())
# heuristic = memoized(GoalManhattan())

heuristic = memoized(precomputed(FFHeuristic(), domain, state))

# heuristic = memoized(precomputed(HAddHeuristic(), domain, state))

# heuristic = GoalCountHeuristic()
# planner = RTHS(heuristic=heuristic, n_iters=1, max_nodes=1000, verbose = true) 

planner = RTDP(heuristic=heuristic, n_rollouts=0) 

# planner = RTDP(heuristic=heuristic, n_rollouts=100) 

# Define agent configuration

agent_config = AgentConfig(
    domain, planner;
    # Assume fixed goal over time
    goal_config = StaticGoalConfig(goal_prior),
    replan_args = (
        prob_replan = 0.0, # Probability of replanning at each timestep
        prob_refine = 1.0, # Probability of refining solution at each timestep
        rand_budget = false # Search budget is fixed everytime
    ),
    # Assume a small amount of action noise
    act_temperature = 1.0,
)


# Configure world model with agent and environment configuration
world_config = WorldConfig(
    agent_config = agent_config,
    env_config = PDDLEnvConfig(domain, state),
    obs_config = PerfectObsConfig()
)

#--- Online Goal Inference ---#

# Load plan dataset
# plans, utterances, splitpoints = load_plan_dataset(joinpath(@__DIR__, "plans"))
# plan = @pddl("(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)","(right human)","(noop robot)")
# utterance = "Can you give me a red key?"
plan = @pddl("(takeout human wine1 fridge1)","(noop robot)","(noop human)","(noop robot)")



obs_traj = PDDL.simulate(domain, state, plan)

t_obs_iter = act_choicemap_pairs(plan)

# Construct callback for logging data and visualizing inference
callback = DKGCombinedCallback(renderer,domain; render=false, goal_names = goal_name)

# Configure SIPS particle filter

ps = SIPS(world_config, resample_cond=:none, rejuv_cond=:none)
         
# ENV["OPENAI_API_KEY"] = "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"
# Run particle filter to perform online goal inference
n_samples = 29
@time pf_state = sips(
    n_samples, t_obs_iter;
    init_args=(init_strata=goal_strata,),
    callback=callback
);