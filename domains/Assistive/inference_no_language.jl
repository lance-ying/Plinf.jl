using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie
# using DelimitedFiles
using CSV, DataFrames

include("utils.jl")
include("ascii.jl")
include("render.jl")
# include("load_plans.jl")
# include("utterance_model.jl")


df = DataFrame(
    problem = String[],
    problem_id = String[],
    temperature = Float64[],
    plan = String[],
    goal_probs_0 = Float64[],
    goal_probs_1 = Float64[],
    goal_probs_2 = Float64[],
    goal_probs_3 = Float64[],
)



#--- Initial Setup ---#
TEMPERATURES = 2.0 .^ (-2.0:1.0:4.0)
# Define action costs
costs = (
    pickuph=3.0, pickupr=1.0, handover=1.0, unlockh=1.0, unlockr=1.0, 
    up=1.0, down=1.0, left=1.0, right=1.0, noop=0.1
)
         
# ENV["OPENAI_API_KEY"] = "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"

# Register PDDL array theory
PDDL.Arrays.register!()

goals = @pddl("(has human gem1)", "(has human gem2)",
              "(has human gem3)", "(has human gem4)")
goal_idxs = collect(1:length(goals))
goal_names = [write_pddl(g) for g in goals]
goal_colors = gem_colors[goal_idxs]

@gen function goal_prior()
    goal ~ uniform_discrete(1, length(goals))
    return MinActionCosts(Term[goals[goal]], costs)
end

# Construct iterator over goal choicemaps for stratified sampling
goal_addr = :init => :agent => :goal => :goal
goal_strata = choiceproduct((goal_addr, 1:length(goals)))

# TEMPERATURES = 2.0 .^ (-4.0:1.0:4.0)


for p in keys(problem_dict)
    for p_id in problem_dict[p]
# for p in ["3"]
    # for p_id in ["3.1"]
        println("running $p_id")
        println()
        domain = load_domain(joinpath(@__DIR__, "domain.pddl"))
        problem = load_problem(joinpath(@__DIR__, "$p.pddl"))
        state = initstate(domain, problem)

# Compile and cache domain for faster performance
        domain, state = PDDL.compiled(domain, state)
        domain = CachedDomain(domain)

        # Visualize initial state
        canvas = renderer(domain, state)

        heuristic = GoalManhattan()
        planner = RTHS(heuristic=heuristic, n_iters=1, max_nodes=2^32) 

        for t in TEMPERATURES 

            println("Temperature: $t\n")
            agent_config = AgentConfig(
                domain, planner;
                # Assume fixed goal over time
                goal_config = StaticGoalConfig(goal_prior),
                replan_args = (
                    prob_replan = 0.0, # Probability of replanning at each timestep
                    prob_refine = 1.0, # Probability of refining solution at each timestep
                    rand_budget = false # Search budget is fixed everytime
                ),

                act_temperature = t,
            )

            # Configure world model with agent and environment configuration
            world_config = WorldConfig(
                agent_config = agent_config,
                env_config = PDDLEnvConfig(domain, state),
                obs_config = PerfectObsConfig()
            )

            #--- Online Goal Inference ---#

            plan = action_dict[p_id]

            len_plan = length(plan)

            obs_traj = PDDL.simulate(domain, state, plan)

            # t_obs_iter = act_choicemap_pairs(plan)
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
                record = true
            )

            # Configure SIPS particle filter
            sips = SIPS(world_config, resample_cond=:none, rejuv_cond=:none)
            # ENV["OPENAI_API_KEY"] = "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"
            # Run particle filter to perform online goal inference
            n_samples = 4
            pf_state = sips(
                n_samples,  observations, timesteps;
                init_args=(init_strata=goal_strata,),
                callback=callback
            )

            goal_probs = reduce(hcat, callback.logger.data[:goal_probs])

            goal_predict = argmax(goal_probs[:,end])

            plan_str=string(rollout_sol(domain, planner, pf_state.traces[goal_predict][:timestep => len_plan => :env], pf_state.traces[goal_predict][:timestep => len_plan => :agent => :plan].sol, pf_state.traces[goal_predict][:timestep => len_plan => :agent =>:goal]))

            new_df = DataFrame(
                problem = p,
                problem_id = p_id,
                temperature = t,
                goal_probs_0 = goal_probs[1, end],
                goal_probs_1 = goal_probs[2, end],
                goal_probs_2 = goal_probs[3, end],
                goal_probs_3 = goal_probs[4, end],
                plan = plan_str
            )
            append!(df, new_df)
            println()
            df_path = joinpath(@__DIR__, "inference_language_results.csv")
            CSV.write(df_path, df)
        end
    end
    GC.gc()
end

