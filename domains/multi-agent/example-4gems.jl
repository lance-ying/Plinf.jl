using Julog, PDDL, Gen, Printf
using Plinf

include("render.jl")
include("utils.jl")
include("ascii.jl")

costs = (pickup=1.0,handover=0.9, unlock=1.0, up=1.0, down=1.0, left=1.0, right=1.0, noop=0.5)

#--- Initial Setup ---#

# Register PDDL array theory
PDDL.Arrays.register!()

# Load domain and problem
path = joinpath(dirname(pathof(Plinf)), "..", "domains", "multi-agent")
domain = load_domain(joinpath(path, "domain.pddl"))
problem = load_problem(joinpath(path, "p5.pddl"))

# Initialize state, set goal and goal colors
state = initstate(domain, problem)
start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))
goal = [problem.goal]
# goal=[pddl"(not (locked door2))"]
spec = MinActionCosts(goal, costs)

num_gems=4
goal_colors, gem_terms, gem_colors = generate_gems(num_gems)

plt = render(state; start=start_pos, gem_colors=gem_colors)


#--- Visualize Plans ---#


# Check that A* heuristic search correctly solves the problem
planner = AStarPlanner(heuristic=GemHeuristic())
plan, traj = planner(domain, state, spec)


spec = MinActionCosts([pddl"(has human gem1)"], costs)
plan, traj = planner(domain, state, spec)
# plan = Term[pddl"(right human)", pddl"(left robot)", pddl"(right human)", pddl"(up robot)", pddl"(right human)", pddl"(noop robot)", pddl"(down human)", pddl"(noop robot)", pddl"(down human)", pddl"(pickup robot key2)", pddl"(down human)", pddl"(down robot)", pddl"(left human)", pddl"(left robot)", pddl"(left human)", pddl"(left robot)", pddl"(pickup human key4)", pddl"(left robot)", pddl"(right human)", pddl"(left robot)", pddl"(right human)", pddl"(left robot)", pddl"(up human)", pddl"(left robot)", pddl"(up human)", pddl"(left robot)", pddl"(up human)", pddl"(up robot)", pddl"(up human)", pddl"(unlock robot key2 door4)", pddl"(up human)", pddl"(noop robot)", pddl"(up human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(right human)", pddl"(noop robot)", pddl"(right human)"]
# traj = PDDL.simulate(domain, state, plan)


println("== Plan ==")
display(plan)

plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan)
@assert satisfy(domain, traj[end], goal) == true

# Visualize full horizon probabilistic A* search
planner = ProbAStarPlanner(heuristic=GoalCountHeuristic(), trace_states=true)
plt = render(state; start=start_pos, gem_colors=gem_colors, show_objs=true)
tr = Gen.simulate(sample_plan, (planner, domain, state, goal))
anim = anim_plan(tr, plt)

# Visualize distribution over trajectories induced by planner
trajs = [planner(domain, state, goal)[2] for i in 1:20]
plt = render(state; start=start_pos, gem_colors=gem_colors, show_objs=false)
anim = anim_traj(trajs, plt; alpha=0.1, gem_colors=gem_colors)

# Visualize sample-based replanning search
astar = ProbAStarPlanner(heuristic=GemHeuristic(), trace_states=true)
replanner = Replanner(planner=astar, persistence=(2, 0.95))
plt = render(state; start=start_pos, gem_colors=gem_colors, show_objs=true)
tr = Gen.simulate(sample_plan, (replanner, domain, state, goal))
anim = anim_replan(tr, plt; gem_colors=gem_colors, show_objs=false)

# Visualize distribution over trajectories induced by replanner
trajs = [replanner(domain, state, goal)[2] for i in 1:20]
anim = anim_traj(trajs, plt; alpha=0.1, gem_colors=gem_colors)

#--- Goal Inference Setup ---#

# Specify possible goals
goals = return_goals(num_gems)
goal_idxs = collect(1:length(goals))
goal_names = [repr(g) for g in goals]

# Define uniform prior over possible goals
@gen function goal_prior()
    Specification(goals[@trace(uniform_discrete(1, length(goals)), :goal)])
end
goal_strata = Dict((:init => :agent => :goal => :goal) => goal_idxs)

# Assume either a planning agent or replanning agent as a model
heuristic = GemMazeDist()
planner = ProbAStarPlanner(heuristic=heuristic, search_noise=0.1)
replanner = Replanner(planner=planner, persistence=(2, 0.95))
agent_planner = replanner # planner

# Configure agent model with goal prior and planner
act_noise = 0.0
agent_init = AgentInit(agent_planner, goal_prior)
agent_config = AgentConfig(domain, agent_planner, act_noise=act_noise)

# Define observation noise model
obs_params = observe_params(
    # (pddl"(xpos)", normal, 1.0), (pddl"(ypos)", normal, 1.0),
    (pddl"(forall (?d - door) (locked ?d))", 0.05),
    (pddl"(forall (?i - item) (has ?i))", 0.05),
    (pddl"(forall (?i - item) (offgrid ?i))", 0.05),
)
obs_params = ground_obs_params(obs_params, state, domain)
obs_terms = collect(keys(obs_params))

# Configure world model with planner, goal prior, initial state, and obs params
world_init = WorldInit(agent_init, state, state)
world_config = WorldConfig(domain, agent_config, obs_params)

# Construct a trajectory with backtracking to perform inference on
plan1, traj = planner(domain, state, pddl"(has robot key1)")
plan2, traj = planner(domain, traj[end], MinActionCosts([pddl"(has human gem3)"], costs))
plan3, traj = planner(domain, traj[end], MinActionCosts([pddl"(has human gem3)"], costs))
# plan4, traj = planner(domain, traj[end], pddl"(has gem3)")
plan1 = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(right robot)", "(noop human)", "(pickup robot key3)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key3)", "(noop human)", "(handover robot human key2)") 

plan1 = @pddl("(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)", "(left robot)", "(up human)")
# plan1 = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(pickup robot key2)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)",  "(left robot)", "(noop human)", "(left robot)",  "(noop human)", "(handover robot human key2)")
# plan1 = @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickup robot key1)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)",  "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)","(left robot)", "(noop human)","(left robot)", "(noop human)")
plan1 = collect(Term, plan1)

traj = PDDL.simulate(domain, state, plan1) 
# plan2, traj = planner(domain, traj[end], spec)

plan = [plan1; plan2]
plan = [plan1; plan2; plan3]
plan, traj = planner(domain, state, pddl"(not(locked door1))")
# traj = PDDL.simulate(domain, state, plan)

# Visualize trajectory
frames = []
anim = anim_traj(traj; gem_colors=gem_colors, plan=plan, frames=frames)
times = [4, 9, 17, 21]
storyboard = plot_storyboard(frames[times], nothing, times;
                             titles=["Initially ambiguous goal",
                                     "Red eliminated upon key pickup",
                                     "Yellow most likely upon unlock",
                                     "Switch to blue upon backtracking"])

#--- Offline Goal Inference ---#

# Run importance sampling to infer the likely goal
n_samples = 30
traces, weights, lml_est =
    world_importance_sampler(world_init, world_config,
                             traj, obs_terms, n_samples;
                             use_proposal=true, strata=goal_strata);

# Plot sampled trajectory for each trace
plt = render(state; start=start_pos, gem_colors=gem_colors)
render_traces!(traces, weights, plt; goal_colors=goal_colors)
plt = render!(traj, plt; alpha=0.5) # Plot original trajectory on top

# Compute posterior probability of each goal
goal_probs = get_goal_probs(traces, weights, 1:length(goals))
println("Posterior probabilities:")
for (goal, prob) in zip(goal_names, values(sort(goal_probs)))
    @printf "Goal: %s\t Prob: %0.3f\n" goal prob
end

# Plot bar chart of goal probabilities
plot_goal_bars!(goal_probs, goal_names, goal_colors)

#--- Online Goal Inference ---#

# Set up visualization and logging callbacks for online goal inference

anim = Animation() # Animation to store each plotted frame
keytimes = [4, 9, 17, 21] # Timesteps to save keyframes
keyframes = [] # Buffer of keyframes to plot as a storyboard
goal_probs = [] # Buffer of goal probabilities over time
plotters = [ # List of subplot callbacks:
    render_cb,
    # goal_lines_cb,
    # goal_bars_cb,
    # plan_lengths_cb,
    # particle_weights_cb,
]
canvas = render(state; start=start_pos, show_objs=false)
callback = (t, s, trs, ws) -> begin
    goal_probs_t = collect(values(sort!(get_goal_probs(trs, ws, goal_idxs))))
    push!(goal_probs, goal_probs_t)
    multiplot_cb(t, s, trs, ws, plotters;
                 trace_future=true, plan=plan,
                 start_pos=start_pos, start_dir=:down,
                 canvas=canvas, animation=anim, show=true,
                 keytimes=keytimes, keyframes=keyframes,
                 gem_colors=gem_colors, goal_colors=goal_colors,
                 goal_probs=goal_probs, goal_names=goal_names);
    print("t=$t\t")
    print_goal_probs(get_goal_probs(trs, ws, goal_idxs))
end

# Set up rejuvenation moves
goal_rejuv! = pf -> pf_goal_move_accept!(pf, goals)
plan_rejuv! = pf -> pf_replan_move_accept!(pf)
mixed_rejuv! = pf -> pf_mixed_move_accept!(pf, goals; mix_prob=0.25)

# Set up action proposal to handle potential action noise
act_proposal = act_noise > 0 ? forward_act_proposal : nothing
act_proposal_args = (act_noise*5,)

# Run a particle filter to perform online goal inference
n_samples = 10
traces, weights =
    world_particle_filter(world_init, world_config, traj, obs_terms, n_samples;
                          resample=true, rejuvenate=nothing,
                          callback=callback, strata=goal_strata,
                          act_proposal=act_proposal,
                          act_proposal_args=act_proposal_args);
# Show animation of goal inference
gif(anim; fps=2)

## Plot storyboard of keyframes ##

storyboard = plot_storyboard(
    keyframes, goal_probs, keytimes;
    time_lims=(1, 27), legend=false,
    titles=["Initially ambiguous goal",
            "Red eliminated upon key pickup",
            "Yellow most likely upon unlock",
            "Switch to blue upon backtracking"],
    goal_names=["Red Gem", "Yellow Gem", "Blue Gem"],
    goal_colors=goal_colors)
