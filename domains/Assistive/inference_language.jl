using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie
using DelimitedFiles

include("utils.jl")
include("ascii.jl")
include("render.jl")
include("load_plans.jl")
include("utterance_model.jl")

problem_dict=Dict(
    "1"=>["1.1"],
    "2"=>["2.1","2.2"],
    "3"=>["3.1","3.2","3.3"],
    "4"=>["4.1","4.2"],
    "5"=>["5.1"],
    "6"=>["6.1"],
    "7"=>["7.1"],
    "8"=>["8.1","8.2"],
    "9"=>["9.1"],
    "10"=>["10.1","10.2"],
    "11"=>["11.1","11.2"],
    "12"=>["12.1","12.2"],
    "13"=>["13.1","13.2"],
    "14"=>["14.1"],
    "15"=>["15.1"],
    "16"=>["16.1"],
    "17"=>["17.1"],
    "18"=>["18.1"],
    "19"=>["19.1"],
    "20"=>["20.1"]

)
#--- Initial Setup ---#
TEMPERATURES = 2.0 .^ (-4.0:1.0:4.0)
         
ENV["OPENAI_API_KEY"] = "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"

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

TEMPERATURES = 2.0 .^ (-4.0:1.0:4.0)


for p in keys(problem_dict)
    for p_id in problem_dict[p]
        print("running $p_id")
        domain = load_domain(joinpath(@__DIR__, "domain.pddl"))
        problem = load_problem(joinpath(@__DIR__, "$p.pddl"))
        state = initstate(domain, problem)

# Define action costs
        costs = (
            pickuph=3.0, pickupr=1.0, handover=1.0, unlockh=1.0, unlockr=1.0, 
            up=1.0, down=1.0, left=1.0, right=1.0, noop=0.1
)

# Compile and cache domain for faster performance
        domain, state = PDDL.compiled(domain, state)
        domain = CachedDomain(domain)

        # Visualize initial state
        canvas = renderer(domain, state)

        heuristic = RelaxedMazeDist(GoalManhattan())
        planner = RTHS(heuristic=heuristic, n_iters=1, max_nodes=2^32) 

        for t in TEMPERATURES

            # Define agent configuration
            agent_config = AgentConfig(
                domain, planner;
                # Assume fixed goal over time
                goal_config = StaticGoalConfig(goal_prior),
                # Assume the agent refines its policy at every timestep
                replan_args = (
                    prob_replan = 0, # Probability of replanning at each timestep
                    prob_refine = 1.0, # Probability of refining solution at each timestep
                    rand_budget = false # Search budget is fixed everytime
                ),
                # Joint action-utterance model
                act_config = CommunicativeActConfig(
                    BoltzmannActConfig(12.5), # Assume some Boltzmann action noise
                    utterance_model, # Utterance model defined in utterance_model.jl
                    (domain, planner) # Domain and planner are arguments to utterance model
                ),
            )

            # Configure world model with agent and environment configuration
            world_config = WorldConfig(
                agent_config = agent_config,
                env_config = PDDLEnvConfig(domain, state),
                obs_config = PerfectObsConfig()
            )

            #--- Online Goal Inference ---#

            # Load plan dataset
            # plans, utterances, splitpoints = load_plan_dataset(joinpath(@__DIR__, "plans"))
            plan = @pddl("(noop human)","(noop robot)","(noop human)","(noop robot)")
            utterance = "I'll get the blue key. Can you pick up a red key?"

            observations = act_choicemap_vec(plan)
            timesteps = collect(1:length(observations))

            # Add observed utterance to initial choicemap
            observed_utterance = utterance

            # observed_utterance = "can you pass me the blue key?"
            len_obs=length(observations)
            observations[len_obs][:timestep => len_obs => :act => :utterance => :output] = " " * observed_utterance


            # Set sample_utterance to false for all other timesteps
            for t in 1:length(observations)
                observations[t][:timestep => t => :act => :sample_utterance] = false
            end

            observations[len_obs][:timestep => len_obs => :act => :sample_utterance] = true


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

            # Run particle filter to perform online goal inference
            n_samples = 40
            pf_state = sips(
                n_samples,  observations;
                init_args=(init_strata=goal_strata,),
                callback=callback
            );

            plan_str=show(rollout_sol(domain, planner, pf_state.traces[4][:timestep => 4 => :env], pf_state.traces[4][:timestep => 4 => :agent => :plan].sol, pf_state.traces[4][:timestep => 4 => :agent =>:goal]))
        end
    end
end
# Set problem to load

# Load domain and problem


# Initialize state

#--- Goal Inference Setup ---#

# Specify possible goals


# Define uniform prior over possible goals



# planner = RTDP(heuristic=heuristic, n_rollouts=100) 



spec = convert(Specification, agent_state.goal_state)
# Rollout planning solution to get future plan
future_plan = rollout_sol(domain, planner, state, sol, spec)

# Extract goal probabilities
# goal_probs = reduce(hcat, callback.logger.data[:goal_probs])

# # Extract log likelihoods of observed utterance
# utterance_addr = :timestep => 4 => :act => :utterance => :output
# sample_utterance_addr = :timestep => 4 => :act => :sample_utterance
# sel = Gen.select(utterance_addr, sample_utterance_addr)
# utterance_logprobs = map(pf_state.traces) do trace
#     return project(trace, sel)
# end

# # Set initial state probabilities to goal posterior given utterance
# utterance_probs = GenParticleFilters.softmax(utterance_logprobs)
# goal_probs[:, 1] = utterance_probs

# # Extract animation
# anim = callback.record.animation

# # Create goal inference storyboard
# times = splitpoints[index]
# storyboard = render_storyboard(
#     anim, times;
#     subtitles = ["Human: $(observed_utterance)", 
#                  fill("...", length(times)-1)...],
#     xlabels = ["t = $t" for t in times],
#     xlabelsize = 20, subtitlesize = 24
# );
# storyboard_goal_lines!(storyboard, goal_probs, times, show_legend=true)
