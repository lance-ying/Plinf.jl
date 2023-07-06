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
prob_dict = Dict{Any, Any}("13.2" => [0.6861064843444725, 0.3138935156555277, 0.0, 0.0], "10.1" => [0.0007556666270039837, 0.9986905955119368, 0.00020873913302459893, 0.0003449987280333683], "12.2" => [0.33314027686446923, 0.004390832842615356, 0.004721883916279629, 0.6577470063766357], "5.1" => [0.3736684146249905, 0.1750861265286925, 0.012130934294494577, 0.4391145245518225], "3.3" => [0.0, 0.0, 0.09999999999999999, 0.8999999999999988], "7.2" => [0.0, 0.9499999999999986, 0.025, 0.025], "3.2" => [0.05, 0.3125000000000001, 0.0125, 0.6249999999999998], "2.2" => [6.536028309023471e-6, 9.416863337552187e-9, 0.286273363444099, 0.7137200911107286], "7.3" => [0.07159960615788033, 0.37335295231440213, 0.3536824335594134, 0.20136500796830442], "2.1" => [0.46439095230277144, 0.532241849561955, 0.002759923189626549, 0.0006072749456469524], "13.1" => [0.5130827590038527, 4.1412967726673104e-5, 0.4868758196021913, 8.42622899923668e-9], "2.3" => [0.5936536948362695, 0.40634630511440273, 4.932790717232471e-11, 2.8730154652357504e-34], "4.1" => [0.00012226461089980673, 0.021637954047604966, 0.5614983697369976, 0.4167414116044975], "11.1" => [0.36250000000000016, 0.2875000000000001, 0.21250000000000005, 0.13749999999999998], "12.1" => [0.008522390815111481, 0.5434789191926346, 0.441026257527861, 0.006972432464393245], "1.1" => [0.0, 0.6999999999999995, 0.025, 0.2750000000000001], "6.1" => [0.33388140042668835, 0.13315316145874528, 0.3653295536654504, 0.1676358844491158], "7.1" => [0.07057849239695232, 0.2806729283676474, 0.39707659901406617, 0.25167198022133397], "10.2" => [0.0, 0.0, 0.9319136801173055, 0.06808631988269341], "6.2" => [0.25868646089622194, 0.1519426135994018, 0.3282009624519486, 0.2611699630524275], "3.1" => [0.17500000000000002, 0.1625, 0.3125000000000001, 0.35000000000000014], "9.1" => [0.029134332616093824, 0.8687069055761547, 1.1338793781245142e-7, 0.10215864841981413])

action_dict = Dict(
    
"1.1"=>@pddl("(left human)",  "(noop robot)", "(left human)","(noop robot)",  "(left human)","(noop robot)","(left human)"),
"2.1"=> @pddl("(up human)", "(noop robot)","(up human)",  "(noop robot)","(up human)","(noop robot)", "(left human)","(noop robot)", "(left human)"),
"2.2"=>@pddl("(up human)","(noop robot)",  "(up human)", "(noop robot)", "(up human)", "(noop robot)","(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)"),
"2.3"=>@pddl("(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)"),
"3.1"=>@pddl("(right human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)"),
"3.2"=>@pddl("(right human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)"),
"3.3"=>@pddl("(right human)", "(noop robot)", "(right human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)"),
"4.1"=>@pddl("(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)"),
"5.1"=>@pddl("(down human)", "(noop robot)",  "(down human)", "(noop robot)", "(right human)"),
"6.1"=>@pddl("(left human)", "(noop robot)", "(left human)"),
"6.2"=>@pddl("(left human)", "(noop robot)", "(left human)"),
"7.1"=>@pddl("(right human)", "(noop robot)",  "(right human)", "(noop robot)", "(right human)"),
"7.2"=>@pddl("(right human)",  "(right human)", "(right human)", "(right human)",  "(right human)", "(right human)", "(right human)", "(pickup human key2)"),
"7.3"=>@pddl("(right human)",  "(right human)","(right human)","(right human)"),
"8.1"=>@pddl("(noop human)"),
"8.2"=>@pddl("(noop human)"),
"9.1"=>@pddl("(right human)", "(right human)", "(right human)","(down human)"),
"10.1"=>@pddl("(left human)", "(left human)", "(left human)","(left human)","(left human)","(pickuph human key1)"),
"10.2"=>@pddl("(right human)", "(right human)",  "(right human)","(right human)","(right human)","(pickuph human key2)"),
"11.1"=>@pddl("(up human)", "(up human)", "(up human)","(up human)"),
"12.1"=>@pddl("(up human)",  "(up human)",  "(right human)", "(right human)"),
"12.2"=>@pddl("(up human)",  "(up human)", "(left human)", "(left human)"),
"13.1"=>@pddl("(down human)", "(down human)", "(pickup human key3)", "(up human)",  "(right human)"),
"13.2"=>@pddl("(down human)", "(left human)", "(left human)", "(left human)","(left human)", "(pickuph human key2)", "(right human)", "(right human)")

)

# Register PDDL array theory
PDDL.Arrays.register!()

# Set problem to load
problem_id = 2

# Load domain and problem
domain = load_domain(joinpath(@__DIR__, "domain.pddl"))
problem = load_problem(joinpath(@__DIR__, "$problem_id.pddl"))


# Initialize state
state = initstate(domain, problem)

state = PDDL.simulate(domain, state, collect(Term, action_dict["2.1"]))[end]


domain, state = PDDL.compiled(domain, state)
domain = CachedDomain(domain)

# Define action costs
costs = (
    pickuph=1.0, pickupr=1.0, handover=1.0, unlockh=1.0, unlockr=10.0, 
    up=1.0, down=1.0, left=1.0, right=1.0, noop=0.6
)

# Construct goal specification
# spec = Specification(Term[problem.goal])

# Compile and cache domain for faster performance
# domain, state = PDDL.compiled(domain, state)
# domain = CachedDomain(domain)

# Visualize initial state
canvas = renderer(domain, state)

#--- Visualize Plans ---#

# Check that A* heuristic search correctly solves the problem
# astar = AStarPlanner(GoalManhattan(), save_search=true)
# sol = astar(domain, state, spec)

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
    goal ~ categorical(prob_dict["2.1"])
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
        prob_replan = 0, # Probability of replanning at each timestep
        prob_refine = 1.0, # Probability of refining solution at each timestep
        rand_budget = false # Search budget is fixed everytime
    ),
    # Joint action-utterance model
    act_config = CommunicativeActConfig(
        BoltzmannActConfig(12.5), # Assume some Boltzmann action noise
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
# plans, utterances, splitpoints = load_plan_dataset(joinpath(@__DIR__, "plans"))

plan = @pddl("(noop robot)",  "(noop human)")
# Construct choicemap of observed actions to perform inference
# index = "p2"
# goal_id = 4
# index = "p$(problem_id)_g$(goal_id)"
# plan = plans[index]
observations = act_choicemap_vec(plan)
timesteps = collect(1:length(observations))
# Add observed utterance to initial choicemap
# observed_utterance = utterances[index]

observed_utterance = "can you pass me the red key?"
observations[1][:timestep => 1 => :act => :utterance => :output] = " " * observed_utterance


# Set sample_utterance to false for all other timesteps
for t in 1:length(observations)
    observations[t][:timestep => t => :act => :sample_utterance] = false
end

observations[1][:timestep => 1 => :act => :sample_utterance] = true


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
         
ENV["OPENAI_API_KEY"] = "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"
# Run particle filter to perform online goal inference
n_samples = 20
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
