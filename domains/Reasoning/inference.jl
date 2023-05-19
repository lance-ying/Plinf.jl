using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie
using JSON


include("utils.jl")
include("ascii.jl")
include("render_new.jl")


# Register PDDL array theory
PDDL.Arrays.register!()

# Load domain and problem
path = joinpath(dirname(pathof(Plinf)), "..", "domains", "reasoning")
domain = load_domain(joinpath(path, "domain.pddl"))
problem = load_problem(joinpath(path, "social.pddl"))
data = JSON.parsefile("data.json")

# Initialize state and construct goal specification
state = initstate(domain, problem)
spec = Specification(problem)

#--- Define Renderer ---#



# Construct gridworld renderer
gem_colors = PDDLViz.colorschemes[:vibrant]
renderer = PDDLViz.GridworldRenderer(
    resolution = (600, 700),
    # agent_renderer = (d, s) -> HumanGraphic(color=:black),
    obj_renderers = Dict(
        :agent => (d, s, o) -> o.name == :human ?
            HumanGraphic() : RobotGraphic(),
        :key => (d, s, o) -> KeyGraphic(
            visible=!s[Compound(:has, [o])],
            color=colordict[get_obj_color(s, o).name]
        ),
        :door => (d, s, o) -> LockedDoorGraphic(
            visible=s[Compound(:locked, [o])],
            color=colordict[get_obj_color(s, o).name]
        ),
        :goal => (d, s, o) -> GemGraphic(
            visible=!s[Compound(:has, [o])],
            color=gem_colors[parse(Int, string(o.name)[end])]
        )
    ),
    show_inventory = false,
    inventory_fns = [(d, s, o) -> s[Compound(:has, [o])]],
    inventory_types = [:item]
)

# Construct gridworld renderer
gem_colors = PDDLViz.colorschemes[:vibrant]
renderer = PDDLViz.GridworldRenderer(
    has_agent = false,
    obj_renderers = Dict(
        :agent => (d, s, o) -> o.name == :Alice ?
            HumanGraphic() 
        :key => (d, s, o) -> KeyGraphic(
            visible=!s[Compound(:has, [o])],
            # color=get_obj_color(s, o).name
            color=colordict[get_obj_color(s, o).name]
        ),
        :door => (d, s, o) -> LockedDoorGraphic(
            visible=s[Compound(:locked, [o])],
            # color=get_obj_color(s, o).name
            color=colordict[get_obj_color(s, o).name]
        ),
        :goal => (d, s, o) -> MultiGraphic(
            GemGraphic(
                visible=!s[Compound(:has, [o])],
                # color=colorscheme[parse(Int, string(o.name)[end])]
                color=colors[parse(Int, string(o.name)[end])]
                # color=:orange
            ),
            # TextGraphic(
            #     string(o.name)[end:end], 0, 0, 0.3,
            #     color=:black, font=:bold
            # )
        )
    ),
    obj_type_z_order = [:door, :key, :goal, :agent],
    show_inventory = true,
    inventory_fns = [
        (d, s, o) -> s[Compound(:has, [Const(:human), o])]
        # (d, s, o) -> s[Compound(:has, [Const(:robot), o])]
    ],

    trajectory_options = Dict(
        :tracked_objects => [Const(:human)],
        :object_colors => [:black]
    )
)
# Visualize initial state
canvas = renderer(domain, state)


# Visualize resulting plan

# canvas = renderer(canvas, domain, state, plan)
# @assert satisfy(domain, sol.trajectory[end], problem.goal) == true

# Visualise search tree
# canvas = renderer(canvas, domain, state, sol, show_trajectory=false)

# # Animate plan
# anim = anim_plan(renderer, domain, state, plan;
                #  format="gif", framerate=5, trail_length=10)

#--- Goal Inference Setup ---#

# Specify possible goals

planner = AStarPlanner(GoalManhattan(), save_search=true)
plan = @pddl()
if "action"
    for act in data["observation"]
        push!(plan, @pddl(act))
    end
else
    path = planner(domain, state, data["observation"])
end
    



goals = @pddl("(has Alice goal1)")
for i in 2:data["goal_count"]
    push!(goals,  @pddl("(has Alice goal$i)"))
end

goal_idxs = collect(1:length(goals))
goal_names = [write_pddl(g) for g in goals]
goal_colors = gem_colors[goal_idxs]

# Define uniform prior over possible goals
@gen function goal_prior()
    goal ~ uniform_discrete(1, length(goals))
    return Specification(goals[goal])
end

# Construct iterator over goal choicemaps for stratified sampling
goal_addr = :init => :agent => :goal => :goal
goal_strata = choiceproduct((goal_addr, 1:length(goals)))

# Compile and cache domain for faster performance
# domain, state = PDDL.compiled(domain, state)
# domain = CachedDomain(domain)

# Configure agent model with domain, planner, and goal prior
# heuristic = RelaxedMazeDist()
# planner = ProbAStarPlanner(heuristic, search_noise=0.1)

base_heuristic = GoalManhattan()
astar = AStarPlanner(base_heuristic)
p_heuristic = memoized(PlannerHeuristic(astar))
# Use RTDP planner that doesn't actually do planning,
# just returns a policy where Q-values are estimated using `p_heuristic`
planner = RTDP(heuristic=p_heuristic, n_rollouts=0) 



agent_config = AgentConfig(
    domain, planner;
    # Assume fixed goal over time
    goal_config = StaticGoalConfig(goal_prior),
    # Assume some Boltzmann action noise (reduce this to make inferences sharper)
    act_temperature = 0.5,
)

# Define observation noise model
obs_params = ObsNoiseParams(
    (pddl"(xloc Alice)", normal, 0.1), (pddl"(yloc Alice)", normal, 0.1),
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


# Construct iterator over observation timesteps and choicemaps 
t_obs_iter = state_choicemap_pairs(obs_traj, obs_terms; batch_size=1)

#--- Online Goal Inference ---#

# Construct callback for logging data and visualizing inference
callback = DKGCombinedCallback(
    renderer, domain;
    goal_addr = goal_addr,
    goal_names = data["goals"],
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
sips = SIPS(world_config, resample_cond = :none , rejuv_cond = :none,
            rejuv_kernel=ReplanKernel(2), period=2)

# Run particle filter to perform online goal inference
n_samples = 18
pf_state = sips(
    n_samples, t_obs_iter;
    init_args=(init_strata=goal_strata,),
    callback=callback
);

# Extract animation
# anim = callback.record.animation

# Create goal inference storyboard
storyboard = render_storyboard(
    anim, [1,2,3];
        # xlabels = ["t = 4", "t = 9", "t = 17", "t = 21"],
    xlabelsize = 20, subtitlesize = 24
);
goal_probs = reduce(hcat, callback.logger.data[:goal_probs])[:, 1:3]
storyboard_goal_lines!(storyboard, goal_probs, [4, 9, 17, 21], show_legend=true)
