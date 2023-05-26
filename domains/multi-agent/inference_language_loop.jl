using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie
using CSV, DataFrames

include("utils.jl")
include("ascii.jl")
include("render.jl")
include("load_plans.jl")
include("utterance_model.jl")

# Register PDDL array theory
PDDL.Arrays.register!()

# Load domain and problems
domain = load_domain(joinpath(@__DIR__, "domain.pddl"))
problem_names = ["p$i" for i in 1:6]
problems = [load_problem(joinpath(@__DIR__, s * ".pddl")) for s in problem_names]

# Load plans
plans, utterances, splitpoints = load_plan_dataset(joinpath(@__DIR__, "plans"))

# Define action costs
costs = (
    pickuph=1.0, pickupr=1.0, handover=1.0, unlockh=1.0, unlockr=10.0, 
    up=1.0, down=1.0, left=1.0, right=1.0, noop=0.6
)

# Specify possible goals
goals = @pddl("(has human gem1)", "(has human gem2)",
              "(has human gem3)", "(has human gem4)")
goal_idxs = collect(1:length(goals))
goal_names = [write_pddl(g) for g in goals]
goal_colors = gem_colors[goal_idxs]
goal_specs = [MinActionCosts(Term[g], costs) for g in goals]

# Define uniform prior over possible goals
@gen function goal_prior()
    goal ~ uniform_discrete(1, length(goals))
    return goal_specs[goal]
end

# Construct iterator over goal choicemaps for stratified sampling
goal_addr = :init => :agent => :goal => :goal
goal_strata = choiceproduct((goal_addr, 1:length(goals)))

# Define temperatures
TEMPERATURES = 2.0 .^ (-4.0:1.0:4.0)

# Construct dataframe to store results
df = DataFrame(
    problem = String[],
    problem_id = Int[],
    goal_id = Int[],
    plan_id = String[],
    temperature = Float64[],
    timestep = Int[],
    is_judgment_point = Bool[],
    utterance = String[],
    action = String[],
    true_goal_probs = Float64[],
    goal_probs_0 = Float64[],
    goal_probs_1 = Float64[],
    goal_probs_2 = Float64[],
    goal_probs_3 = Float64[],
    brier_score = Float64[],
    log_ml_est = Float64[]
)

# Iterate over problems
for (problem_id, problem) in enumerate(problems)
    problem_name = problem_names[problem_id]
    println("== Problem: $problem_name ==")
    println()

    # Initialize state
    state = initstate(domain, problem)

    # Compile and cache domain for faster performance
    c_domain, c_state = PDDL.compiled(domain, state)
    c_domain = CachedDomain(c_domain)

    # Iterate over plans
    p_plans = filter(kv -> startswith(kv.first, problem_name), plans)
    p_utterances = filter(kv -> startswith(kv.first, problem_name), utterances)
    p_splitpoints = filter(kv -> startswith(kv.first, problem_name), splitpoints)
    for plan_id in sort!(collect(keys(p_plans)))
        println("-- Plan: $plan_id --")
        println()

        # Extract plan, judgment points and goal_id
        plan = p_plans[plan_id]
        judgment_times = p_splitpoints[plan_id]
        goal_id = parse(Int, match(r"p\d+_g(\d+)", plan_id).captures[1])

        # Construct choicemap of observed actions to perform inference
        observations = act_choicemap_vec(plan)
        timesteps = collect(1:length(observations))

        # Add observed utterance to initial choicemap
        observed_utterance = p_utterances[plan_id]
        observations[1][:timestep => 1 => :act => :utterance => :output] = " " * observed_utterance
        observations[1][:timestep => 1 => :act => :sample_utterance] = true
        println("Utterance: $observed_utterance\n")

        # Set sample_utterance to false for all other timesteps
        for t in 2:length(observations)
            observations[t][:timestep => t => :act => :sample_utterance] = false
        end

        # Iterate over temperatures
        for temperature in TEMPERATURES
            println("Temperature: $temperature ($plan_id)\n")
            # Use RTHS planner that updates value estimates of all neighboring states
            # at each timestep, using full-horizon heuristic search to estimate the value
            heuristic = memoized(GoalManhattan())
            planner = RTHS(heuristic=heuristic, n_iters=1, max_nodes=2^32)

            # Define agent configuration
            agent_config = AgentConfig(
                c_domain, planner;
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
                    BoltzmannActConfig(temperature), # Assume some Boltzmann action noise
                    utterance_model, # Utterance model defined in utterance_model.jl
                    (c_domain, planner) # Domain and planner are arguments to utterance model
                ),
            )

            # Configure world model with agent and environment configuration
            world_config = WorldConfig(
                agent_config = agent_config,
                env_config = PDDLEnvConfig(c_domain, c_state),
                obs_config = PerfectObsConfig()
            )

            # Construct callback for logging data and visualizing inference
            callback = DKGCombinedCallback(
                renderer, c_domain;
                goal_addr = goal_addr,
                goal_names = ["gem1", "gem2", "gem3", "gem4"],
                goal_colors = goal_colors,
                obs_trajectory = PDDL.simulate(c_domain, c_state, plan),
                print_goal_probs = true,
                plot_goal_bars = false,
                plot_goal_lines = false,
                render = false,
                inference_overlay = false,
                record = false,
                sleep = 0.001
            )

            # Configure SIPS particle filter
            sips = SIPS(world_config, resample_cond=:none, rejuv_cond=:none)

            # Run particle filter to perform online goal inference
            n_samples = length(goals)
            pf_state = sips(
                n_samples,  observations, timesteps;
                init_args=(init_strata=goal_strata,),
                callback=callback
            )

            # Extract goal probabilities and log ML estimate
            goal_probs = reduce(hcat, callback.logger.data[:goal_probs])
            log_ml_est = callback.logger.data[:lml_est]

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
            log_ml_est[1] = logsumexp(utterance_logprobs) - log(n_samples)

            # Compute Brier score
            true_goal_indicator = zeros(size(goal_probs))
            true_goal_indicator[goal_id, :] .= 1.0
            brier_score = vec(sum((goal_probs .- true_goal_indicator).^2, dims=1))

            # Store results in dataframe
            n_timesteps = length(timesteps) + 1
            timesteps_shifted = [1; timesteps .+ 1]
            plan_shifted = [[write_pddl(PDDL.no_op)]; write_pddl.(plan)]
            new_df = DataFrame(
                problem = fill(problem_name, n_timesteps),
                problem_id = fill(problem_id, n_timesteps),
                goal_id = fill(goal_id, n_timesteps),
                plan_id = fill(plan_id, n_timesteps),
                temperature = fill(temperature, n_timesteps),
                timestep = timesteps_shifted,
                is_judgment_point = [t in judgment_times for t in timesteps_shifted],
                utterance = fill(observed_utterance, n_timesteps),
                action = plan_shifted,
                true_goal_probs = goal_probs[goal_id, :],
                goal_probs_0 = goal_probs[1, :],
                goal_probs_1 = goal_probs[2, :],
                goal_probs_2 = goal_probs[3, :],
                goal_probs_3 = goal_probs[4, :],
                brier_score = brier_score,
                log_ml_est = log_ml_est
            )

            # Append results to dataframe
            append!(df, new_df)
            println()
        end
    end
    GC.gc()
end

df_path = joinpath(@__DIR__, "inference_language_results.csv")
CSV.write(df_path, df)
