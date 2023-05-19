using Julog, PDDL, Gen, Printf
using Plinf

include("utils.jl")
include("ascii.jl")
include("render.jl")

#Plan dataset#
plan_dict=Dict("p1_g1"=>@pddl("(right human)", "(left robot)", "(right human)", "(left robot)", "(right human)", "(pickupr robot key1)", "(up human)", "(unlock robot key1 door1)","(up human)", "(noop robot)","(left human)", "(noop robot)","(left human)", "(noop robot)","(left human)", "(noop robot)","(up human)", "(noop robot)","(up human)", "(noop robot)","(up human)", "(noop robot)","(up human)", "(noop robot)","(up human)", "(noop robot)","(pickuph human gem1)") ,
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
"p5_g4"=>@pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(right robot)", "(noop human)", "(down robot)", "(noop human)", "(unlock robot key1 door3)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(handover robot human key2)", "(unlock human key2 door4)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem4)")

)

#--- Initial Setup ---#
costs = (pickuph=1.0,pickupr=1.0,handover=1.0, unlock=1.0, up=1.0, down=1.0, left=1.0, right=1.0, noop=0.6)
# Register PDDL array theory
PDDL.Arrays.register!()

# Load domain and problem
path = joinpath(dirname(pathof(Plinf)), "..", "domains", "multi-agent")
domain = load_domain(joinpath(path, "domain.pddl"))
problem = load_problem(joinpath(path, "p1.pddl"))

# Initialize state, set goal and goal colors
state = initstate(domain, problem)
start_pos = Dict("human"=>(state[pddl"(xloc human)"], state[pddl"(yloc human)"]), "robot"=>(state[pddl"(xloc robot)"], state[pddl"(yloc robot)"]))
goal = [problem.goal]
spec = MinActionCosts(goal, costs)

num_gems=4
goal_colors, gem_terms, gem_colors = generate_gems(num_gems)
#--- Visualize Plans ---#

# Check that A* heuristic search correctly solves the problem

planner = AStarPlanner(heuristic=GemHeuristic())
plan, traj = planner(domain, state, spec)
println("== Plan ==")
display(plan)
plt = render(state; start=start_pos, plan=plan, gem_colors=gem_colors)
anim = anim_traj(traj; start_pos=start_pos, gem_colors=gem_colors, plan=plan)
@assert satisfy(domain, traj[end], goal) == true


#--- Goal Inference Setup ---#

# Specify possible goals
goals = @pddl("(has human gem1)", "(has human gem2)","(has human gem3)","(has human gem4)")
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
    (pddl"(xloc human)", normal, 1.0), (pddl"(yloc human)", normal, 1.0),
    (pddl"(xloc robot)", normal, 1.0), (pddl"(yloc robot)", normal, 1.0),
    (pddl"(forall (?d - door) (locked ?d))", 0.05),
    (pddl"(forall (?i - item) (has ?i))", 0.05),
    (pddl"(forall (?i - item) (offgrid ?i))", 0.05),
)
obs_params = ground_obs_params(obs_params, state, domain)
obs_terms = collect(keys(obs_params))

# Configure world model with planner, goal prior, initial state, and obs params
world_init = WorldInit(agent_init, state, state)
world_config = WorldConfig(domain, agent_config, obs_params)



#--- Online Goal Inference ---#

# Set up visualization and logging callbacks for online goal inference

anim = Animation() # Animation to store each plotted frame
keytimes = [4, 14, 22, 30] # Timesteps to save keyframes
keyframes = [] # Buffer of keyframes to plot as a storyboard
goal_probs = [] # Buffer of goal probabilities over time
plotters = [ # List of subplot callbacks:
    render_cb,
    # goal_lines_cb,
    # goal_bars_cb,
    # plan_lengths_cb,
    # particle_weights_cb,
]
# print(plotters)
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
n_samples = 20
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
    time_lims=(1, 12), legend=false,
    # titles=["Initially ambiguous goal",
            # "Red eliminated upon key pickup",
            # "Yellow most likely upon unlock",
            # "Switch to blue upon backtracking"],
    goal_names=["Red Gem", "Yellow Gem", "Blue Gem","Green Gem"],
    goal_colors=goal_colors)
