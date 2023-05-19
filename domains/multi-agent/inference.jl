using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie


include("utils.jl")
include("ascii.jl")
include("render_new.jl")

#--- Initial Setup ---#
plan_dict=Dict("p1_g1"=>@pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(left human)", "(left robot)", "(left human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(down robot)", "(left human)", "(unlock robot key1 door1)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)"),
"p1_g2"=>@pddl("(right human)", "(right robot)", "(right human)", "(right robot)", "(right human)", "(right robot)", "(up human)", "(pickupr robot key2)", "(up human)", "(left robot)", "(up human)", "(unlock robot key2 door2)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)", "(noop robot)","(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(up human)","(noop robot)",  "(pickuph human gem2)"),
"p1_g3"=>@pddl("(right human)", "(right robot)", "(right human)", "(right robot)", "(right human)", "(right robot)", "(up human)", "(pickupr robot key2)", "(up human)", "(left robot)", "(up human)", "(unlock robot key2 door2)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)","(noop robot)", "(right human)","(noop robot)", "(right human)","(noop robot)", "(right human)","(noop robot)","(pickuph human gem3)"),
"p2_g1"=>@pddl("(right human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(down robot)", "(right human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(up human)", "(noop robot)", "(unlock human key2 door3)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human key1)", "(noop robot)", "(right human)", "(noop robot)", "(unlock human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem1)"),
"p2_g2"=>@pddl("(right human)", "(left robot)", "(right human)", "(up robot)", "(down human)", "(pickupr robot key2)", "(down human)", "(down robot)", "(down human)", "(left robot)", "(left human)", "(left robot)", "(left human)","(left robot)" , "(pickuph human key4)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(handover robot human key2)", "(up human)", "(noop robot)", "(unlock human key2 door3)",  "(noop robot)","(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlock human key4 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem2)"),
"p2_g3"=>@pddl("(right human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(down robot)", "(right human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(up human)", "(noop robot)", "(unlock human key2 door3)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem3)"),
"p3_g1"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(up human)", "(left robot)", "(right human)", "(left robot)", "(right human)", "(left robot)", "(pickuph human key2)", "(handover robot human key1)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key1 door3)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key2 door1)","(noop robot)", "(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)", "(pickuph human gem1)" ),
"p3_g2"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(up human)", "(noop robot)", "(unlock human key1 door2)","(noop robot)", "(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)", "(pickuph human gem2)" ),
"p3_g3"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(unlock human key1 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem3)"),
"p3_g4"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key1)", "(unlock human key1 door4)", "(handover robot human key2)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlock human key2 door5)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem4)"),
"p4_g1"=>@pddl("(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key1)", "(right human)","(noop robot)","(right human)","(noop robot)","(unlock human key1 door1)","(noop robot)","(right human)", "(noop robot)","(right human)", "(noop robot)","(pickuph human gem1)"),
"p4_g2"=>@pddl("(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(down robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key2)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlock human key2 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickuph human gem2)"),
"p4_g3"=>@pddl("(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key1)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlock human key1 door5)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickuph human gem3)"),
"p4_g4"=>@pddl("(noop human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(noop human)", "(left robot)", "(up human)", "(left robot)", "(right human)", "(pickupr robot key1)", "(right human)", "(down robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(handover robot human key2)", "(unlock human key2 door2)", "(handover robot human key1)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(down human)", "(noop robot)", "(unlock human key1 door3)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(pickuph human gem4)"),
"p5_g1"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key3)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key3)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key3 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(unlock human key2 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem1)"),
"p5_g2"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key3)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key3)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key3 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)","(right human)", "(noop robot)","(right human)", "(noop robot)","(right human)", "(noop robot)","(pickuph human gem2)"),
"p5_g3"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key3)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key3)", "(noop human)", "(handover robot human key2)", "(unlock human key2 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(unlock human key3 door5)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem3)"),
"p5_g4"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(unlock human key2 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem4)"),

)

#--- Initial Setup ---#
# costs = (pickuph=1.0,pickupr=1.0,handover=1.0, unlock=1.0, up=1.0, down=1.0, left=1.0, right=1.0, noop=0.6)
costs = (pickuph=1.0,pickupr=1.0,handover=1.0, unlockh=1.0, unlockr=1.0, up=1.0, down=1.0, left=1.0, right=1.0, noop=0.6)



# Register PDDL array theory
PDDL.Arrays.register!()

# Load domain and problem
path = joinpath(dirname(pathof(Plinf)), "..", "domains", "multi-agent")
domain = load_domain(joinpath(path, "domain.pddl"))
problem = load_problem(joinpath(path, "p3.pddl"))

# Initialize state and construct goal specification
state = initstate(domain, problem)
# spec = Specification(problem)
goal = [problem.goal]

goal = [@pddl("(has human gem1)")]
spec = MinActionCosts(collect(Term, goal), costs)

#--- Define Renderer ---#

# Construct gridworld renderer
gem_colors = PDDLViz.colorschemes[:vibrant]
renderer = PDDLViz.GridworldRenderer(
    resolution = (600, 700),
    has_agent = false,
    # agent_renderer = (d, s) -> HumanGraphic(color=:black),
    obj_renderers = Dict(
        :agent => (d, s, o) -> o.name == :human ?
            HumanGraphic() : RobotGraphic(),
        :key => (d, s, o) -> KeyGraphic(
            color=colordict[get_obj_color(s, o).name]
        ),
        :door => (d, s, o) -> LockedDoorGraphic(
            visible=s[Compound(:locked, [o])],
            color=colordict[get_obj_color(s, o).name]
        ),
        :gem => (d, s, o) -> GemGraphic(
            color=gem_colors[parse(Int, string(o.name)[end])]
        )
    ),
    obj_type_z_order = [:door, :key, :gem, :agent],
    show_inventory = true,
    inventory_fns = [
        (d, s, o) -> s[Compound(:has, [Const(:human), o])],
        (d, s, o) -> s[Compound(:has, [Const(:robot), o])]
    ],
    inventory_types = [:item, :item],
    inventory_labels = ["Human", "Robot"],
    trajectory_options = Dict(
        :tracked_objects => [Const(:human), Const(:robot)],
        :tracked_types => Const[],
        :object_colors => [:black, :slategray]
    )
)
# Visualize initial state
canvas = renderer(domain, state)

#--- Visualize Plans ---#

# Check that A* heuristic search correctly solves the problem
astar = AStarPlanner(GoalCountHeuristic(), save_search=true)

plan = astar(domain, state, spec)

p_heuristic = memoized(PlannerHeuristic(astar))
planner = RTDP(heuristic=p_heuristic, n_rollouts=0) 
@time sol = planner(domain, state, spec)
future_action = Vector{Compound}()
for _ in 1:100
    act = best_action(sol, state)
    if ismissing(act) break end
    state = transition(domain, state, act)
    push!(future_action, act)
    if is_goal(spec, domain, state) break end
end




anim = anim_plan(renderer, domain, state, plan;
                 format="gif", framerate=5, trail_length=10)

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

# Configure agent model with domain, planner, and goal prior
heuristic = RelaxedMazeDist()
planner = ProbAStarPlanner(heuristic, search_noise=0.1, max_nodes = 200)
agent_config = AgentConfig(
    domain, planner;
    # Assume fixed goal over time
    goal_config = StaticGoalConfig(goal_prior),
    # Assume the agent randomly replans over time
    replan_args = (
        prob_replan = 0.2, # Probability of replanning at each timestep
        budget_dist = shifted_neg_binom, # Search budget distribution
        budget_dist_args = (50, 0.05, 1) # Budget distribution parameters
    ),
    # Assume a small amount of action noise
    act_epsilon = 0.05,
)

# Define observation noise model
# Define observation noise model
obs_params = ObsNoiseParams(
    (pddl"(xloc human)", normal, 1.0), (pddl"(yloc human)", normal, 1.0),
    (pddl"(xloc robot)", normal, 1.0), (pddl"(yloc robot)", normal, 1.0),
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

plan = plan_dict["p2_g1"]
obs_traj = PDDL.simulate(domain, state, plan)

# Visualize trajectory
anim = anim_trajectory(renderer, domain, obs_traj;
                       framerate=5, format="gif", trail_length=10)
storyboard = render_storyboard(
    anim, [4, 9, 17, 21];
    subtitles = ["(i) Initially ambiguous goal",
                 "(ii) Red eliminated upon key pickup",
                 "(iii) Yellow most likely upon unlock",
                 "(iv) Switch to blue upon backtracking"],
    xlabels = ["t = 4", "t = 9", "t = 17", "t = 21"],
    xlabelsize = 20, subtitlesize = 24
)

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
    render = true,
    inference_overlay = true,
    record = true
)

# Configure SIPS particle filter
sips = SIPS(world_config, resample_cond=:ess, rejuv_cond=:periodic,
            rejuv_kernel=ReplanKernel(2), period=2)

# Run particle filter to perform online goal inference
n_samples = 40
@time pf_state = sips(
    n_samples, t_obs_iter;
    init_args=(init_strata=goal_strata,),
    callback=callback
);

# Extract animation
anim = callback.record.animation

# Create goal inference storyboard
storyboard = render_storyboard(
    anim, [1,10, 20, 34];
    subtitles = ["(i) Initially ambiguous goal",
                 "(ii) Red eliminated upon key pickup",
                 "(iii) Yellow most likely upon unlock",
                 "(iv) Switch to blue upon backtracking"],
    xlabels = ["t = 1", "t = 10", "t = 20", "t = 34"],
    xlabelsize = 20, subtitlesize = 24
);
goal_probs = reduce(hcat, callback.logger.data[:goal_probs])
storyboard_goal_lines!(storyboard, goal_probs, [1,10, 20, 34], show_legend=true)
