using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie
using DelimitedFiles

include("utils.jl")
include("ascii.jl")
include("render.jl")
include("load_plans.jl")
include("utterance_model.jl")

#--- Initial Setup ---#

# Register PDDL array theory
PDDL.Arrays.register!()

# Set problem to load
problem_id = 4

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
heuristic = GoalManhattan()
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
    # Joint action-utterance model
    act_config = CommunicativeActConfig(
        BoltzmannActConfig(2.5), # Assume some Boltzmann action noise
        utterance_model, # Utterance model defined in utterance_model.jl
        (domain, planner) # Domain and planner are arguments to utterance model
    ),
)

# Configure world model with agent and environment configuration
world_config = WorldConfig(
    agent_config = agent_config,
    env_config = PDDLEnvConfig(domain, state),
    obs_config = PerfectObsConfig()
)

#--- Online Goal Inference ---#

# Load plan dataset
plans, utterances, splitpoints = load_plan_dataset(joinpath(@__DIR__, "plans"))

# Construct choicemap of observed actions to perform inference
goal_id = 4
index = "p$(problem_id)_g$(goal_id)"
plan = plans[index]
observations = act_choicemap_vec(plan)
timesteps = collect(1:length(observations))

# Add observed utterance to initial choicemap
observed_utterance = utterances[index]
observations[1][:timestep => 1 => :act => :utterance => :output] = " " * observed_utterance
observations[1][:timestep => 1 => :act => :sample_utterance] = true

# Set sample_utterance to false for all other timesteps
for t in 2:length(observations)
    observations[t][:timestep => t => :act => :sample_utterance] = false
end

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
           
# Run particle filter to perform online goal inference
n_samples = 4
pf_state = sips(
    n_samples,  observations;
    init_args=(init_strata=goal_strata,),
    callback=callback
);

# Extract goal probabilities
goal_probs = reduce(hcat, callback.logger.data[:goal_probs])

# Extract log likelihoods of observed utterance
utterance_addr = :timestep => 1 => :act => :utterance => :output
sample_utterance_addr = :timestep => 1 => :act => :sample_utterance
sel = Gen.select(utterance_addr, sample_utterance_addr)
utterance_logprobs = map(pf_state.traces) do trace
    return project(trace, sel)
end

# Set initial state probabilities to goal posterior given utterance
utterance_probs = GenParticleFilters.softmax(utterance_logprobs)
goal_probs[:, 1] = utterance_probs

# Extract animation
anim = callback.record.animation

# Create goal inference storyboard
times = splitpoints[index]
storyboard = render_storyboard(
    anim, times;
    subtitles = ["Human: $(observed_utterance)", 
                 fill("...", length(times)-1)...],
    xlabels = ["t = $t" for t in times],
    xlabelsize = 20, subtitlesize = 24
);
storyboard_goal_lines!(storyboard, goal_probs, times, show_legend=true)
