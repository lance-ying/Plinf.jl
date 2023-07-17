using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie
using DelimitedFiles

include("utils.jl")
include("ascii.jl")
include("render.jl")
# include("load_plans.jl")


action_dict = Dict(
    
"1.1"=>@pddl("(left human)",  "(left human)",  "(left human)","(left human)"),
"2.1"=> @pddl("(up human)", "(up human)",  "(up human)", "(left human)", "(left human)"),
"2.2"=>@pddl("(up human)",  "(up human)",  "(up human)", "(right human)",  "(right human)",  "(right human)"),
"2.3"=>@pddl("(up human)",  "(up human)",  "(up human)", "(left human)", "(left human)", "(left human)",  "(left human)", "(left human)", "(left human)"),
"3.1"=>@pddl("(right human)", "(right human)",  "(up human)"),
"3.2"=>@pddl("(right human)", "(right human)",  "(up human)"),
"3.3"=>@pddl("(right human)",  "(right human)",  "(down human)", "(down human)"),
"4.1"=>@pddl("(down human)", "(down human)",  "(down human)", "(down human)"),
"5.1"=>@pddl("(down human)",  "(down human)", "(right human)"),
"6.1"=>@pddl("(left human)",  "(left human)"),
"6.2"=>@pddl("(left human)",  "(left human)"),
"7.1"=>@pddl("(right human)",  "(right human)","(right human)"),
"7.2"=>@pddl("(right human)",  "(right human)", "(right human)", "(right human)",  "(right human)", "(right human)", "(right human)", "(pickup human key2)"),
"7.3"=>@pddl("(right human)",  "(right human)","(right human)","(right human)"),
"8.1"=>@pddl("(noop human)"),
"8.2"=>@pddl("(noop human)"),
"9.1"=>@pddl("(right human)", "(right human)", "(right human)","(down human)"),
"10.1"=>@pddl("(left human)", "(left human)", "(left human)","(left human)","(left human)","(pickup human key1)"),
"10.2"=>@pddl("(right human)", "(right human)",  "(right human)","(right human)","(right human)","(pickup human key2)"),
"11.1"=>@pddl("(up human)", "(up human)", "(up human)","(up human)"),
"12.1"=>@pddl("(up human)",  "(up human)",  "(right human)", "(right human)"),
"12.2"=>@pddl("(up human)",  "(up human)", "(left human)", "(left human)"),
"13.1"=>@pddl("(down human)", "(down human)", "(pickup human key3)", "(up human)",  "(right human)"),
"13.2"=>@pddl("(down human)", "(left human)", "(left human)", "(left human)","(left human)", "(pickup human key2)", "(right human)", "(right human)")

)
#--- Initial Setup ---#

# Register PDDL array theory
PDDL.Arrays.register!()

# Set problem to load
problem_id = 3

# Load domain and problem
domain = load_domain(joinpath(@__DIR__, "domain_1.pddl"))
problem = load_problem(joinpath(@__DIR__, "$problem_id.pddl"))

# Initialize state
state = initstate(domain, problem)

# Define action costs
costs = (
    pickup=1.0, handover=1.0, unlock=1.0, 
    up=1.0, down=1.0, left=1.0, right=1.0, noop=0.6
)

# Construct goal specification
spec = Specification(Term[problem.goal])

# Visualize initial state
canvas = renderer(domain, state)

#--- Visualize Plans ---#

# Define custom relaxed distance heuristic
heuristic = RelaxedMazeDist(GoalManhattan([pddl"(human)"]))
hval = heuristic(domain, state, pddl"(has human gem1)")

# Check that A* heuristic search correctly solves the problem
astar = AStarPlanner(h, save_search=true, max_nodes=20)
sol = astar(domain, state, pddl"(has human gem1)")

# Visualize solution 
renderer(domain, state, sol)

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

# Compile domain for faster inference
domain, state = compiled(domain, state)

# Construct RTDP planner that does no actual planning
# Value function is initialized to a "no-doors" relaxed distance heuristic
heuristic = RelaxedMazeDist(GoalManhattan([pddl"(human)"]))
planner = RTDP(heuristic=heuristic, n_rollouts=0) 

# Define Boltzmann agent model using relaxed planner
agent_config = AgentConfig(
    domain, planner;
    # Assume fixed goal over time
    goal_config = StaticGoalConfig(goal_prior),
    # Assume a small amount of action noise
    act_temperature = 1.0,
)

# Define observation noise model
# obs_params = ObsNoiseParams(
#     (pddl"(xloc human)", normal, 1.0),
#     (pddl"(yloc human)", normal, 1.0),
#     (pddl"(forall (?d - door) (locked ?d))", 0.05),
#     (pddl"(forall (?i - item) (has ?i))", 0.05),
#     (pddl"(forall (?i - item) (offgrid ?i))", 0.05)
# )
# obs_params = ground_obs_params(obs_params, domain, state)
# obs_terms = collect(keys(obs_params))

# Configure world model with planner, goal prior, initial state, and obs params
world_config = WorldConfig(
    agent_config = agent_config,
    env_config = PDDLEnvConfig(domain, state),
)

#--- Test Trajectory Generation ---#

# Construct a trajectory with backtracking to perform inference on
obs_traj = PDDL.simulate(domain, state, action_dict["3.1"])

# Visualize trajectory
# anim = anim_trajectory(renderer, domain, obs_traj;
                    #    framerate=5, format="gif", trail_length=10)
# storyboard = render_storyboard(
#     anim, [4, 9, 17, 21];
#     subtitles = ["(i) Initially ambiguous goal",
#                  "(ii) Red eliminated upon key pickup",
#                  "(iii) Yellow most likely upon unlock",
#                  "(iv) Switch to blue upon backtracking"],
#     xlabels = ["t = 4", "t = 9", "t = 17", "t = 21"],
#     xlabelsize = 20, subtitlesize = 24
# )

# Construct iterator over observation timesteps and choicemaps 
# t_obs_iter = state_choicemap_pairs(obs_traj, obs_terms; batch_size=1)
t_obs_iter = act_choicemap_pairs(action_dict["3.1"])

#--- Online Goal Inference ---#

# Construct callback for logging data and visualizing inference
callback = DKGCombinedCallback(
    renderer, domain;
    goal_addr = goal_addr,
    goal_names = ["gem1", "gem2", "gem3","gem4" ],
    goal_colors = goal_colors,
    obs_trajectory = obs_traj,
    print_goal_probs = true,
    plot_goal_bars = true,
    plot_goal_lines = true,
    render = true,
    inference_overlay = true,
    record = true
)

# Configure SIPS particle filter
sips = SIPS(world_config, resample_cond=:none, rejuv_cond=:none)

# Run particle filter to perform online goal inference
n_samples = 4
pf_state = sips(
    n_samples, t_obs_iter;
    init_args=(init_strata=goal_strata,),
    callback=callback
);
