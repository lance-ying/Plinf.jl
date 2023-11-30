using PDDL, SymbolicPlanners
using Gen, GenParticleFilters
using Plinf
using Printf
using PDDLViz, GLMakie

using GenParticleFilters: softmax
using SymbolicPlanners: get_goal_terms, set_goal_terms

PDDL.Arrays.@register()

include("utils.jl")
# include("heuristics.jl")
include("plan_io.jl")
include("utterance_model.jl")

## Literal Assistant ##

"""
    literal_command_inference(domain, state, utterance)

Runs literal listener inference for an `utterance` in a `domain` and environment 
`state`. Returns a distribution over listener-directed commands that could
have led to the utterance.
"""
function literal_command_inference(
    domain::Domain, state::State, utterance::String;
    speaker = pddl"(human)",
    listener = pddl"(robot)",
    verbose::Bool = false
)
    # Enumerate over listener-directed commands
    verbose && println("Enumerating commands...")
    actions, agents, predicates =
        enumerate_salient_actions(domain, state; salient_agents=[listener])
    commands =
        enumerate_commands(actions, agents, predicates; speaker, listener)
    # Lift commands and remove duplicates
    commands = lift_command.(commands, [state])
    unique!(commands)
    # Add starting space to utterance if it doesn't have one
    if utterance[1] != ' '
        utterance = " $utterance"
    end
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
end

"""
    literal_assistance_naive(command, domain, state, true_goal_spec,
                             assist_obj_type; kwargs...)

Naive literal assistance model for a lifted `command` in a `domain` and
environment `state`. Computes the distribution over assistance options,
distribution over assistive plans, and the expected cost of those plans.

Assistance is naive, because it assumes that each valid grounding of the 
lifed `command` is equally likely, instead of finding the most efficient 
way of satisfying the command.
"""
function literal_assistance_naive(
    command::ActionCommand,
    domain::Domain, state::State,
    true_goal_spec::Specification,
    assist_obj_type::Symbol;
    speaker = pddl"(human)",
    listener = pddl"(robot)",
    max_steps = 100,
    cmd_planner = AStarPlanner(FFHeuristic(), max_nodes=2000),
    goal_planner = AStarPlanner(FFHeuristic(), max_nodes=2000),
    verbose::Bool = false
)
    # Compute assistance options, averaged over possible groundings
    verbose && println("Computing assistance options...")
    assist_objs = PDDL.get_objects(state, assist_obj_type)
    assist_objs = sort!(collect(assist_objs), by=string)
    # print(assist_objs)
    assist_option_probs = zeros(length(assist_objs))
    g_commands = ground_command(command, domain, state)
    print(g_commands)
    for cmd in g_commands
        focal_objs = extract_focal_objects(cmd)
        for obj in focal_objs
            PDDL.get_objtype(state, obj) == assist_obj_type || continue
            obj_idx = findfirst(==(obj), assist_objs)
            assist_option_probs[obj_idx] += 1
        end
    end
    assist_option_probs ./= length(g_commands)
    if verbose
        println("Option probabilities:")
        for (obj, prob) in zip(assist_objs, assist_option_probs)
            @printf("  %s: %.3f\n", obj, prob)
        end
        println()
    end

    # Compute assistance plans
    verbose && println("Computing assistance plans...")
    assist_cmd_plans = Vector{Term}[]
    assist_full_plans = Vector{Term}[]
    cmd_successes = Bool[]
    goal_successes = Bool[]
    for cmd in g_commands
        # Compute plan that satisfies command
        verbose && println("Planning for command: $cmd")
        if !is_command_possible(cmd, domain, state)
            verbose && println("Command is impossible to satisfy.")
            cmd_plan = Term[]
            full_plan = fill(PDDL.no_op, max_steps)
            push!(assist_cmd_plans, cmd_plan)
            push!(assist_full_plans, full_plan)
            push!(cmd_successes, false)
            push!(goal_successes, false)
            continue
        end
        cmd_goals = command_to_goals(cmd; speaker, listener)
        cmd_goal_spec = set_goal_terms(true_goal_spec, cmd_goals)
        cmd_plan = nothing
        cmd_success = false
        for trial in (true) # Try with and without freezing speaker
            verbose && println("Speaker is frozen: $trial")
            tmp_state = copy(state)
            tmp_state[Compound(:frozen, Term[speaker])] = trial
            cmd_sol = cmd_planner(domain, tmp_state, cmd_goal_spec)
            if cmd_sol isa NullSolution || cmd_sol.status != :success
                cmd_plan = Term[]
                verbose && println("No plan found.")
            else
                cmd_plan = collect(cmd_sol)
                cmd_success = true
                verbose && println("Plan found: $(length(cmd_plan)) actions")
                break
            end
        end
        push!(assist_cmd_plans, cmd_plan)
        push!(cmd_successes, cmd_success)
        # Compute remainder that satifies speaker's true goal, freezing listener
        verbose && println("Planning for remainder...")
        cmd_end_state = isempty(cmd_plan) ?
            copy(state) : EndStateSimulator()(domain, state, cmd_plan)
        cmd_end_state[Compound(:frozen, Term[listener])] = true
        # print(true_goal_spec)
        goal_sol = goal_planner(domain, cmd_end_state, true_goal_spec)
        if goal_sol isa NullSolution || goal_sol.status != :success
            goal_plan = fill(PDDL.no_op, max_steps - length(cmd_plan))
            goal_success = false
            verbose && println("No plan found.")
        else
            goal_plan = collect(goal_sol)
            goal_success = true
            verbose && println("Plan found: $(length(goal_plan)) actions")
        end
        push!(goal_successes, goal_success)
        full_plan = Term[cmd_plan; goal_plan]
        push!(assist_full_plans, full_plan)
    end
    
    # Compute average costs of assistance plans
    verbose && println("\nComputing plan costs...")
    assist_plan_cost = min(mean(length.(assist_full_plans)), max_steps)
    assist_move_cost = map(assist_full_plans) do plan
        map(plan) do act
            act == PDDL.no_op && return 0.5
            act.name == :no_op && return 0.0
            act.args[1] == listener && return 0.0
            return 1.0
        end |> sum
    end |> mean
    cmd_success_rate = mean(cmd_successes)
    goal_success_rate = mean(goal_successes)
    if verbose
        @printf("Average plan cost: %.2f\n", assist_plan_cost)
        @printf("Average speaker move cost: %.2f\n", assist_move_cost)
        @printf("Command success rate: %.2f\n", cmd_success_rate)
        @printf("Goal success rate: %.2f\n", goal_success_rate)
    end
    
    return (
        assist_objs = assist_objs,
        assist_option_probs = assist_option_probs,
        plan_cost = assist_plan_cost,
        move_cost = assist_move_cost,
        cmd_success = cmd_success_rate,
        goal_success = goal_success_rate,
        cmd_plans = assist_cmd_plans,
        full_plans = assist_full_plans,
    )
end

"""
    literal_assistance_naive(commands, probs, domain, state, true_goal_spec,
                             assist_obj_type; n_samples=50, kwargs...)

Naive literal assistance model for a distribution of lifted `commands` in a
`domain` and environment `state`. Uses systematic sampling with `n_samples` 
to compute the expected distribution over assistance options and the expected
cost of the assistive plans.
"""
function literal_assistance_naive(
    commands::AbstractVector{ActionCommand},
    probs::AbstractVector{<:Real},
    domain::Domain, state::State,
    true_goal_spec::Specification,
    assist_obj_type::Symbol;
    n_samples::Int = 50,
    verbose = false,
    kwargs...
)
    # Set up containers
    assist_objs = PDDL.get_objects(state, assist_obj_type)
    assist_objs = sort!(collect(assist_objs), by=string)
    assist_option_probs = zeros(length(assist_objs))
    assist_plan_costs = Float64[]
    assist_move_costs = Float64[]
    cmd_success_rates = Float64[]
    goal_success_rates = Float64[]
    sample_probs = Float64[]
    verbose && println("Computing expected values via systematic sampling...")
    # Compute expected assistance options and costs via systematic sampling
    sys_sample_map!(commands, probs, n_samples) do command, prob
        verbose && println("Sampling command: $command")
        result = literal_assistance_naive(
            command, domain, state, true_goal_spec,
            assist_obj_type; verbose, kwargs...
        )
        assist_option_probs .+= result.assist_option_probs .* prob
        push!(assist_plan_costs, result.plan_cost)
        push!(assist_move_costs, result.move_cost)
        push!(cmd_success_rates, result.cmd_success)
        push!(goal_success_rates, result.goal_success)
        push!(sample_probs, prob)
    end
    assist_plan_cost = assist_plan_costs' * sample_probs
    assist_move_cost = assist_move_costs' * sample_probs
    cmd_success_rate = cmd_success_rates' * sample_probs
    goal_success_rate = goal_success_rates' * sample_probs
    if verbose
        println("Option probabilities:")
        for (obj, prob) in zip(assist_objs, assist_option_probs)
            @printf("  %s: %.3f\n", obj, prob)
        end
        @printf("Average plan cost: %.2f\n", assist_plan_cost)
        @printf("Average speaker move cost: %.2f\n", assist_move_cost)
        @printf("Command success rate: %.2f\n", cmd_success_rate)
        @printf("Goal success rate: %.2f\n", goal_success_rate)
    end
    return (
        assist_objs = assist_objs,
        assist_option_probs = assist_option_probs,
        plan_cost = assist_plan_cost,
        move_cost = assist_move_cost,
        cmd_success = cmd_success_rate,
        goal_success = goal_success_rate,
        sampled_plan_costs = assist_plan_costs,
        sample_probs = sample_probs,
    )
end

"""
    literal_assistance_efficient(command, domain, state, true_goal_spec,
                                 assist_obj_type; kwargs...)

Efficient literal assistance model for a lifted `command` in a `domain` and
environment `state`. Computes the distribution over assistance options,
distribution over assistive plans, and the expected cost of those plans.

Assistance is efficient because it finds the most efficient way of satisfying
the lifted `command`. 
"""
function literal_assistance_efficient(
    command::ActionCommand,
    domain::Domain, state::State,
    true_goal_spec::Specification,
    assist_obj_type::Symbol;
    speaker = pddl"(human)",
    listener = pddl"(robot)",
    max_steps = 100,
    cmd_planner = AStarPlanner(FFHeuristic(), max_nodes=2000),
    goal_planner = AStarPlanner(FFHeuristic(), max_nodes=2000),
    verbose::Bool = false
)
    # Compute plan that satisfies command
    verbose && println("Planning for command: $command")
    cmd_goals = command_to_goals(command; speaker, listener)
    cmd_goal_spec = set_goal_terms(true_goal_spec, cmd_goals)
    cmd_plan = nothing
    cmd_success = false
    for trial in (true) # Try planning with speaker frozen and unfrozen
        verbose && println("Speaker is frozen: $trial")
        tmp_state = copy(state)
        tmp_state[Compound(:frozen, Term[speaker])] = trial
        cmd_sol = cmd_planner(domain, tmp_state, cmd_goal_spec)
        if cmd_sol isa NullSolution || cmd_sol.status != :success
            cmd_plan = Term[]
            verbose && println("No plan found.")
        else
            cmd_plan = collect(cmd_sol)
            cmd_success = true
            verbose && println("Plan found: $(length(cmd_plan)) actions")
            break
        end
    end
    
    # Compute remainder that satifies speaker's true goal, freezing listener
    verbose && println("Planning for remainder...")
    cmd_end_state = isempty(cmd_plan) ?
        copy(state) : EndStateSimulator()(domain, state, cmd_plan)
    cmd_end_state[Compound(:frozen, Term[listener])] = true
    goal_sol = goal_planner(domain, cmd_end_state, true_goal_spec)
    if goal_sol isa NullSolution || goal_sol.status != :success
        goal_plan = fill(PDDL.no_op, max_steps - length(cmd_plan))
        goal_success = false
        verbose && println("No plan found.")
    else
        goal_plan = collect(goal_sol)
        goal_success = true
        verbose && println("Plan found: $(length(goal_plan)) actions")
    end
    full_plan = Term[cmd_plan; goal_plan]
    verbose && println()
    
    # Compute assistance options
    verbose && println("Computing assistance options...")
    assist_objs = PDDL.get_objects(state, assist_obj_type)
    assist_objs = sort!(collect(assist_objs), by=string)
    assist_option_probs = zeros(length(assist_objs))
    focal_objs = extract_focal_objects_from_plan(command, cmd_plan)
    for obj in focal_objs
        PDDL.get_objtype(state, obj) == assist_obj_type || continue
        obj_idx = findfirst(==(obj), assist_objs)
        assist_option_probs[obj_idx] += 1
    end
    if verbose
        println("Option probabilities:")
        for (obj, prob) in zip(assist_objs, assist_option_probs)
            @printf("  %s: %.3f\n", obj, prob)
        end
        println()
    end

    # Compute costs of assistance plans
    verbose && println("Computing plan cost...")
    assist_plan_cost = min(length(full_plan), max_steps)
    assist_move_cost = map(full_plan) do act
        act == PDDL.no_op && return 0.5
        act.name == :no_op && return 0.0
        act.args[1] == listener && return 0.0
        return 1.0
    end |> sum
    if verbose
        @printf("Plan cost: %.2f\n", assist_plan_cost)
        @printf("Speaker move cost: %.2f\n", assist_move_cost)
        @printf("Command success: %s\n", cmd_success)
        @printf("Goal success: %s\n", goal_success)
    end

    return (
        assist_objs = assist_objs,
        assist_option_probs = assist_option_probs,
        plan_cost = assist_plan_cost,
        move_cost = assist_move_cost,
        cmd_success = float(cmd_success),
        goal_success = float(goal_success),
        cmd_plan = cmd_plan,
        full_plan = full_plan
    )
end

"""
    literal_assistance_efficient(commands, probs, domain, state, true_goal_spec,
                                 assist_obj_type; n_samples=50, kwargs...)

Efficient literal assistance model for a distribution of lifted `commands` in a
`domain` and environment `state`. Uses systematic sampling with `n_samples`
to compute the expected distribution over assistance options and the expected
cost of the assistive plans.
"""
function literal_assistance_efficient(
    commands::AbstractVector{ActionCommand},
    probs::AbstractVector{<:Real},
    domain::Domain, state::State,
    true_goal_spec::Specification,
    assist_obj_type::Symbol;
    n_samples::Int = 50,
    verbose = false,
    kwargs...
)
    # Set up containers
    assist_objs = PDDL.get_objects(state, assist_obj_type)
    assist_objs = sort!(collect(assist_objs), by=string)
    assist_option_probs = zeros(length(assist_objs))
    assist_plan_costs = Float64[]
    assist_move_costs = Float64[]
    cmd_success_rates = Float64[]
    goal_success_rates = Float64[]
    sample_probs = Float64[]
    # Compute expected assistance options and costs via systematic sampling
    verbose && println("Computing expected values via systematic sampling...")
    sys_sample_map!(commands, probs, n_samples) do command, prob
        verbose && println("Sampling command: $command")
        result = literal_assistance_efficient(
            command, domain, state, true_goal_spec,
            assist_obj_type; verbose, kwargs...
        )
        assist_option_probs .+= result.assist_option_probs .* prob
        push!(assist_plan_costs, result.plan_cost)
        push!(assist_move_costs, result.move_cost)
        push!(cmd_success_rates, result.cmd_success)
        push!(goal_success_rates, result.goal_success)
        push!(sample_probs, prob)
        verbose && println()
    end
    assist_plan_cost = assist_plan_costs' * sample_probs
    assist_move_cost = assist_move_costs' * sample_probs
    cmd_success_rate = cmd_success_rates' * sample_probs
    goal_success_rate = goal_success_rates' * sample_probs
    if verbose
        println("== Expected values ==")
        println("Option probabilities:")
        for (obj, prob) in zip(assist_objs, assist_option_probs)
            @printf("  %s: %.3f\n", obj, prob)
        end
        @printf("Plan cost: %.2f\n", assist_plan_cost)
        @printf("Speaker move cost: %.2f\n", assist_move_cost)
        @printf("Command success rate: %.2f\n", cmd_success_rate)
        @printf("Goal success rate: %.2f\n", goal_success_rate)
    end
    return (
        assist_objs = assist_objs,
        assist_option_probs = assist_option_probs,
        plan_cost = assist_plan_cost,
        move_cost = assist_move_cost,
        cmd_success = cmd_success_rate,
        goal_success = goal_success_rate,
        sampled_plan_costs = assist_plan_costs,
        sample_probs = sample_probs,
    )
end

## Pragmatic Assistant ##

"""
    configure_pragmatic_speaker_model(
        domain, state, goals, cost_profiles;
        act_temperature = 1.0,
        modalities = (:utterance, :action),
        max_nodes = 2^16
    )

Configure the listener / assistant's model of the speaker / human principal.
"""
function configure_pragmatic_speaker_model(
    domain::Domain, state::State,
    goals::AbstractVector{<:Term},
    cost_profiles;
    act_temperature = 1.0,
    modalities = (:utterance, :action),
    max_nodes = 2^16,
    kwargs...
)
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
    heuristic = memoized(precomputed(FFHeuristic(), domain, state))
    planner = RTHS(heuristic=heuristic, n_iters=0, max_nodes=1000)

    # Define communication and action configuration
    act_config = BoltzmannActConfig(act_temperature)
    if :utterance in modalities
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
            plan_at_init = true, # Plan at initial timestep
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

    return world_config
end

"""
    pragmatic_goal_inference(
        model_config, n_goals, n_costs,
        actions, utterances, utterance_times;
        modalities = (:utterance, :action),
        verbose = false,
        kwargs...
    )

Runs online pragmatic goal inference problem defined by `model_config` and the 
observed `actions` and `utterances`. Returns the particle filter state, the
distribution over goals, the distribution over cost profiles, and the log
marginal likelihood estimate of the data.
"""
function pragmatic_goal_inference(
    model_config::WorldConfig,
    n_goals::Int, n_costs::Int,
    actions::AbstractVector{<:Term},
    utterances::AbstractVector{String},
    utterance_times::AbstractVector{Int};
    speaker = pddl"(human)",
    listener = pddl"(robot)",
    modalities = (:utterance, :action),
    verbose = false,
    goal_names = ["gem$i" for i in 1:n_goals],
    kwargs...
)
    # Add do-operator to listener actions (all actions for utterance-only model)
    obs_actions = map(actions) do act
        :action ∉ modalities || act.args[1] == listener ? Plinf.do_op(act) : act
    end
    # Convert plan to action choicemaps
    observations = act_choicemap_vec(obs_actions)
    timesteps = collect(1:length(observations))
    # Construct selection containing all action addresses
    action_sel = Gen.select()
    for t in timesteps
        push!(action_sel, :timestep => t => :act => :act)
    end
    # Add utterances to choicemaps
    utterance_sel = Gen.select()
    if :utterance in modalities
        # Set `speak` to false for all timesteps
        for (t, obs) in zip(timesteps, observations)
            obs[:timestep => t => :act => :speak] = false
        end
        # Add initial choice map
        init_obs = choicemap((:init => :act => :speak, false))
        pushfirst!(observations, init_obs)
        pushfirst!(timesteps, 0)
        # Constrain `speak` and `utterance` for each step where speech occurs
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
            push!(utterance_sel, speak_addr)
            push!(utterance_sel, utterance_addr)
        end
    end

    # Construct iterator over goals and cost profiles for stratified sampling
    goal_addr = :init => :agent => :goal => :goal
    cost_addr = :init => :agent => :goal => :cost_idx
    init_strata = choiceproduct((goal_addr, 1:n_goals),
                                (cost_addr, 1:n_costs))

    # Construct logging and printing callbacks
    logger_cb = DataLoggerCallback(
        t = (t, pf) -> t::Int,
        goal_probs = pf -> probvec(pf, goal_addr, 1:n_goals)::Vector{Float64},
        cost_probs = pf -> probvec(pf, cost_addr, 1:n_costs)::Vector{Float64},
        lml_est = pf -> log_ml_estimate(pf)::Float64,
        action_goal_probs = pf -> begin
            tr_scores = map(pf.traces) do trace
                project(trace, action_sel)
            end
            tr_probs = softmax(tr_scores)
            probs = zeros(n_goals)
            for (idx, tr) in enumerate(pf.traces)
                goal = tr[goal_addr]
                probs[goal] += tr_probs[idx]
            end
            return probs
        end,
        utterance_goal_probs = pf -> begin
            tr_scores = map(pf.traces) do trace
                project(trace, utterance_sel)
            end
            tr_probs = softmax(tr_scores)
            probs = zeros(n_goals)
            for (idx, tr) in enumerate(pf.traces)
                goal = tr[goal_addr]
                probs[goal] += tr_probs[idx]
            end
            return probs
        end
    )
    print_cb = PrintStatsCallback(
        (goal_addr, 1:n_goals);
        header="t\t" * join(goal_names, "\t") * "\n"
    )
    if verbose
        callback = CombinedCallback(logger=logger_cb, print=print_cb)
    else
        callback = CombinedCallback(logger=logger_cb)
    end

    # Configure SIPS particle filter
    sips = SIPS(model_config, resample_cond=:none, rejuv_cond=:none)
    # Run particle filter to perform online goal inference
    n_samples = length(init_strata)
    pf_state = sips(
        n_samples,  observations;
        init_args=(init_strata=init_strata,),
        callback=callback
    );

    # Extract logged data
    goal_probs_history = callback.logger.data[:goal_probs]
    goal_probs_history = reduce(hcat, goal_probs_history)
    goal_probs = goal_probs_history[:, end]
    cost_probs_history = callback.logger.data[:cost_probs]
    cost_probs_history = reduce(hcat, cost_probs_history)
    cost_probs = cost_probs_history[:, end]
    lml_est_history = callback.logger.data[:lml_est]
    lml_est = lml_est_history[end]
    action_goal_probs_history = callback.logger.data[:action_goal_probs]
    action_goal_probs_history = reduce(hcat, action_goal_probs_history)
    action_goal_probs = action_goal_probs_history[:, end]
    utterance_goal_probs_history = callback.logger.data[:utterance_goal_probs]
    utterance_goal_probs_history = reduce(hcat, utterance_goal_probs_history)
    utterance_goal_probs = utterance_goal_probs_history[:, end]

    # Extract trace scores for specific modalities
    action_trace_scores = map(pf_state.traces) do trace
        project(trace, action_sel)
    end
    utterance_trace_scores = map(pf_state.traces) do trace
        project(trace, utterance_sel)
    end

    return (
        pf = pf_state,
        goal_probs = goal_probs,
        cost_probs = cost_probs,
        action_goal_probs = action_goal_probs,
        utterance_goal_probs = utterance_goal_probs,
        action_trace_scores = action_trace_scores,
        utterance_trace_scores = utterance_trace_scores,
        lml_est = lml_est,
        goal_probs_history = goal_probs_history,
        cost_probs_history = cost_probs_history,
        action_goal_probs_history = action_goal_probs_history,
        utterance_goal_probs_history = utterance_goal_probs_history,
        lml_est_history = lml_est_history
    )
end

function pragmatic_goal_inference(
    domain::Domain, state::State, goals::Vector{Term}, cost_profiles,
    actions::AbstractVector{<:Term},
    utterances::AbstractVector{String},
    utterance_times::AbstractVector{Int};
    kwargs...
)
    # Configure speaker model
    model_config = configure_pragmatic_speaker_model(
        domain, state, goals, cost_profiles; kwargs...
    )
    # Run goal inference
    return pragmatic_goal_inference(
        model_config, length(goals), length(cost_profiles),
        actions, utterances, utterance_times; kwargs...
    )
end

"""
    pragmatic_assistance_offline(pf, domain, state, true_goal_spec,
                                 assist_obj_type; kwargs...)

Offline pragmatic assistance model, given a particle filter belief state (`pf`)
in a `domain` and environment `state`. Simulates the best action to take at
each timestep via expected cost minimization, where the expectation is taken
over goal specifications. Returns the distribution over assistance options,
the assistive plan, and the expected cost of that plan.

Assistance is offline, because the assistant plans ahead based on its current 
belief about the speaker's goal, instead of updating its belief as it observes
the speaker's actions.
"""
function pragmatic_assistance_offline(
    pf::ParticleFilterState,
    domain::Domain, state::State,
    true_goal_spec::Specification,
    assist_obj_type::Symbol;
    speaker = pddl"(human)",
    listener = pddl"(robot)",
    act_temperature = 1.0,
    max_steps::Int = 100,
    p_thresh::Float64 = 0.001,
    verbose::Bool = false
)
    # Extract probabilities, specifications and policies from particle filter
    start_t = Plinf.get_model_timestep(pf)
    model_config = Gen.get_args(pf.traces[1])[2]
    probs = get_norm_weights(pf)
    goal_specs = map(pf.traces) do trace
        trace[:init => :agent => :goal]
    end
    policies = map(pf.traces) do trace
        if start_t == 0
            copy(trace[:init => :agent => :plan].sol)
        else
            copy(trace[:timestep => start_t => :agent => :plan].sol)
        end
    end
    heuristic = memoized(FFHeuristic())
    planner = RTHS(heuristic=heuristic, n_iters=0, max_nodes=2000)
    
    # Iteratively take action that minimizes expected goal achievement cost
    verbose && println("Planning future actions via pragmatic assistance...")
    assist_plan = Term[]
    for t in (start_t+1):max_steps
        # Refine policies for each goal, starting from current state
        for (prob, policy, spec) in zip(probs, policies, goal_specs)
            prob < p_thresh && continue # Ignore low-probability goals
            policy = refine!(policy, planner, domain, state, spec)
        end
        # Compute Q-values / probabilities for each action
        act_priorities = Dict{Term, Float64}()
        for act in available(domain, state)
            next_state = transition(domain, state, act)
            act_priorities[act] = 0.0
            agent = act.args[1]
            no_op = Compound(:noop, Term[agent])
            # Compute expected value / probability of action across goals
            for (prob, policy, spec) in zip(probs, policies, goal_specs)
                prob < p_thresh && continue # Ignore low-probability goals
                if agent == listener
                    # Compute expected value of listener actions
                    val = SymbolicPlanners.get_value(policy, state, act)
                    if val == -Inf # Handle irreversible failures
                        noop_cost = get_cost(spec, domain, state, no_op, state)
                        act_cost = get_cost(spec, domain, state, act, next_state)
                        val = -((max_steps - t) * noop_cost + act_cost)
                    end
                elseif get_goal_terms(true_goal_spec) == get_goal_terms(spec)
                    # Compute probability of speaker actions under true goal
                    b_policy = BoltzmannPolicy(policy, act_temperature)
                    val = SymbolicPlanners.get_action_prob(b_policy, state, act)
                else
                    val = 0.0
                end
                act_priorities[act] += prob * val
            end
        end
        # Take action with highest priority
        act = argmax(act_priorities)
        push!(assist_plan, act)
        state = transition(domain, state, act)
        verbose && println("$(t-start_t)\t$(write_pddl(act))")
        # Check if goal is satisfied
        if is_goal(true_goal_spec, domain, state)
            verbose && println("Goal satisfied at timestep $(t-start_t).")
            break
        end
        # Check if last two actions were no-ops
        if (length(assist_plan) >= 2 &&
            assist_plan[end].name == :noop && assist_plan[end-1].name == :noop)
            # Fill remaining plan with no-ops
            while length(assist_plan) < (max_steps - start_t)
                append!(assist_plan, assist_plan[end-1:end])
            end
            assist_plan = assist_plan[1:max_steps-start_t]
            verbose && println("No-op loop detected, terminating early.")
            break
        end
    end
    assist_plan_cost = length(assist_plan)
    assist_move_cost = map(assist_plan) do act
        act == PDDL.no_op && return 0.5
        act.name == :no_op && return 0.0
        act.args[1] == listener && return 0.0
        return 1.0
    end |> sum
    if verbose
        @printf("Plan cost: %d\n", assist_plan_cost)
        @printf("Speaker move cost: %d\n", assist_move_cost)
    end
    
    # Extract assistance options
    verbose && println("\nExtracting assistance options...")
    assist_objs = PDDL.get_objects(state, assist_obj_type)
    assist_objs = sort!(collect(assist_objs), by=string)
    assist_option_probs = zeros(length(assist_objs))
    listener_plan = filter(act -> act.args[1] == listener, assist_plan)
    focal_objs = extract_focal_objects(listener_plan)
    for obj in focal_objs
        PDDL.get_objtype(state, obj) == assist_obj_type || continue
        obj_idx = findfirst(==(obj), assist_objs)
        assist_option_probs[obj_idx] += 1
    end
    if verbose
        println("Option probabilities:")
        for (obj, prob) in zip(assist_objs, assist_option_probs)
            @printf("  %s: %.3f\n", obj, prob)
        end
        println()
    end

    return (
        assist_objs = assist_objs,
        assist_option_probs = assist_option_probs,
        plan_cost = assist_plan_cost,
        move_cost = assist_move_cost,
        full_plan = assist_plan        
    )
end
