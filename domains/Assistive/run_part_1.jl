using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie
using DelimitedFiles

include("utils.jl")
include("ascii.jl")
include("render.jl")

prob_dict=Dict()
function run_stimulus(p,id)
    filename = "$p.$id"
    domain = load_domain(joinpath(@__DIR__, "domain_1.pddl"))
    problem = load_problem(joinpath(@__DIR__, "$p.pddl"))
    
    # Initialize state
    state = initstate(domain, problem)

    
    #--- Goal Inference Setup ---#
    
    # Specify possible goals
    goals = @pddl("(has human gem1)", "(has human gem2)",
                  "(has human gem3)", "(has human gem4)")
    goal_idxs = collect(1:length(goals))
    goal_names = [write_pddl(g) for g in goals]
    goal_colors = gem_colors[goal_idxs]
    
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
    
    # planner = AStarPlanner(heuristic, search_noise=0.1,max_nodes=50) 
    heuristic = GoalManhattan()
    planner = RTHS(heuristic=heuristic, n_iters=1, max_nodes=2^32) 
    agent_config = AgentConfig(
        domain, planner;
        # Assume fixed goal over time
        goal_config = StaticGoalConfig(goal_prior),
        # Assume the agent randomly replans over time
        replan_args = (
            prob_replan = 0.1, # Probability of replanning at each timestep
            budget_dist = shifted_neg_binom, # Search budget distribution
            budget_dist_args = (2, 0.05, 1) # Budget distribution parameters
        ),
        # Assume a small amount of action noise
        act_epsilon = 0.05,
    )
    
    # Define observation noise model
    obs_params = ObsNoiseParams(
        (pddl"(xloc human)", normal, 1.0),
        (pddl"(yloc human)", normal, 1.0),
        (pddl"(forall (?d - door) (locked ?d))", 0.05),
        (pddl"(forall (?i - item) (has ?i))", 0.05),
        (pddl"(forall (?i - item) (offgrid ?i))", 0.05)
    )
    obs_params = ground_obs_params(obs_params, domain, state)
    obs_terms = collect(keys(obs_params))
    
    # Configure world model with planner, goal prior, initial state, and obs params
    world_config = WorldConfig(
        agent_config = agent_config,
        env_config = PDDLEnvConfig(domain, state),
        obs_config = MarkovObsConfig(domain, obs_params)
    )
    
    #--- Test Trajectory Generation ---#
    
    # Construct a trajectory with backtracking to perform inference on
    obs_traj = PDDL.simulate(domain, state, action_dict[filename])
    
    # Visualize trajectory
    # anim = anim_trajectory(renderer, domain, obs_traj;
                        #    framerate=5, format="gif", trail_length=10)
    
    # Construct iterator over observation timesteps and choicemaps 
    t_obs_iter = state_choicemap_pairs(obs_traj, obs_terms; batch_size=1)
    
    #--- Online Goal Inference ---#
    
    # Construct callback for logging data and visualizing inference
    callback = DKGCombinedCallback(
        renderer, domain;
        goal_addr = goal_addr,
        goal_names = ["gem1", "gem2", "gem3","gem4" ],
        goal_colors = goal_colors,
        obs_trajectory = obs_traj,
        print_goal_probs = false,
        plot_goal_bars = false,
        plot_goal_lines = false,
        render = true,
        inference_overlay = false,
        record = true
    )
    
    # Configure SIPS particle filter
    sips = SIPS(world_config, resample_cond=:ess, rejuv_cond=:periodic,
                rejuv_kernel=ReplanKernel(2), period=2)
    
    # Run particle filter to perform online goal inference
    n_samples = 80
    pf_state = sips(
        n_samples, t_obs_iter;
        init_args=(init_strata=goal_strata,),
        callback=callback
    );
    goal_probs = reduce(hcat, callback.logger.data[:goal_probs])
    prob_dict[filename]=goal_probs[:,end]
    
end

function run_all()
    run_stimulus("1.1")
    run_stimulus("2.1")
    run_stimulus("2.2")
    run_stimulus("2.3")
    run_stimulus("3.1")
    run_stimulus("3.2")
    run_stimulus("3.3")
    run_stimulus("4.1")
    run_stimulus("5.1")
    run_stimulus("6.1")
    run_stimulus("6.2")
    run_stimulus("7.1")
    run_stimulus("7.2")
    run_stimulus("7.3")
    run_stimulus("8.1")
    run_stimulus("8.2")
    run_stimulus("9.1")
    run_stimulus("10.1")
    run_stimulus("10.2")
    run_stimulus("11.1")
    run_stimulus("12.1")
    run_stimulus("12.2")
    run_stimulus("13.1")
    run_stimulus("13.2")
end