using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie
using Formatting: printfmt
using DelimitedFiles

using GenGPT3

include("utils.jl")
include("ascii.jl")
include("render_new.jl")

ENV["OPENAI_API_KEY"] = "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"
gpt3 = GPT3GF(model="text-babbage-001")



examples = """
Input: (unlock robot key2 door1) where (is-color door1 blue)
Output: Can you unlock the blue door?
Input: (handover robot human key2) where (is-color key2 blue)
Output: Go pick up the blue key
Input: (unlock robot key1 door1) where (is-color door1 red) 
Output: Can you unlock the red door for me?
Input: (handover robot human key1) where (is-color key1 green)
Output: Can you pick up the green key?
Input: (handover robot human key1) (handover robot human key2) where (is-color key1 green) (is-color key2 red)
Output: Can you pass me the green and the red key?

"""

function select_action(plan)
    action_set = []
    colors = []
    for a in plan
        if (occursin("handover", string(a)))

            push!(action_set, a)
            key_regex = r"(key\d)"
            key = match(key_regex, string(a))


            if key !== nothing
                color = PDDL.satisfiers(domain, state, parse_pddl("(iscolor $(key[1]) ?c)"))[1][Var(:C)]
                push!(colors, "(iscolor $(key[1]) $color)")
            end

        end

        if (occursin("unlock", string(a)) && occursin("robot", string(a)))
            push!(action_set, a)
            door_regex = r"(door\d)" 
            door =  match(door_regex, string(a))

            if door !== nothing
                color = PDDL.satisfiers(domain, state, parse_pddl("(iscolor $(door[1]) ?c)"))[1][Var(:C)]
                push!(colors, "(iscolor $(door[1]) $color)")
            end 
        end
    end

    if length(colors) == 0
        return "nothing"
    end

    prompt = ""
    for a in action_set
        prompt = prompt * string(a) * " "
    end

    prompt = prompt * "where "

    # print(colors)
    for c in colors
        prompt = prompt * string(c) * " "
    end

    return prompt
end


@gen function utterance_model(t, agent_state, env_state, act)

    state = env_state
    sol = agent_state.plan_state.sol
    spec = agent_state.goal_state
    # print("calling utterace model")
    # print("\n\n")

    future_action = Vector{Compound}()
        for _ in 1:80
            act = best_action(sol, state)
            if ismissing(act) break end
            state = transition(domain, state, act)
            push!(future_action, act)
            if is_goal(spec, domain, state) break end
        end


    print(future_action)
    print("\n\n")

    sample_utterance ~ bernoulli(0.5)
    if sample_utterance
        if select_action(future_action) == "nothing"
            # utterance = {:utterance => :output} ~ labeled_unif([""])
            utterance ~ gpt3("say something")
            return utterance
        end
        prompt = examples * "\n" * "Input: " * select_action(future_action) * "\nOutput:"
        # print("calling GPT")
        utterance ~ gpt3(prompt)
        return utterance
    else
        return ""
    end

    
end




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
"p5_g2"=>@pddl("(noop human)", "(noop robot)","(right human)", "(up robot)", "(right human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(right human)", "(right robot)", "(pickuph human key3)", "(down robot)", "(left human)", "(noop robot)", "(unlockh human key3 door3)", "(down robot)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key2 door2)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem2)"),
"p5_g3"=>@pddl("(noop human)", "(noop robot)","(right human)", "(up robot)", "(right human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(right human)", "(right robot)", "(pickuph human key3)", "(down robot)", "(left human)", "(noop robot)", "(unlockh human key3 door3)", "(down robot)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(left human)", "(noop robot)", "(unlockh human key2 door4)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem3)"),
"p5_g4"=>@pddl("(noop human)", "(noop robot)","(right human)", "(up robot)", "(right human)", "(left robot)", "(right human)", "(pickupr robot key2)", "(right human)", "(right robot)", "(pickuph human key3)", "(up robot)", "(left human)", "(pickupr robot key1)", "(unlockh human key3 door3)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(down robot)", "(noop human)", "(handover robot human key1)", "(noop human)", "(handover robot human key2)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(down human)", "(noop robot)", "(down human)", "(noop robot)", "(unlockh human key1 door5)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(unlockh human key2 door6)", "(noop robot)", "(right human)", "(noop robot)", "(right human)", "(noop robot)", "(pickuph human gem4)"),
"p6_g1" => @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(pickupr robot key1)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(up robot)", "(up human)", "(up robot)", "(up human)", "(left robot)", "(right human)", "(left robot)", "(up human)", "(left robot)", "(noop human)","(left robot)", "(noop human)", "(handover robot human key1)", "(unlockh human key1 door1)", "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(pickuph human gem1)"),
"p6_g3" => @pddl("(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(up robot)", "(noop human)", "(right robot)", "(noop human)", "(right robot)", "(noop human)", "(pickupr robot key2)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(down robot)", "(down human)", "(down robot)", "(down human)", "(down robot)", "(down human)", "(down robot)", "(down human)", "(down robot)", "(left human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)", "(noop human)", "(left robot)","(noop human)",  "(up robot)","(noop human)", "(handover robot human key2)",  "(unlockh human key2 door3)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(pickuph human gem3)"))

utterance_dict=Dict("p1_g1" => "Can you unlock the red door?", "p1_g2" =>"Can you help me unlock the blue door?", "p1_g3" =>"Can you help me unlock the blue door for me?",
"p2_g1" => "Can you pass me the red key?", "p2_g2" => "Can you give me the red and the yellow key?", "p2_g3" => "Can you pass me the red key?",
"p3_g1" => "Can I have the blue key?", "p3_g2" => "Can you pass me the red key?",  "p3_g3" => "Can you pass me the red key?", "p3_g4" => "Can you give me the red and the blue key?",
"p4_g1" => "Can you pass me the red key?",  "p4_g2" => "Can you pass me the yellow key?",  "p4_g3" => "Can you pass me the red key?", "p4_g4" => "Pass me the red and yellow key.",
"p5_g1" => "Can you pass me a red and blue key?",  "p5_g2" => "Can you pass me the blue key?",  "p5_g3" => "Can you pass me the blue key?", "p5_g4" => "Pass me the red and blue key.",
"p6_g1" => "Can you pass me the red key?",  "p6_g3" => "Can you pass me the yellow key?"
)

#--- Initial Setup ---#
costs = (pickuph=1.0,pickupr=1.0,handover=1.0, unlockh=1.0, unlockr=10.0, up=1.0, down=1.0, left=1.0, right=1.0, noop=0.6)
# costs = (pickuph=1.0,pickupr=1.0,handover=1.0, unlock=1.0,  up=1.0, down=1.0, left=1.0, right=1.0, noop=0.6)



# Register PDDL array theory
PDDL.Arrays.register!()

p=5
# Load domain and problem
path = joinpath(dirname(pathof(Plinf)), "..", "domains", "multi-agent")
domain = load_domain(joinpath(path, "domain.pddl"))
problem = load_problem(joinpath(path, "p5.pddl"))

# Initialize state and construct goal specification
state = initstate(domain, problem)
# spec = Specification(problem)
goal = [problem.goal]
goal = [@pddl("(has human gem3)")]

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
# astar = AStarPlanner(GoalCountHeuristic(), save_search=true)
astar = AStarPlanner(GoalManhattan(), save_search=true)
@time sol = astar(domain, state, spec)

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
p_heuristic = memoized(PlannerHeuristic(astar))
# Use RTDP planner that doesn't actually do planning,
# just returns a policy where Q-values are estimated using `p_heuristic`
planner = RTDP(heuristic=p_heuristic, n_rollouts=0) 

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

replan_args = (
    prob_replan = 0, # Probability of replanning at each timestep
    budget_dist = shifted_neg_binom, # Search budget distribution
    budget_dist_args = (1000, 0.05, 1) # Budget distribution parameters
)

act_config = BoltzmannActConfig(2.5)


agent_config = AgentConfig(
    domain, planner;
    # Assume fixed goal over time
    goal_config = StaticGoalConfig(goal_prior),
    act_config = CommunicativeActConfig(act_config, utterance_model),
    
)

# agent_config = AgentConfig(
#     goal_config = StaticGoalConfig(goal_prior),
#     plan_config = ReplanConfig(domain, planner; replan_args...),
#     act_config = CommunicativeActConfig(act_config, utterance_model),
# )

# Configure world model with planner, goal prior, initial state, and obs params
world_config = WorldConfig(
    agent_config = agent_config,
    env_config = PDDLEnvConfig(domain, state),
    obs_config = MarkovObsConfig(domain, obs_params)
)

#--- Test Trajectory Generation ---#

# Construct a trajectory with backtracking to perform inference on
    trial=1
    index = "p$(p)_g$trial"
    
    # plan = sol
    plan = plan_dict[index]
    obs_traj = PDDL.simulate(domain, state, plan)

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

    # Create sequence of choicemaps from observed actions
    observations = act_choicemap_vec(collect(Term, plan))


    # Add observed utterance to initial choicemap
    observed_utterance = utterance_dict[index]
    # observed_utterance = "Can you pass me the red and blue key?"
    # observed_utterance = "Can you unlock the red door?"


    for i in 1:length(observations)
        # observations[i][:timestep => i => :act => :utterance => :output] = ""
        observations[i][:timestep => i => :act => :sample_utterance] = false
    end
    observations[1][:timestep => 1 => :act => :utterance => :output] = observed_utterance
    observations[1][:timestep => 1 => :act => :sample_utterance] = true

    timesteps = collect(1:length(observations))

    # Configure SIPS particle filter
    sips = SIPS(world_config, resample_cond=:none, rejuv_cond=:none,
                rejuv_kernel=ReplanKernel(2), period=2)

                
    # Run particle filter to perform online goal inference
    n_samples = 4
    pf_state = sips(
        n_samples,  observations, timesteps;
        init_args=(init_strata=goal_strata,),
        callback=callback
    );

    goal_probs = reduce(hcat, callback.logger.data[:goal_probs])
    writedlm("results/lan/p$(p)_g$(trial)_lan.csv",  goal_probs, ',')


# Extract animation
anim = callback.record.animation

# Create goal inference storyboard
storyboard = render_storyboard(
    anim, [1,8, 18, 28, 40];
    subtitles = ["Human: Can you pick up a red key and a blue key?",
                 "...",
                 "...",
                 "..."],
    xlabels = ["t = 1", "t = 8", "t = 18", "t = 28", "t = 40"],
    xlabelsize = 20, subtitlesize = 24
);
goal_probs = reduce(hcat, callback.logger.data[:goal_probs])
storyboard_goal_lines!(storyboard, new_goal_prob, [1,8, 18, 28, 40], show_legend=true)


future_action = Vector{Compound}()
s = state
for _ in 1:60
    act = best_action(sol, s)
    if ismissing(act) break end
    s = transition(domain, s, act)
    push!(future_action, act)
    if is_goal(spec, domain, s) break end
end

s1= s
zeros(float, 4, 54)



new_goal_prob = selectdim(goal_probs, 2, 4:54)
rating = []

for i in 1:28
    push!(rating, [0.5,0,0,0.5])
    end

for i in 1:23
    push!(rating, [1,0,0,0])
    end
# [1,8, 18, 28, 40]

