using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie
using DelimitedFiles

include("utils.jl")
include("ascii.jl")
include("render.jl")
include("load_plans.jl")

#--- Initial Setup ---#

# Register PDDL array theory
PDDL.Arrays.register!()

# Set problem to load
problem_id = 2

# Load domain and problem
domain = load_domain(joinpath(@__DIR__, "domain.pddl"))
problem = load_problem(joinpath(@__DIR__, "p$problem_id.pddl"))

# Initialize state
state = initstate(domain, problem)

# Define action costs
costs = (
    pickuph=1.0, pickupr=1.0, handover=1.0, unlockh=1.0, unlockr=10.0, 
    up=1.0, down=1.0, left=1.0, right=1.0, noop=0.6
)

# Construct goal specification
spec = MinActionCosts(Term[problem.goal], costs)

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
plan = collect(sol)
anim = anim_plan(renderer, domain, state, plan)

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
heuristic = memoized(GoalManhattan())
planner = RTHS(heuristic=heuristic, n_iters=1, max_nodes=2^32)

# Define agent configuration
agent_config = AgentConfig(
    domain, planner;
    # Assume fixed goal over time
    goal_config = StaticGoalConfig(goal_prior),
    # Assume the agent refines its policy at every timestep
    replan_args = (
        prob_replan = 0.0, # Probability of replanning at each timestep
        prob_refine = 1.0, # Probability of refining solution at each timestep
        rand_budget = false # Search budget is fixed everytime
    ),
    # Assume some Boltzmann action noise (reduce this to make inferences sharper)
    act_temperature = 2.5,
)

# Configure world model with agent and environment configuration
world_config = WorldConfig(
    agent_config = agent_config,
    env_config = PDDLEnvConfig(domain, state),
    obs_config = PerfectObsConfig()
)

#--- Online Goal Inference ---#

# Load plan dataset
plans, _, splitpoints = load_plan_dataset(joinpath(@__DIR__, "plans"))

# Construct choicemap of observed actions to perform inference
goal_id = 1
index = "p$(problem_id)_g$(goal_id)"
plan = plans[index]
observations = act_choicemap_vec(plan)
timesteps = collect(1:length(observations))

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
    record = false
)

# Configure SIPS particle filter
sips = SIPS(world_config, resample_cond=:none, rejuv_cond=:none)

# Run particle filter to perform online goal inference
n_samples = length(goals)
@time pf_state = sips(
    n_samples,  observations, timesteps;
    init_args=(init_strata=goal_strata,),
    callback=callback
);

# Create goal inference storyboard
goal_probs = reduce(hcat, callback.logger.data[:goal_probs])
writedlm("results/no_lan/p$(problem_id)_g$(goal_id).csv",  goal_probs, ',')
