using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie
using CSV, DataFrames
using HDF5, JLD

include("utils.jl")
# include("ascii.jl")
include("render.jl")
# include("load_plans.jl")
# include("utterance_model.jl")


# Register PDDL array theory
PDDL.Arrays.register!()

goal_prob_total = Dict()

df = DataFrame(
    problem = String[],
    problem_id = String[],
    temperature = Float64[],
    plan = String[],
    goal_probs_0 = Float64[],
)

for problem_id in 1:20

# Load domain and problem
    domain = load_domain(joinpath(@__DIR__, "domain.pddl"))
    problem = load_problem(joinpath(@__DIR__, "room.pddl"))

    # Initialize state
    state = initstate(domain, problem)

    # Define action costs
    costs = (
        pickup=1.0, takeout=1.0, putdown=1.0, noop=0.2
    )

    goal_name = ["set_table1","set_table1b", "set_table2","set_table2b","set_table3","set_table3b","set_table4","set_table4b","wine1","wine1p","wine2","win2p","wine3","win3p","wine4","win4p","juice1","juice1p","juice2","juice2p","juice3","juice3p","juice4","juice4p","salad","beefstew"]

    #--- Visualize Plans ---#
    heuristic = memoized(precomputed(FFHeuristic(), domain, state))

    #--- Goal Inference Setup ---#

    # Specify possible goals
    goal_idxs = collect(1:length(goals))
    goal_names = [write_pddl(g) for g in goals]
    # goal_colors = gem_colors[goal_idxs]

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
    # heuristic = GoalManhattan()
    # planner = RTHS(heuristic=heuristic, n_iters=1, max_nodes=1000) 
    # heuristic = RelaxedMazeDist(GoalManhattan())
    # heuristic = memoized(GoalManhattan())

    # heuristic = GoalCountHeuristic()
    planner = RTHS(heuristic=heuristic, n_iters=1, max_nodes=2^32)

    # planner = RTDP(heuristic=heuristic, n_rollouts=0) 

    # planner = RTDP(heuristic=heuristic, n_rollouts=100) 

    # Define agent configuration
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
            # Assume a small amount of action noise
            act_temperature = t,
        )


        # Configure world model with agent and environment configuration
        world_config = WorldConfig(
            agent_config = agent_config,
            env_config = PDDLEnvConfig(domain, state),
            obs_config = PerfectObsConfig()
        )

        #--- Online Goal Inference ---#


        plan = action_dict[problem_id]

        obs_traj = PDDL.simulate(domain, state, plan)

        t_obs_iter = act_choicemap_pairs(plan)

        # Construct callback for logging data and visualizing inference
        callback = DKGCombinedCallback(renderer,domain; render=false, goal_names = goal_name)

        # Configure SIPS particle filter
        sips = SIPS(world_config, resample_cond=:none, rejuv_cond=:none)
                
        # Run particle filter to perform online goal inference
        n_samples = 29
        pf_state = sips(
            n_samples, t_obs_iter;
            init_args=(init_strata=goal_strata,),
            callback=callback
        );

        goal_probs = reduce(hcat, callback.logger.data[:goal_probs])

        goal_prob_total[problem_id] = goal_probs

        goal_predict = argmax(goal_probs[:,end])

        plan_str=string(rollout_sol(domain, planner, pf_state.traces[goal_predict][:timestep => len_plan => :env], pf_state.traces[goal_predict][:timestep => len_plan => :agent => :plan].sol, pf_state.traces[goal_predict][:timestep => len_plan => :agent =>:goal]))

        new_df = DataFrame(
            problem = p,
            problem_id = p_id,
            temperature = t,
            plan = plan_str
        )

        append!(df, new_df)
        println()

        df_path = joinpath(@__DIR__, "inference_no_language_results.csv")
        CSV.write(df_path, df)

        save("/Users/lance/Documents/GitHub/Plinf.jl-refactor/domains/Virtual-home/data.jld", "prob_$(problem_id)_$t", goal_prob_total)


    end
end