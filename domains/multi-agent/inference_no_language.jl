using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie
using DelimitedFiles

include("utils.jl")
include("ascii.jl")
include("render.jl")

#--- Initial Setup ---#
plan_dict=Dict("p1_g1"=>@pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(left human)", "(left robot)", "(left human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(down robot)", "(left human)", "(unlockr robot key1 door1)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)"),
"p1_g2"=>@pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(up human)", "(right robot)", "(up human)", "(right robot)", "(right human)", "(right robot)", "(right human)", "(unlockr robot key2 door2)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem2)"),
"p1_g3"=>@pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(up human)", "(down robot)", "(right human)", "(right robot)", "(right human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(unlockr robot key2 door2)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem3)"),
"p2_g1"=>@pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(right human)", "(up robot)", "(right human)", "(handover robot human key2)", "(unlockh human key2 door3)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human key1)", "(noop robot)", "(right human)", "(noop robot)", "(unlockh human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem1)"),
"p2_g2"=>@pddl("(noop human)", "(left robot)", "(right human)", "(left robot)", "(right human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(down robot)", "(noop human)","(down robot)", "(noop human)", "(down robot)", "(noop human)", "(pickupr robot key4)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(handover robot human key2)", "(unlockh human key2 door3)", "(handover robot human key4)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlockh human key4 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem2)"),
"p2_g3"=>@pddl("(noop human)", "(left robot)", "(right human)", "(left robot)", "(right human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(handover robot human key2)", "(unlockh human key2 door3)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem3)"),
"p3_g1"=>@pddl("(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)"),
"p3_g2"=>@pddl("(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(up human)", "(noop robot)", "(unlockh human key2 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem2)"),
"p3_g3"=>@pddl("(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key2 door3)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem3)"),
"p3_g4"=>@pddl("(down human)", "(down robot)", "(down human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(left robot)", "(right human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key1)", "(unlockh human key1 door4)", "(handover robot human key2)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlockh human key2 door5)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem4)"),
"p4_g1"=>@pddl("(noop human)", "(noop robot)","(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key1)", "(right human)","(noop robot)","(right human)","(noop robot)","(unlockh human key1 door1)","(noop robot)","(right human)", "(noop robot)","(right human)", "(noop robot)","(pickuph human gem1)"),
"p4_g2"=>@pddl("(noop human)", "(noop robot)","(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(down robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key2)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlockh human key2 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickuph human gem2)"),
"p4_g3"=>@pddl("(noop human)", "(noop robot)","(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key1)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlockh human key1 door5)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickuph human gem3)"),
"p4_g4"=>@pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(down robot)", "(right human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key2)", "(unlockh human key2 door2)", "(handover robot human key1)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(down human)", "(noop robot)", "(unlockh human key1 door3)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickuph human gem4)"),
"p5_g1"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(right human)", "(right robot)", "(right human)", "(up robot)", "(right human)", "(pickupr robot key1)", "(pickuph human key3)", "(down robot)", "(left human)", "(down robot)", "(unlockh human key3 door3)", "(down robot)", "(noop human)", "(handover robot human key2)", "(noop human)", "(handover robot human key1)","(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key2 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(unlockh human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem1)"),
"p5_g3"=>@pddl("(noop human)", "(noop robot)","(right human)", "(up robot)", "(right human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(right human)", "(right robot)", "(pickuph human key3)", "(down robot)", "(left human)", "(noop robot)", "(unlockh human key3 door3)", "(down robot)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key2 door4)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem3)"),
"p5_g4"=>@pddl("(noop human)", "(noop robot)","(right human)", "(up robot)", "(right human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(right human)", "(right robot)", "(pickuph human key3)", "(up robot)", "(left human)", "(pickupr robot key1)", "(unlockh human key3 door3)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key1)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlockh human key1 door5)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlockh human key2 door6)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem4)"),
"p6_g1" => @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(up human)", "(up robot)", "(up human)", "(left robot)", "(right human)", "(left robot)", "(up human)", "(left robot)", "(noop human)","(left robot)", "(noop human)", "(handover robot human key1)", "(unlockh human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)"),
"p6_g1" => @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(up human)", "(up robot)", "(up human)", "(left robot)", "(right human)", "(left robot)", "(up human)", "(left robot)", "(noop human)","(left robot)", "(noop human)", "(handover robot human key1)", "(unlockh human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)"),
"p6_g3" => @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(down human)", "(down robot)", "(down human)", "(down robot)", "(down human)", "(down robot)", "(down human)", "(down robot)", "(left human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)","(noop human)",  "(up robot)","(noop human)", "(handover robot human key2)",  "(unlockh human key2 door3)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem3)"))


#--- Initial Setup ---#
costs = (pickuph=1.0,pickupr=1.0,handover=1.0, unlockh=1.0, unlockr=10.0, up=1.0, down=1.0, left=1.0, right=1.0, noop=0.6)

# Register PDDL array theory
PDDL.Arrays.register!()

p = 5
# Load domain and problem
path = joinpath(dirname(pathof(Plinf)), "..", "domains", "multi-agent")
domain = load_domain(joinpath(path, "domain.pddl"))
problem = load_problem(joinpath(path, "p$p.pddl"))

# Initialize state and construct goal specification
state = initstate(domain, problem)
# spec = Specification(problem)
goal = [problem.goal]

spec = MinActionCosts(collect(Term, goal), costs)

# Visualize initial state
canvas = renderer(domain, state)

#--- Goal Inference Setup ---#

# Specify possible goals
goals = @pddl("(has human gem1)", "(has human gem2)", "(has human gem3)", "(has human gem4)")
goal_idxs = collect(1:length(goals))
goal_names = [write_pddl(g) for g in goals]
goal_colors = gem_colors[goal_idxs]

# Define uniform prior over possible goals
@gen function goal_prior()
    goal ~ uniform_discrete(1, length(goals))
    return MinActionCosts(collect(Term, [goals[goal]]), costs)
end

# Construct iterator over goal choicemaps for stratified sampling
goal_addr = :init => :agent => :goal => :goal
goal_strata = choiceproduct((goal_addr, 1:length(goals)))

# Compile and cache domain for faster performance
domain, state = PDDL.compiled(domain, state)
domain = CachedDomain(domain)

astar = AStarPlanner(GoalManhattan(), save_search=true)

p_heuristic = memoized(PlannerHeuristic(astar))
# Use RTDP planner that doesn't actually do planning,
# just returns a policy where Q-values are estimated using `p_heuristic`
planner = RTDP(heuristic=p_heuristic, n_rollouts=0) 

agent_config = AgentConfig(
    domain, planner;
    # Assume fixed goal over time
    goal_config = StaticGoalConfig(goal_prior),
    # Assume the agent randomly replans over time
    replan_args = (
        prob_replan = 0, # Probability of replanning at each timestep
        budget_dist = shifted_neg_binom, # Search budget distribution
        budget_dist_args = (1000, 0.05, 1) # Budget distribution parameters
    ),
    # Assume a small amount of action noise
    act_temperature = 2.5,
)

# Define observation noise model
# Define observation noise model
obs_params = ObsNoiseParams(
    (pddl"(xloc human)", normal, 0.1), (pddl"(yloc human)", normal, 0.1),
    (pddl"(xloc robot)", normal, 0.1), (pddl"(yloc robot)", normal, 0.1),
    (pddl"(forall (?d - door) (locked ?d))", 0.05),
    (pddl"(forall (?a - agent ?i - item) (has ?a ?i))", 0.05),
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
    trial = 1

    index = "p$(p)_g$trial"
    plan = plan_dict[index]
    obs_traj = PDDL.simulate(domain, state, plan)

    # Construct iterator over observation timesteps and choicemaps 
    t_obs_iter = state_choicemap_pairs(obs_traj, obs_terms; batch_size=1)


    observations = act_choicemap_vec(plan)

    #--- Online Goal Inference ---#

    # Construct callback for logging data and visualizing inference
    callback = DKGCombinedCallback(
        renderer, domain;
        goal_addr = goal_addr,
        goal_names = ["gem1", "gem2", "gem3", "gem4"],
        goal_colors = goal_colors,
        obs_trajectory = obs_traj,
        print_goal_probs = true,
        plot_goal_bars = false,
        plot_goal_lines = false,
        render = false,
        inference_overlay = false,
        record = false
    )
    timesteps = collect(1:length(observations))
    # Configure SIPS particle filter
    sips = SIPS(world_config, resample_cond=:none, rejuv_cond=:none,
                rejuv_kernel=ReplanKernel(2), period=2)

    # Run particle filter to perform online goal inference
    n_samples = 4
    @time pf_state = sips(
        n_samples,  observations, timesteps;
        init_args=(init_strata=goal_strata,),
        callback=callback
    );


    # Create goal inference storyboard
    goal_probs = reduce(hcat, callback.logger.data[:goal_probs])
    writedlm("results/no_lan/p$(p)_g$(trial).csv",  goal_probs, ',')
    # storyboard_goal_lines!(storyboard, goal_probs, [1,10, 20, 34], show_legend=true)
# end