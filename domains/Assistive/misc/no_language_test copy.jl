using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie
using DelimitedFiles

include("utils.jl")
include("ascii.jl")
include("render.jl")
# include("load_plans.jl")
# include("utterance_model.jl")

costs = (
    pickuph=3.0, pickupr=1.0, handover=1.0, unlockh=1.0, unlockr=1.0, 
    up=1.0, down=1.0, left=1.0, right=1.0, noop=0.01
)

action_dict = Dict(
    
"1.1"=>@pddl("(left human)",  "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)","(left human)"),
"2.1"=>@pddl("(up human)",  "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)"),
"2.2"=>@pddl("(up human)",  "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)"),
"3.1"=>@pddl("(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)"),
"3.2"=>@pddl("(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)","(right human)","(noop robot)"),
"3.3"=>@pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)"),
"4.1"=>@pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)", "(noop robot)","(right human)",  "(noop robot)"),
"4.2"=>@pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)", "(noop robot)","(right human)",  "(noop robot)"),
"5.1"=>@pddl("(down human)",  "(noop robot)", "(down human)",  "(noop robot)", "(right human)",  "(noop robot)"),
"6.1"=>@pddl("(left human)",  "(noop robot)", "(left human)"),
"7.1"=>@pddl("(right human)",  "(noop robot)", "(right human)","(noop robot)","(right human)",  "(noop robot)"),
"8.1"=>@pddl("(right human)","(noop robot)","(right human)","(noop robot)"),
"8.2"=>@pddl("(down human)","(noop robot)","(down human)","(noop robot)"),
"9.1"=>@pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)", "(noop robot)","(down human)",  "(noop robot)"),
"10.1"=>@pddl("(noop human)",  "(noop robot)"),
"10.2"=>@pddl("(noop human)",  "(noop robot)"),
"11.1"=>@pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(up human)", "(noop robot)","(up human)",  "(noop robot)","(right human)",  "(noop robot)","(right human)",  "(noop robot)"),
"11.2"=>@pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)","(right human)",  "(noop robot)","(right human)",  "(noop robot)"),
"12.1"=>@pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)",  "(noop robot)"),
"12.2"=>@pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)"),
"13.1"=>@pddl("(down human)",  "(noop robot)", "(down human)",  "(noop robot)","(pickuph human key3)",  "(noop robot)", "(up human)",  "(noop robot)",  "(right human)",  "(noop robot)"),
"13.2"=>@pddl("(down human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)","(pickuph human key2)",  "(noop robot)", "(right human)",  "(noop robot)",  "(right human)",  "(noop robot)"),
"14.1"=>@pddl("(noop human)",  "(noop robot)"),
"15.1"=>@pddl("(noop human)",  "(noop robot)"),
"16.1"=>@pddl("(noop human)",  "(noop robot)"),
"17.1"=>@pddl("(down human)",  "(noop robot)", "(down human)",  "(noop robot)","(right human)",  "(noop robot)"),
"18.1"=>@pddl("(left human)",  "(noop robot)", "(up human)",  "(noop robot)"),
"19.1"=>@pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)"),
"20.1"=>@pddl("(down human)" , "(noop robot)","(down human)" ,"(noop robot)", "(left human)" , "(noop robot)","(pickuph human key1)" , "(noop robot)","(right human)" ,"(noop robot)", "(right human)" ))

problem_dict=Dict(
    "1"=>["1.1"],
    "2"=>["2.1","2.2"],
    "3"=>["3.1","3.2","3.3"],
    "4"=>["4.1","4.2"],
    "5"=>["5.1"],
    "6"=>["6.1"],
    "7"=>["7.1"],
    "8"=>["8.1","8.2"],
    "9"=>["9.1"],
    "10"=>["10.1","10.2"],
    "11"=>["11.1","11.2"],
    "12"=>["12.1","12.2"],
    "13"=>["13.1","13.2"],
    "14"=>["14.1"],
    "15"=>["15.1"],
    "16"=>["16.1"],
    "17"=>["17.1"],
    "18"=>["18.1"],
    "19"=>["19.1"],
    "20"=>["20.1"]
)
#--- Initial Setup ---#

# Register PDDL array theory
PDDL.Arrays.register!()

# Set problem to load

problem_id = 3

# Load domain and problem
domain = load_domain(joinpath(@__DIR__, "domain.pddl"))
problem = load_problem(joinpath(@__DIR__, "$problem_id.pddl"))

# Initialize state
state = initstate(domain, problem)

# Define action costs
costs = (
    pickuph=2.0, pickupr=1.0, handover=1.0, unlockh=1.0, unlockr=1.0, 
    up=1.0, down=1.0, left=1.0, right=1.0, noop=0.2
)

# Construct goal specification
spec = Specification(pddl"(has human gem1)")

# Compile and cache domain for faster performance
domain, state = PDDL.compiled(domain, state)
domain = CachedDomain(domain)

# Visualize initial state
canvas = renderer(domain, state)

#--- Visualize Plans ---#


# Check that A* heuristic search correctly solves the problem
astar = AStarPlanner(GoalManhattan(), save_search=true)
sol = astar(domain, state, spec)

# Visualize solution 
# plan = collect(sol)

# anim = anim_plan(renderer, domain, state, plan)

#--- Goal Inference Setup ---#

# Specify possible goals
goals = @pddl("(has human gem1)", "(has human gem2)",
              "(has human gem3)", "(has human gem4)")
goal_idxs = collect(1:length(goals))
goal_names = [write_pddl(g) for g in goals]
goal_colors = gem_colors[goal_idxs]

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

heuristic = GoalManhattan()
planner = RTHS(heuristic=heuristic, n_iters=1, max_nodes=2^32) 

# planner = RTDP(heuristic=heuristic, n_rollouts=0) 

# planner = RTDP(heuristic=heuristic, n_rollouts=100) 

# Define agent configuration

agent_config = AgentConfig(
    domain, planner;
    # Assume fixed goal over time
    goal_config = StaticGoalConfig(goal_prior),
    # Assume a small amount of action noise
    act_temperature = 4.0,
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
plan = action_dict["3.1"]



obs_traj = PDDL.simulate(domain, state, plan)

t_obs_iter = act_choicemap_pairs(plan)

# Construct callback for logging data and visualizing inference
callback = DKGCombinedCallback(
    renderer, domain;
    goal_addr = goal_addr,
    goal_names = ["gem1", "gem2", "gem3", "gem4"],
    goal_colors = goal_colors,
    obs_trajectory = PDDL.simulate(domain, state, plan),
    print_goal_probs = true,
    plot_goal_bars = false,
    plot_goal_lines = false,
    render = true,
    inference_overlay = true,
    record = true
)

# Configure SIPS particle filter
sips = SIPS(world_config, resample_cond=:none, rejuv_cond=:none)
         
# ENV["OPENAI_API_KEY"] = "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"
# Run particle filter to perform online goal inference
n_samples = 4
pf_state = sips(
    n_samples, t_obs_iter;
    init_args=(init_strata=goal_strata,),
    callback=callback
);