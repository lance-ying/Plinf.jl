using PDDL, SymbolicPlanners
using Gen, GenParticleFilters
using Plinf
using Printf
using PDDLViz, GLMakie

using GenParticleFilters: softmax

include("utils.jl")
include("plan_io.jl")
include("utterance_model.jl")
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
plan_id = "2.1.keys"

plan = PLANS[plan_id]
utterances = UTTERANCES[plan_id]
utterance_times = UTTERANCE_TIMES[plan_id]
assist_type = match(r"(\d+\w?).(\d+)\.(\w+)", plan_id).captures[3]

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

## Run literal listener inference ##

# Enumerate over robot-directed commands
actions, agents, predicates = enumerate_salient_actions(domain, state)
commands = enumerate_commands(actions, agents, predicates)
commands = lift_command.(commands, [state])
unique!(commands)

# Generate constrained trace from literal listener model
choices = choicemap((:utterance => :output, utterances[1]))
trace, _ = generate(literal_utterance_model, (domain, state, commands), choices)

# Extract unnormalized log-probabilities of utterance conditioned on each command
command_scores = extract_utterance_scores_per_command(trace)

# Compute posterior probability of each command
command_probs = softmax(command_scores)

# Sort commands by probability
perm = sortperm(command_scores, rev=true)
commands = commands[perm]
command_probs = command_probs[perm]
command_scores = command_scores[perm]
top_command = commands[1]

# Print top 5 commands and their probabilities
println("Top 5 most probable commands:")
for idx in 1:5
    command_str = repr("text/plain", commands[idx])
    @printf("%.3f: %s\n", command_probs[idx], command_str)
end

## Determine assistance options for naive literal listener ##

assist_obj_type = assist_type == "keys" ? :key : :door
cmd_planner = AStarPlanner(GoalCountHeuristic(), max_nodes=2^13)
goal_planner = AStarPlanner(GoalManhattan(), max_nodes=2^13)
plan_end_state = EndStateSimulator()(domain, state, plan)

# Extract assistance option for most probable command
top_assist_probs = zeros(length(PDDL.get_objects(state, assist_obj_type)))
top_ground_commands = ground_command(top_command, domain, state)
for cmd in top_ground_commands
    focal_objs = extract_focal_objects(cmd)
    for obj in focal_objs
        PDDL.get_objtype(state, obj) == assist_obj_type || continue
        obj_idx = findfirst(==(obj), PDDL.get_objects(state, assist_obj_type))
        top_assist_probs[obj_idx] += 1
    end
end
top_assist_probs ./= length(top_ground_commands)

# Print assistance options for most probable command
println("Assistance options for most probable command:")
for (obj, prob) in zip(PDDL.get_objects(state, assist_obj_type), top_assist_probs)
    @printf("%s : %.3f\n", obj, prob)
end

# Compute average plan completion costs for most probable command
assist_cmd_plans = Vector{Term}[]
assist_full_plans = Vector{Term}[]
for cmd in top_ground_commands
    # Compute plan that satisfies command
    cmd_goals = command_to_goals(cmd)
    cmd_goal_spec = MinActionCosts(cmd_goals, action_costs)
    cmd_sol = cmd_planner(domain, plan_end_state, cmd_goal_spec)
    if cmd_sol isa NullSolution || sol.status != :success
        continue
    end
    cmd_plan = collect(cmd_sol)
    push!(assist_cmd_plans, cmd_plan)
    # Compute remainder that satifies human's true goal
    cmd_end_state = EndStateSimulator()(domain, plan_end_state, cmd_plan)
    goal_sol = goal_planner(domain, cmd_end_state, true_goal_spec)
    if goal_sol isa NullSolution || sol.status != :success
        continue
    end
    goal_plan = collect(goal_sol)
    full_plan = vcat(cmd_plan, goal_plan)
    push!(assist_full_plans, full_plan)
end
assist_plan_lengths = length.(assist_full_plans)
mean_assist_plan_length = mean(assist_plan_lengths)
assist_human_costs = map(assist_full_plans) do plan
    filter(act -> act.args[1] == pddl"(human)", plan) |> length
end
mean_assist_human_cost = mean(assist_human_costs)

# Print average plan completion costs for most probable command
println("Average plan completion costs for most probable command:")
@printf("Mean assist plan length: %.2f\n", mean_assist_plan_length)
@printf("Mean assist human cost: %.2f\n", mean_assist_human_cost)

# Compute assistance options in expectation via systematic sampling
n_samples = 50
count = 0
u = rand() / n_samples
total_prob = 0.0
expected_assist_probs = zeros(length(PDDL.get_objects(state, assist_obj_type)))
for (cmd, prob) in zip(commands, command_probs)
    count == n_samples && break
    n_copies = 0
    total_prob += prob
    while u <= total_prob
        n_copies += 1
        count += 1
        u += 1 / n_samples
    end
    tmp_assist_probs = zeros(size(expected_assist_probs))
    g_commands = ground_command(cmd, domain, state)
    for g_cmd in g_commands
        focal_objs = extract_focal_objects(g_cmd)
        for obj in focal_objs
            PDDL.get_objtype(state, obj) == assist_obj_type || continue
            obj_idx = findfirst(==(obj), PDDL.get_objects(state, assist_obj_type))
            tmp_assist_probs[obj_idx] += 1
        end
    end
    tmp_assist_probs ./= length(g_commands)
    expected_assist_probs .+= tmp_assist_probs .* (n_copies / n_samples)
end

# Print assistance options in expectation across all commands
println("Assistance options in expectation across all commands:")
for (obj, prob) in zip(PDDL.get_objects(state, assist_obj_type), expected_assist_probs)
    @printf("%s : %.3f\n", obj, prob)
end

## Determine assistance options for efficient literal listener ##

assist_obj_type = assist_type == "keys" ? :key : :door
cmd_planner = AStarPlanner(GoalCountHeuristic(), max_nodes=2^13)
goal_planner = AStarPlanner(GoalManhattan(), max_nodes=2^13)
plan_end_state = EndStateSimulator()(domain, state, plan)

# Extract assistance option for most probable command
cmd_goals = command_to_goals(top_command)
cmd_goal_spec = MinActionCosts(cmd_goals, action_costs)
sol = cmd_planner(domain, plan_end_state, cmd_goal_spec)
top_assist_cmd_plan = collect(sol)
focal_objs = extract_focal_objects_from_plan(top_command, top_assist_plan)

top_assist_probs = zeros(length(PDDL.get_objects(state, assist_obj_type)))
for obj in focal_objs
    PDDL.get_objtype(state, obj) == assist_obj_type || continue
    obj_idx = findfirst(==(obj), PDDL.get_objects(state, assist_obj_type))
    top_assist_probs[obj_idx] += 1
end

# Print assistance options for most probable command
println("Assistance options for most probable command:")
for (obj, prob) in zip(PDDL.get_objects(state, assist_obj_type), top_assist_probs)
    @printf("%s : %.3f\n", obj, prob)
end

# Compute plan completion costs for most probable command
cmd_plan = top_assist_cmd_plan
cmd_end_state = EndStateSimulator()(domain, plan_end_state, cmd_plan)
goal_sol = goal_planner(domain, cmd_end_state, true_goal_spec)
goal_plan = collect(goal_sol)
top_assist_full_plan = vcat(cmd_plan, goal_plan)

top_assist_plan_length = length(top_assist_full_plan)
top_assist_human_cost =
    filter(act -> act.args[1] == pddl"(human)", top_assist_full_plan) |> length

# Print plan completion costs for most probable command
println("Plan completion costs for most probable command:")
@printf("Top assist plan length: %d\n", top_assist_plan_length)
@printf("Top assist human cost: %d\n", top_assist_human_cost)

# Compute assistance options in expectation via systematic sampling
n_samples = 50
count = 0
u = rand() / n_samples
total_prob = 0.0    
expected_assist_probs = zeros(length(PDDL.get_objects(state, assist_obj_type)))
for (cmd, prob) in zip(commands, command_probs)
    count == n_samples && break
    n_copies = 0
    total_prob += prob
    while u <= total_prob
        n_copies += 1
        count += 1
        u += 1 / n_samples
    end
    tmp_assist_probs = zeros(size(expected_assist_probs))
    cmd_goals = command_to_goals(cmd)
    cmd_goal_spec = MinActionCosts(cmd_goals, action_costs)
    sol = cmd_planner(domain, plan_end_state, cmd_goal_spec)
    if sol isa NullSolution || sol.status != :success
        continue
    end
    assist_cmd_plan = collect(sol)
    focal_objs = extract_focal_objects_from_plan(cmd, assist_cmd_plan)
    for obj in focal_objs
        PDDL.get_objtype(state, obj) == assist_obj_type || continue
        obj_idx = findfirst(==(obj), PDDL.get_objects(state, assist_obj_type))
        tmp_assist_probs[obj_idx] += 1
    end
    expected_assist_probs .+= tmp_assist_probs .* (n_copies / n_samples)
end

# Print assistance options in expectation across all commands
println("Assistance options in expectation across all commands:")
for (obj, prob) in zip(PDDL.get_objects(state, assist_obj_type), expected_assist_probs)
    @printf("%s : %.3f\n", obj, prob)
end

## Configure agent and world model ##

# Set options that vary across runs
ACT_TEMPERATURE = 4.0
MODALITIES = (:action, :utterance)

# Define possible goals
goals = @pddl("(has human gem1)", "(has human gem2)",
              "(has human gem3)", "(has human gem4)")
goal_idxs = collect(1:length(goals))
goal_names = ["red", "yellow", "blue", "green"]

# Define goal prior
@gen function goal_prior()
    # Sample goal index
    goal ~ uniform_discrete(1, length(goals))
    # Define action costs (TO-DO: add uncertainty over relative costs)
    costs = (
        human=(
            pickup=1.0, unlock=1.0, handover=1.0, 
            up=1.0, down=1.0, left=1.0, right=1.0, noop=0.5
        ),
        robot = (
            pickup=1.0, unlock=2.0, handover=1.0, 
            up=1.0, down=1.0, left=1.0, right=1.0, noop=0.5
        )
    )
    # Construct goal specification
    spec = MinPerAgentActionCosts(Term[goals[goal]], costs)
    return spec
end

# Construct iterator over goal choicemaps for stratified sampling
goal_addr = :init => :agent => :goal => :goal
goal_strata = choiceproduct((goal_addr, 1:length(goals)))

# Configure planner
heuristic = memoized(precomputed(GoalManhattan(), domain, state))
planner = RTHS(heuristic=heuristic, n_iters=1, max_nodes=2^16)

# Define communication and action configuration
act_config = BoltzmannActConfig(ACT_TEMPERATURE)
if :utterance in MODALITIES
    act_config = CommunicativeActConfig(
        act_config, # Assume some Boltzmann action noise
        pragmatic_utterance_model, # Utterance model
        (domain, planner) # Domain and planner are arguments to utterance model
    )
end

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
renderer = get(renderer_dict, assist_type, RENDERER)
callback = DKGCombinedCallback(
    renderer, domain;
    goal_addr = goal_addr,
    goal_names = goal_names,
    goal_colors = gem_colors,
    obs_trajectory = PDDL.simulate(domain, state, plan),
    print_goal_probs = true,
    plot_goal_bars = false,
    plot_goal_lines = false,
    render = true,
    inference_overlay = true,
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
n_samples = length(goal_strata)
pf_state = sips(
    n_samples,  observations;
    init_args=(init_strata=goal_strata,),
    callback=callback
);

# Extract goal probabilities
goal_probs = callback.logger.data[:goal_probs]
goal_probs = reduce(hcat, goal_probs)

