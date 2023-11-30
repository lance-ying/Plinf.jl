using PDDL, SymbolicPlanners
using Gen, GenParticleFilters
using Plinf
using Printf
using PDDLViz, GLMakie

using GenParticleFilters: softmax

include("utils.jl")
include("plan_io.jl")
include("utterance_model.jl")
include("inference.jl")
include("render.jl")
include("callbacks.jl")
include("scenario.jl")

PDDL.Arrays.@register()
GLMakie.activate!(inline=false)

## Load domains, problems and plans ##

# Define directory paths
# PROBLEM_DIR = joinpath(@__DIR__, "problems")
PLAN_DIR = joinpath(@__DIR__, "plans", "observed","2")
COMPLETION_DIR = joinpath(@__DIR__, "plans", "completed","2")
STIMULI_DIR = joinpath(@__DIR__, "stimuli")

# Load domain
DOMAIN = load_domain(joinpath(@__DIR__, "domain1.pddl"))

# Load problems
# PROBLEMS = Dict{String, Problem}()
# for path in readdir(PROBLEM_DIR)
#     name, ext = splitext(path)
#     ext == ".pddl" || continue
#     PROBLEMS[name] = load_problem(joinpath(PROBLEM_DIR, path))
# end

# Load utterance-annotated plans and completions
PLAN_IDS, PLANS, UTTERANCES, UTTERANCE_TIMES = load_plan_dataset(PLAN_DIR)
PLAN_IDS, COMPLETIONS, _, _ = load_plan_dataset(COMPLETION_DIR)

## Set-up for specific plan and problem ##

# Select plan and problem
plan_id = "2.5"
p = parse(Integer, plan_id[1])

plan = PLANS[plan_id]
utterances = UTTERANCES[plan_id]
utterance_times = UTTERANCE_TIMES[plan_id]

problem = load_problem(joinpath(@__DIR__, "problems/$(plan_id[1]).pddl"))

# Determine true goal from completion
completion = COMPLETIONS[plan_id]
# true_goal_obj = completion[end].args[2]
true_goal = goal_dict[pid_dict[plan_id]]

# Construct true goal specification
action_costs = (
    move=5, grab=1.2, noop=0.6
)

true_goal_spec = MinActionCosts(Term[true_goal], action_costs)

state = initstate(DOMAIN, problem)

# Compile and cache domain for faster performance
domain, state = PDDL.compiled(DOMAIN, state)
domain = CachedDomain(domain)

# Simulate plan to completion
plan_end_state = EndStateSimulator()(domain, state, plan)

## Run literal listener inference ##

# Infer distribution over commands
commands, command_probs, command_scores =
    literal_command_inference(domain, plan_end_state," "* utterances[1], verbose=true)
top_command = commands[1]


    # Enumerate over listener-directed commands
    actions, agents, predicates =
        enumerate_salient_actions(domain, state; salient_agents=[pddl"robot"])
    commands =
        enumerate_commands(actions, agents, predicates; speaker = pddl"human", listener = pddl"robot")
    # Lift commands and remove duplicates
    commands = lift_command.(commands, [state])
    unique!(commands)
    # Generate constrained trace from literal listener model
    verbose && println("Evaluating logprobs of observed utterance...")
    choices = choicemap((:utterance => :output, utterance))
    trace, _ = generate(literal_utterance_model,
                        (domain, state, commands), choices)
    # Extract unnormalized log-probabilities of utterance for each command
    command_scores = extract_utterance_scores_per_command(trace)
    # Compute posterior probability of each command
    verbose && println("Computing posterior over commands...")
    command_probs = softmax(command_scores)
    # Sort commands by posterior probability
    perm = sortperm(command_scores, rev=true)
    commands = commands[perm]
    command_probs = command_probs[perm]
    command_scores = command_scores[perm]
    # Return commands and their posterior probabilities
    return (
        commands = commands,
        probs = command_probs,
        scores = command_scores
    )

# Print top 5 commands and their probabilities
println("Top 5 most probable commands:")
for idx in 1:25
    command_str = repr("text/plain", commands[idx])
    @printf("%.3f: %s\n", command_probs[idx], command_str)
end

for idx in 1:149
    if repr("text/plain", commands[idx]) == "(grab you plate1 l) (grab you plate2 l)"
        print(idx)
    end
    # @printf("%.3f: %s\n", command_probs[idx], command_str)
end

# Compute naive assistance options and plans for top command
top_naive_assist_results = literal_assistance_naive(
    top_command, domain, plan_end_state, true_goal_spec, :item;
    verbose = true
)

# Compute expected assistance options and plans via systematic sampling
expected_naive_assist_results = literal_assistance_naive(
    commands, command_probs,
    domain, plan_end_state, true_goal_spec, :item;
    verbose = true, n_samples = 5
)

# Compute efficient assistance options and plans for top command
top_efficient_assist_results = literal_assistance_efficient(
    top_command, domain, plan_end_state, true_goal_spec, :item;
    verbose = true
)

# Compute expected assistance options and plans via systematic sampling
expected_efficient_assist_results = literal_assistance_efficient(
    commands, command_probs,
    domain, plan_end_state, true_goal_spec, :item;
    verbose = true, n_samples = 50
)

## Configure agent and world model ##

# Set options that vary across runs
ACT_TEMPERATURE = 0.5
MODALITIES = (:action, :utterance)
MODALITIES = (:action)
goal_names= [["veggie_salad","chicken_salad","chicken_stew","salmon_stew","potato_stew"],
["set_table1", "set_table2","set_table3","set_table4","set_table1b","set_table2b","set_table3b","set_table4b"],
["wine1","wine2","wine3","wine4","wine1p","wine2p","wine3p","wine4p","juice1","juice2","juice3","juice4","juice1p","juice2p","juice3p","juice4p"]]

# goals

# # Define possible goals
# goals = @pddl("(has human gem1)", "(has human gem2)",
#               "(has human gem3)", "(has human gem4)")
# goal_names = ["red", "yellow", "blue", "green"]

# Define possible cost profiles
cost_profiles = [ # Equal cost profile
    (robot = (
        move=5, grab=1.2, noop=0.6
    ),

    human = (
        move=5, grab=1, noop=0.6
    )
    ),
    (robot = (
        move=5, grab=1, noop=0.6
    ),
    
    human = (
        move=5, grab=1, noop=0.6
    )
    ),
    (robot = (
        move=5, grab=1, noop=0.6
    ),
    
    human = (
        move=5, grab=10, noop=0.6
    )),
]    

# Define goal prior
@gen function goal_prior()
    # Sample goal index
    goal ~ uniform_discrete(1, length(goals[p]))
    # Sample action costs
    cost_idx ~ uniform_discrete(1, length(cost_profiles))
    costs = cost_profiles[cost_idx]
    # Construct goal specification
    spec = MinPerAgentActionCosts(Term[goals[p][goal]], costs)
    return spec
end

# Construct iterator over goals and cost profiles for stratified sampling
goal_addr = :init => :agent => :goal => :goal
cost_addr = :init => :agent => :goal => :cost_idx
init_strata = choiceproduct((goal_addr, 1:length(goals[p])),
                            (cost_addr, 1:length(cost_profiles)))

# Configure planner
heuristic = memoized(precomputed(FFHeuristic(), domain, state))
# planner = RTDP(heuristic=heuristic, n_rollouts=0)
planner = RTHS(heuristic=heuristic, n_iters=0, max_nodes=1000)

ACT_TEMPERATURE =0.1
# Define communication and action configuration
act_config = BoltzmannActConfig(ACT_TEMPERATURE)
# if :utterance in MODALITIES
#     act_config = CommunicativeActConfig(
#         act_config, # Assume some Boltzmann action noise
#         pragmatic_utterance_model, # Utterance model
#         (domain, planner) # Domain and planner are arguments to utterance model
#     )
# end

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
    act_config = act_config
)

# Configure world model with agent and environment configuration
world_config = WorldConfig(
    agent_config = agent_config,
    env_config = PDDLEnvConfig(domain, state),
    obs_config = PerfectObsConfig()
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
callback = DKGCombinedCallback(
    renderer, domain;
    goal_addr = goal_addr,
    goal_names = goal_names[p],
    obs_trajectory = PDDL.simulate(domain, state, plan),
    print_goal_probs = true,
    plot_goal_bars = false,
    plot_goal_lines = false,
    render = false,
    inference_overlay = false,
    record = false
)

# For only data logging and printing, use these callbacks
# logger_cb = DataLoggerCallback(
#     t = (t, pf) -> t::Int,
#     goal_probs = pf -> probvec(pf, goal_addr, 1:n_goals)::Vector{Float64},
#     lml_est = pf -> log_ml_estimate(pf)::Float64,
# )
# print_cb = PrintStatsCallback(
#     (goal_addr, 1:n_goals);
#     header="t\t" * join(goal_names, "\t") * "\n"
# )
# callback = CombinedCallback(logger=logger_cb, print=print_cb)

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
# cost_probs = callback.logger.data[:cost_probs]
# cost_probs = reduce(hcat, cost_probs)

## Compute pragmatic assistance options and plans ##

pragmatic_assist_results = pragmatic_assistance_offline(
    pf_state, domain, plan_end_state, true_goal_spec, :item;
    act_temperature = ACT_TEMPERATURE, verbose = true
)
