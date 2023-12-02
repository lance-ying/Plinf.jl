using PDDL, SymbolicPlanners
using Gen, GenParticleFilters
using Plinf
using Printf
using CSV, DataFrames
using Dates

using GenParticleFilters: softmax

include("utils.jl")
include("plan_io.jl")
include("utterance_model.jl")
include("inference.jl")
include("scenario copy.jl")

PDDL.Arrays.@register()

## Load domains, problems and plans ##

# Define directory paths
PROBLEM_DIR = joinpath(@__DIR__, "problems")
PLAN_DIR = joinpath(@__DIR__, "plans", "observed","2")
COMPLETION_DIR = joinpath(@__DIR__, "plans", "completed","2")
STIMULI_DIR = joinpath(@__DIR__, "stimuli")

# Load domain
DOMAIN = load_domain(joinpath(@__DIR__, "domain1.pddl"))
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

## Define parameters ##

# Possible goals
GOALS = goals[2]

# Possible cost profiles
COST_PROFILES = [ # Equal cost profile
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

# Boltzmann action temperatures
ACT_TEMPERATURES = [0.2]

# Possible modalities
MODALITIES = [
    (:action,),
    (:utterance,),
    (:action, :utterance),
]

# Maximum number of steps before time is up

MAX_STEPS = 100

# Number of samples for systematic sampling
N_LITERAL_NAIVE_SAMPLES = 10
N_LITERAL_EFFICIENT_SAMPLES = 10

# Whether to run literal or pragmatic inference
RUN_LITERAL = true
RUN_PRAGMATIC = true

## Run experiments ##

df = DataFrame(
    # Plan info
    plan_id = String[],
    problem_id = String[],
    assist_type = String[],
    true_goal = String[],
    # Method info
    infer_method = String[],
    assist_method = String[],
    estim_type = String[],
    modalities = String[],
    act_temperature = Float64[],
    # Inference results
    goal_probs_1 = Float64[],
    goal_probs_2 = Float64[],
    goal_probs_3 = Float64[],
    goal_probs_4 = Float64[],
    goal_probs_5 = Float64[],
    goal_probs_6 = Float64[],
    goal_probs_7 = Float64[],
    goal_probs_8 = Float64[],
    goal_probs_9 = Float64[],
    goal_probs_10 = Float64[],
    goal_probs_11 = Float64[],
    goal_probs_12 = Float64[],
    true_goal_probs = Float64[],
    brier_score = Float64[],
    lml_est = Float64[],
    # Assistance results
    top_command = String[],
    assist_probs_1 = Float64[],
    assist_probs_2 = Float64[],
    assist_probs_3 = Float64[],
    assist_probs_4 = Float64[],
    assist_probs_5 = Float64[],
    assist_probs_6 = Float64[],
    assist_probs_7 = Float64[],
    assist_probs_8 = Float64[],
    assist_probs_9 = Float64[],
    assist_probs_10 = Float64[],
    assist_probs_11 = Float64[],
    assist_probs_12 = Float64[],
    assist_probs_13 = Float64[],
    assist_probs_14 = Float64[],
    assist_probs_15 = Float64[],
    assist_probs_16 = Float64[],
    assist_plan = String[],
    assist_plan_cost = Float64[]
)
datetime = Dates.format(Dates.now(), "yyyy-mm-ddTHH-MM-SS")
df_path = "experiments_1.csv"
df_path = joinpath(@__DIR__, df_path)

# Iterate over plans
for plan_id in PLAN_IDS[1:end]
    println("=== Plan $plan_id ===")
    # Load plan and problem
    plan = PLANS[plan_id]
    utterances = UTTERANCES[plan_id]
    utterance_times = UTTERANCE_TIMES[plan_id]
    println(utterances)

    assist_type = "items"
    assist_obj_type = :item

    problem_id = match(r"(\d+?).(\d+)", plan_id).captures[1]
    problem = PROBLEMS[problem_id]

    # Determine true goal from completion
    completion = COMPLETIONS[plan_id]
    true_goal_obj = completion[end].args[2]
    true_goal = goal_dict[pid_dict[plan_id]]
    # print(true_goal)

    # Construct true goal specification
    action_costs = (
    move=5, grab=1.2, noop=0.6
)
    true_goal_spec = MinActionCosts(Term[true_goal], action_costs)

    # print(true_goal_spec)

    cost_profiles = COST_PROFILES
    # Sellect cost profiles based on assistance type

    # Compile domain for problem
    domain = get!(COMPILED_DOMAINS, problem_id) do
        println("Compiling domain for problem $problem_id...")
        state = initstate(DOMAIN, problem)
        domain, _ = PDDL.compiled(DOMAIN, state)
        return domain
    end

    # Construct initial state
    state = initstate(domain, problem)
    # Simulate plan to completion
    plan_end_state = EndStateSimulator()(domain, state, plan)
    remain_steps = MAX_STEPS - length(plan)

    # Construct plan entry for dataframe
    plan_entry = Dict{Symbol, Any}(
        :plan_id => plan_id,
        :problem_id => problem_id,
        :assist_type => "items",
        :true_goal => string(true_goal_obj),
    )

    # Run literal inference and assistance
    if RUN_LITERAL
        println()
        println("-- Literal instruction following --")
        # Infer distribution over commands
        commands, command_probs, command_scores =
            literal_command_inference(domain, plan_end_state,
                                      utterances[1], verbose=true)
        top_command = commands[1]

        # Print top 5 commands and their probabilities
        println("Top 5 most probable commands:")
        for idx in 1:5
            command_str = repr("text/plain", commands[idx])
            @printf("%.3f: %s\n", command_probs[idx], command_str)
        end

        # Set up planners
        cmd_planner = AStarPlanner(FFHeuristic(), max_nodes=10000)
        goal_planner = AStarPlanner(FFHeuristic(), max_nodes=10000)

        # Set up dataframe entry        
        entry = copy(plan_entry)
        entry[:infer_method] = "literal"
        entry[:modalities] = "utterance"
        entry[:act_temperature] = 0.0
        entry[:top_command] = repr("text/plain", top_command)
        for i in 1:6
            entry[Symbol("assist_probs_$i")] = 0.0
        end

        # Compute naive assistance options and plans for top command
        println()
        top_naive_assist_results = literal_assistance_naive(
            top_command, domain, plan_end_state, true_goal_spec, assist_obj_type;
            cmd_planner, goal_planner, max_steps = remain_steps, verbose = true
        )
        entry[:assist_method] = "naive"
        entry[:estim_type] = "mode"
        entry[:assist_plan] = ""
        entry[:assist_plan_cost] = top_naive_assist_results.plan_cost
        for (i, p) in enumerate(top_naive_assist_results.assist_option_probs)
            entry[Symbol("assist_probs_$i")] = p
        end
        push!(df, entry, cols=:union)

        # Compute expected assistance options and plans via systematic sampling
        # println()
        # mean_naive_assist_results = literal_assistance_naive(
        #     commands, command_probs,
        #     domain, plan_end_state, true_goal_spec, assist_obj_type;
        #     cmd_planner, goal_planner, max_steps = remain_steps,
        #     verbose = true, n_samples = N_LITERAL_NAIVE_SAMPLES
        # )
        # entry[:estim_type] = "mean"
        # entry[:assist_plan] = ""
        # entry[:assist_plan_cost] = mean_naive_assist_results.plan_cost
        # for (i, p) in enumerate(mean_naive_assist_results.assist_option_probs)
        #     entry[Symbol("assist_probs_$i")] = p
        # end
        # push!(df, entry, cols=:union)

        # Compute efficient assistance options and plans for top command
        println()
        top_efficient_assist_results = literal_assistance_efficient(
            top_command, domain, plan_end_state, true_goal_spec, assist_obj_type;
            cmd_planner, goal_planner, max_steps = remain_steps, verbose = true
        )
        entry[:assist_method] = "efficient"
        entry[:estim_type] = "mode"
        entry[:assist_plan] =
            join(write_pddl.(top_efficient_assist_results.full_plan), "\n")
        entry[:assist_plan_cost] = top_efficient_assist_results.plan_cost
        for (i, p) in enumerate(top_efficient_assist_results.assist_option_probs)
            entry[Symbol("assist_probs_$i")] = p
        end
        push!(df, entry, cols=:union)

        # Compute expected assistance options and plans via systematic sampling
        # println()
        # mean_efficient_assist_results = literal_assistance_efficient(
        #     commands, command_probs,
        #     domain, plan_end_state, true_goal_spec, assist_obj_type;
        #     cmd_planner, goal_planner, max_steps = remain_steps,
        #     verbose = true, n_samples = N_LITERAL_EFFICIENT_SAMPLES
        # )
        # entry[:estim_type] = "mean"
        # entry[:assist_plan] = ""
        # entry[:assist_plan_cost] = top_efficient_assist_results.plan_cost
        # for (i, p) in enumerate(top_efficient_assist_results.assist_option_probs)
        #     entry[Symbol("assist_probs_$i")] = p
        # end
        # push!(df, entry, cols=:union)

        GC.gc()
        CSV.write(df_path, df)
    end

    # Run pragmatic inference and assistance
    if RUN_PRAGMATIC
        println()
        println("-- Pragmatic instruction following --")

        # Set up dataframe entry        
        entry = copy(plan_entry)
        entry[:infer_method] = "pragmatic"
        entry[:assist_method] = "offline"
        entry[:estim_type] = "mode"
        entry[:top_command] = ""
        for i in 1:6
            entry[Symbol("assist_probs_$i")] = 0.0
        end

        # Iterate over modalities and parameters
        for act_temperature in ACT_TEMPERATURES
            println()
            println("Action temperature: $act_temperature")
            entry[:act_temperature] = act_temperature

            # Configure pragmatic speaker/agent model
            model_config = configure_pragmatic_speaker_model(
                domain, state, GOALS, cost_profiles;
                modalities=(:action, :utterance), act_temperature
            )

            # Run goal inference
            println()
            println("Running pragmatic goal inference...")
            pragmatic_inference_results = pragmatic_goal_inference(
                model_config, length(GOALS), length(cost_profiles),
                plan, utterances, utterance_times,
                verbose = true
            )

            for modalities in MODALITIES
                println()
                println("Modalities: $modalities")
                entry[:modalities] = join(collect(modalities), ", ")

                # Store inference results
                goal_probs = if modalities == (:action,)
                    pragmatic_inference_results.action_goal_probs
                elseif modalities == (:utterance,)
                    pragmatic_inference_results.utterance_goal_probs
                elseif modalities == (:action, :utterance)
                    pragmatic_inference_results.goal_probs
                end
                for (i, p) in enumerate(goal_probs)
                    entry[Symbol("goal_probs_$i")] = p
                end
                true_goal_idx = findfirst(==(true_goal), GOALS)
                
                entry[:true_goal_probs] = goal_probs[true_goal_idx]
                entry[:brier_score] =
                    sum((goal_probs .- (1:length(GOALS) .== true_goal_idx)).^2)
                entry[:lml_est] = pragmatic_inference_results.lml_est

                # Compute pragmatic assistance options and plans
                println("Running pragmatic goal assistance...")
                pf = copy(pragmatic_inference_results.pf)
                if modalities == (:action,)
                    pf.log_weights .=
                        pragmatic_inference_results.action_trace_scores
                elseif modalities == (:utterance,)
                    pf.log_weights .=
                        pragmatic_inference_results.utterance_trace_scores
                end
                pragmatic_assist_results = pragmatic_assistance_offline(
                    pf, domain, plan_end_state,
                    true_goal_spec, assist_obj_type;
                    verbose = true, max_steps = MAX_STEPS, 
                    act_temperature
                )
                entry[:assist_plan] =
                    join(write_pddl.(pragmatic_assist_results.full_plan), "\n")
                entry[:assist_plan_cost] = pragmatic_assist_results.plan_cost
                for (i, p) in enumerate(pragmatic_assist_results.assist_option_probs)
                    entry[Symbol("assist_probs_$i")] = p
                end
                push!(df, entry, cols=:union)
                CSV.write(df_path, df)
            end
            GC.gc()
        end
    end
end
