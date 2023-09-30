using PDDL, SymbolicPlanners
using Gen, GenParticleFilters
using Plinf
using Printf
using PDDLViz, GLMakie

using GenParticleFilters: softmax
using SymbolicPlanners: get_goal_terms, set_goal_terms

PDDL.Arrays.@register()

include("utils.jl")
include("plan_io.jl")
include("utterance_model.jl")

"""
    literal_command_inference(domain, state, utterance)

Literal listener inference for an `utterance` in a `domain` and environment 
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
    failure_cost = 100,
    cmd_planner = AStarPlanner(GoalCountHeuristic(), max_nodes=2^14),
    goal_planner = AStarPlanner(GoalManhattan(), max_nodes=2^14),
    verbose::Bool = false
)
    # Compute assistance options, averaged over possible groundings
    verbose && println("Computing assistance options...")
    assist_objs = PDDL.get_objects(state, assist_obj_type)
    assist_objs = sort!(collect(assist_objs), by=string)
    assist_option_probs = zeros(length(assist_objs))
    g_commands = ground_command(command, domain, state)
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
    for cmd in g_commands
        # Compute plan that satisfies command
        verbose && println("Planning for command: $cmd")
        cmd_goals = command_to_goals(cmd; speaker, listener)
        cmd_goal_spec = set_goal_terms(true_goal_spec, cmd_goals)
        cmd_sol = cmd_planner(domain, state, cmd_goal_spec)
        if cmd_sol isa NullSolution || cmd_sol.status != :success
            cmd_plan = Term[]
            verbose && println("No plan found.")
        else
            cmd_plan = collect(cmd_sol)
            verbose && println("Plan found: $(length(cmd_plan)) actions")
        end
        push!(assist_cmd_plans, cmd_plan)
        # Compute remainder that satifies speaker's true goal
        verbose && println("Planning for remainder...")
        cmd_end_state = isempty(cmd_plan) ?
            state : EndStateSimulator()(domain, state, cmd_plan)
        goal_sol = goal_planner(domain, cmd_end_state, true_goal_spec)
        if goal_sol isa NullSolution || goal_sol.status != :success
            goal_plan = fill(PDDL.no_op, failure_cost - length(cmd_plan))
            verbose && println("No plan found.")
        else
            goal_plan = collect(goal_sol)
            verbose && println("Plan found: $(length(goal_plan)) actions")
        end
        full_plan = Term[cmd_plan; goal_plan]
        push!(assist_full_plans, full_plan)
    end
    
    # Compute average costs of assistance plans
    verbose && println("\nComputing plan costs...")
    assist_plan_cost = mean(length.(assist_full_plans))
    if verbose
        @printf("Average plan cost: %.2f\n", assist_plan_cost)
    end
    
    return (
        assist_objs = assist_objs,
        assist_option_probs = assist_option_probs,
        plan_cost = assist_plan_cost,
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
        push!(sample_probs, prob)
    end
    assist_plan_cost = assist_plan_costs' * sample_probs
    if verbose
        println("Option probabilities:")
        for (obj, prob) in zip(assist_objs, assist_option_probs)
            @printf("  %s: %.3f\n", obj, prob)
        end
        @printf("Average plan cost: %.2f\n", assist_plan_cost)
    end
    return (
        assist_objs = assist_objs,
        assist_option_probs = assist_option_probs,
        plan_cost = assist_plan_cost,
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
    failure_cost = 100,
    cmd_planner = AStarPlanner(GoalCountHeuristic(), max_nodes=2^14),
    goal_planner = AStarPlanner(GoalManhattan(), max_nodes=2^14),
    verbose::Bool = false
)
    # Compute plan that satisfies command
    verbose && println("Planning for command: $command")
    cmd_goals = command_to_goals(command; speaker, listener)
    cmd_goal_spec = set_goal_terms(true_goal_spec, cmd_goals)
    cmd_sol = cmd_planner(domain, state, cmd_goal_spec)
    if cmd_sol isa NullSolution || cmd_sol.status != :success
        cmd_plan = Term[]
        verbose && println("No plan found.")
    else
        cmd_plan = collect(cmd_sol)
        verbose && println("Plan found: $(length(cmd_plan)) actions")
    end
    
    # Compute remainder that satifies speaker's true goal
    verbose && println("Planning for remainder...")
    cmd_end_state = isempty(cmd_plan) ?
        state : EndStateSimulator()(domain, state, cmd_plan)
    goal_sol = goal_planner(domain, cmd_end_state, true_goal_spec)
    if goal_sol isa NullSolution || goal_sol.status != :success
        goal_plan = fill(PDDL.no_op, failure_cost - length(cmd_plan))
        verbose && println("No plan found.")
    else
        goal_plan = collect(goal_sol)
        verbose && println("Plan found: $(length(goal_plan)) actions")
    end
    goal_plan = collect(goal_sol)
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
    assist_plan_cost = length(full_plan)
    if verbose
        @printf("Plan cost: %.2f\n", assist_plan_cost)
    end

    return (
        assist_objs = assist_objs,
        assist_option_probs = assist_option_probs,
        plan_cost = assist_plan_cost,
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
        push!(sample_probs, prob)
        verbose && println()
    end
    assist_plan_cost = assist_plan_costs' * sample_probs
    if verbose
        println("== Expected values ==")
        println("Option probabilities:")
        for (obj, prob) in zip(assist_objs, assist_option_probs)
            @printf("  %s: %.3f\n", obj, prob)
        end
        @printf("Plan cost: %.2f\n", assist_plan_cost)
    end
    return (
        assist_objs = assist_objs,
        assist_option_probs = assist_option_probs,
        plan_cost = assist_plan_cost,
        sampled_plan_costs = assist_plan_costs,
        sample_probs = sample_probs,
    )
end
