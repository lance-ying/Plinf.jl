using PDDL, SymbolicPlanners
using Gen, GenParticleFilters
using Plinf
using Printf
using PDDLViz, GLMakie

using GenParticleFilters: softmax

include("utils.jl")
include("heuristics.jl")
include("plan_io.jl")
include("utterance_model.jl")
include("inference.jl")
include("render.jl")
include("callbacks.jl")

PDDL.Arrays.@register()
GLMakie.activate!(inline=false)

## Load domains, problems and plans ##

# Define directory paths
PROBLEM_DIR = joinpath(@__DIR__, "problems")
PLAN_DIR = joinpath(@__DIR__, "plans", "observed")
COMPLETION_DIR = joinpath(@__DIR__, "plans", "completed")
STIMULI_DIR = joinpath(@__DIR__, "stimuli")

# Load domain
DOMAIN = load_domain(joinpath(@__DIR__, "domain.pddl"))
COMPILED_DOMAINS = Dict{String, Domain}()

# Load problems
PROBLEMS = Dict{String, Problem}()
for path in readdir(PROBLEM_DIR)
    name, ext = splitext(path)
    ext == ".pddl" || continue
    PROBLEMS[name] = load_problem(joinpath(PROBLEM_DIR, path))
end

# Load utterance-annotated plans and completions
PLAN_IDS, PLANS, UTTERANCES, UTTERANCE_TIMES = load_plan_dataset(PLAN_DIR)
PLAN_IDS, COMPLETIONS, _, _ = load_plan_dataset(COMPLETION_DIR)

## Set-up for specific plan and problem ##

# Select plan and problem
plan_id = "17.1.doors"

plan = PLANS[plan_id]
utterances = UTTERANCES[plan_id]
utterance_times = UTTERANCE_TIMES[plan_id]

assist_type = match(r"(\d+\w?).(\d+)\.(\w+)", plan_id).captures[3]
assist_obj_type = assist_type == "keys" ? :key : :door

problem_id = match(r"(\d+\w?).(\d+)\.(\w+)", plan_id).captures[1]
problem = PROBLEMS[problem_id]

# Determine true goal from completion
completion = COMPLETIONS[plan_id]
true_goal_obj = completion[end].args[2]
true_goal = Compound(:has, Term[pddl"(human)", true_goal_obj])

# Construct true goal specification
action_costs = (
    pickup=1.0, unlock=1.0, handover=1.0, 
    up=1.0, down=1.0, left=1.0, right=1.0, noop=0.9
)
true_goal_spec = MinActionCosts(Term[true_goal], action_costs)

# Compile domain for problem
domain = get!(COMPILED_DOMAINS, problem_id) do
    state = initstate(DOMAIN, problem)
    domain, _ = PDDL.compiled(DOMAIN, state)
    return domain
end

# Construct initial state
state = initstate(domain, problem)

# Simulate plan to completion
plan_end_state = EndStateSimulator()(domain, state, plan)

## Run literal listener inference ##

# Infer distribution over commands
commands, command_probs, command_scores =
    literal_command_inference(domain, plan_end_state, utterances[1], verbose=true)
top_command = commands[1]

# Print top 5 commands and their probabilities
println("Top 5 most probable commands:")
for idx in 1:5
    command_str = repr("text/plain", commands[idx])
    @printf("%.3f: %s\n", command_probs[idx], command_str)
end

# Compute naive assistance options and plans for top command
top_naive_assist_results = literal_assistance_naive(
    top_command, domain, plan_end_state, true_goal_spec, assist_obj_type;
    verbose = true
)

# Compute expected assistance options and plans via systematic sampling

expected_naive_assist_results = literal_assistance_naive(
    commands, command_probs,
    domain, plan_end_state, true_goal_spec, assist_obj_type;
    verbose = true, n_samples = 10
)

# Compute efficient assistance options and plans for top command
top_efficient_assist_results = literal_assistance_efficient(
    top_command, domain, plan_end_state, true_goal_spec, assist_obj_type;
    verbose = true
)

# Compute expected assistance options and plans via systematic sampling
expected_efficient_assist_results = literal_assistance_efficient(
    commands, command_probs,
    domain, plan_end_state, true_goal_spec, assist_obj_type;
    verbose = true, n_samples = 10
)

## Configure agent and world model ##

# Set options that vary across runs
ACT_TEMPERATURES = [2.0]
MODALITIES = (:action, :utterance)

# Define possible goals
goals = @pddl("(has human gem1)", "(has human gem2)",
              "(has human gem3)", "(has human gem4)")
goal_names = ["red", "yellow", "blue", "green"]

# Define possible cost profiles
cost_profiles = [
    ( # Equal cost profile, higher no-op cost
        human = (
            pickup=2.0, unlock=1.0, handover=1.0, 
            up=1.0, down=1.0, left=1.0, right=1.0, noop=0.9
        ),
        robot = (
            pickup=2.0, unlock=2.0, handover=1.0, 
            up=1.0, down=1.0, left=1.0, right=1.0, noop=0.9
        )
    ),
    ( # Equal cost profile, lower no-op cost
        human = (
            pickup=2.0, unlock=1.0, handover=1.0, 
            up=1.0, down=1.0, left=1.0, right=1.0, noop=0.6
        ),
        robot = (
            pickup=2.0, unlock=2.0, handover=1.0, 
            up=1.0, down=1.0, left=1.0, right=1.0, noop=0.6
        )
     ),
    ( # Human costs are higher, higher no-op cost
        human = (
            pickup=3.0, unlock=2.0, handover=2.0, 
            up=2.0, down=2.0, left=2.0, right=2.0, noop=0.9
        ),
        robot = (
            pickup=2.0, unlock=2.0, handover=1.0, 
            up=1.0, down=1.0, left=1.0, right=1.0, noop=0.9
        )
    ),
    ( # Human costs are higher, lower no-op cost
        human = (
            pickup=3.0, unlock=2.0, handover=2.0, 
            up=2.0, down=2.0, left=2.0, right=2.0, noop=0.6
        ),
        robot = (
            pickup=2.0, unlock=2.0, handover=1.0, 
            up=1.0, down=1.0, left=1.0, right=1.0, noop=0.6
        )
    )
]    

# Define goal prior
@gen function goal_prior()
    # Sample goal index
    goal ~ uniform_discrete(1, length(goals))
    # Sample action costs
    cost_idx ~ uniform_discrete(1, length(cost_profiles))
    costs = cost_profiles[cost_idx]
    # Construct goal specification
    spec = MinPerAgentActionCosts(Term[goals[goal]], costs)
    return spec
end

# Configure planner
heuristic = precomputed(DoorsKeysMSTHeuristic(), domain, state)
planner = RTHS(heuristic=heuristic, n_iters=2, max_nodes=128)

# Define agent configuration prior
@gen function agent_config_prior()
    temperature ~ uniform_discrete(1, length(ACT_TEMPERATURES))
    # Define communication and action configuration
    act_config = BoltzmannActConfig(ACT_TEMPERATURES[temperature])
    if :utterance in MODALITIES
        act_config = CommunicativeActConfig(
            act_config, # Assume some Boltzmann action noise
            pragmatic_utterance_model, # Utterance model
            (domain, planner) # Domain and planner are arguments to utterance model
        )
    end
    return AgentConfig(
        domain, planner;
        # Assume fixed goal over time
        goal_config = StaticGoalConfig(goal_prior),
        # Assume the agent refines its policy at every timestep
        replan_args = (
            plan_at_init = true, # Plan at initial timestep
            prob_replan = 0, # Probability of replanning at each timestep
            prob_refine = 1.0, # Probability of refining solution at each timestep
            rand_budget = false # Search budget is fixed everytime
        ),
        act_config = act_config
    )
end

# Configure world model with agent and environment configuration
world_config = WorldConfig(
    agent_config = agent_config_prior,
    env_config = PDDLEnvConfig(domain, state),
    obs_config = PerfectObsConfig()
)

# Construct iterator over goals and cost profiles for stratified sampling
goal_addr = :init => :agent => :goal => :goal
cost_addr = :init => :agent => :goal => :cost_idx
temp_addr = :init => :agent_config => :temperature
init_strata = choiceproduct(
    (goal_addr, 1:length(goals)),
    (cost_addr, 1:length(cost_profiles)),
    (temp_addr, 1:length(ACT_TEMPERATURES))
)

## Run inference on observed actions and utterances ##

# Add do-operator around robot actions
obs_plan = map(plan) do act
    act.args[1] == pddl"(robot)" ? Plinf.do_op(act) : act
end

# Convert plan to action choicemaps
observations = act_choicemap_vec(obs_plan)
timesteps = collect(1:length(observations))

# Add utterances to choicemaps
if :utterance in MODALITIES
    # Set `speak` to false for all timesteps
    for (t, obs) in zip(timesteps, observations)
        obs[:timestep => t => :act => :speak] = false
    end
    # Add initial choice map
    init_obs = choicemap((:init => :act => :speak, false))
    pushfirst!(observations, init_obs)
    pushfirst!(timesteps, 0)
    # Constrain `speak` and `utterance` for each timestep where speech occurs
    for (t, utt) in zip(utterance_times, utterances)
        if utt[1] != ' ' # Add starting space to utterance if missing
            utt = " $utt"
        end
        if t == 0
            speak_addr = :init => :act => :speak
            utterance_addr = :init => :act => :utterance => :output
        else
            speak_addr = :timestep => t => :act => :speak
            utterance_addr = :timestep => t => :act => :utterance => :output
        end
        observations[t+1][speak_addr] = true
        observations[t+1][utterance_addr] = utt
    end
end

# Construct callback for logging data and visualizing inference
# renderer = get(renderer_dict, assist_type, RENDERER)
# callback = DKGCombinedCallback(
#     renderer, domain;
#     goal_addr = goal_addr,
#     goal_names = goal_names,
#     goal_colors = gem_colors,
#     obs_trajectory = PDDL.simulate(domain, state, plan),
#     print_goal_probs = true,
#     plot_goal_bars = false,
#     plot_goal_lines = false,
#     render = true,
#     inference_overlay = true,
#     record = false
# )

# For only data logging and printing, use these callbacks
logger_cb = DataLoggerCallback(
    t = (t, pf) -> t::Int,
    goal_probs = pf -> probvec(pf, goal_addr, 1:length(goals))::Vector{Float64},
    cost_probs = pf -> probvec(pf, cost_addr, 1:length(cost_profiles))::Vector{Float64},
    temp_probs = pf -> probvec(pf, temp_addr, 1:length(ACT_TEMPERATURES))::Vector{Float64},
    lml_est = pf -> log_ml_estimate(pf)::Float64,
)
print_cb = PrintStatsCallback(
    (goal_addr, 1:length(goals)),
    (cost_addr, 1:length(cost_profiles)),
    (temp_addr, 1:length(ACT_TEMPERATURES));
    header=("t\t" * join(goal_names, "\t") * "\t" *
            join(["C$C" for C in 1:length(cost_profiles)], "\t") * "\t" *
            join(["T=$T" for T in ACT_TEMPERATURES], "\t") * "\n")
)
callback = CombinedCallback(logger=logger_cb, print=print_cb)

# Configure SIPS particle filter
sips = SIPS(world_config, resample_cond=:none, rejuv_cond=:none)

# Run particle filter to perform online goal inference
n_samples = length(init_strata)
pf_state = sips(
    n_samples,  observations;
    init_args=(init_strata=init_strata,),
    callback=callback
);

# Extract goal probabilities
goal_probs = callback.logger.data[:goal_probs]
goal_probs = reduce(hcat, goal_probs)

# Extract cost probabilities
cost_probs = callback.logger.data[:cost_probs]
cost_probs = reduce(hcat, cost_probs)

# Extract temperature probabilities
temp_probs = callback.logger.data[:temp_probs]
temp_probs = reduce(hcat, temp_probs)

## Compute pragmatic assistance options and plans ##

true_goal_spec = MinPerAgentActionCosts(Term[true_goal], cost_profiles[1])

pragmatic_assist_results = pragmatic_assistance_offline(
    pf_state, domain, plan_end_state,
    true_goal_spec, completion, assist_obj_type;
    verbose = true, max_steps=100
)
