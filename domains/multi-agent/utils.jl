using DataStructures: OrderedDict
using PDDLViz: RGBA, to_color, set_alpha
using Base: @kwdef

import SymbolicPlanners: compute, get_goal_terms

"Returns the color of an object."
function get_obj_color(state::State, obj::Const)
    for color in PDDL.get_objects(state, :color)
        if state[Compound(:iscolor, Term[obj, color])]
            return color
        end
    end
    return Const(:none)
end

"Returns the location of an object."
function get_obj_loc(state::State, obj::Const; check_has::Bool=false)
    x = state[Compound(:xloc, Term[obj])]
    y = state[Compound(:yloc, Term[obj])]
    # Check if object is held by an agent, and return agent's location if so
    if check_has && PDDL.get_objtype(state, obj) in (:gem, :key)
        agents = (PDDL.get_objects(state, :human)...,
                  PDDL.get_objects(state, :robot)...)
        for agent in agents
            if state[Compound(:has, Term[agent, obj])]
                x, y = get_obj_loc(state, agent)
                break
            end
        end
    end
    return (x, y)
end
    
"""
    GoalManhattan

Custom relaxed distance heuristic to goal objects. Estimates the cost of 
collecting all goal objects by computing the distance between all goal objects
and the agent, then returning the minimum distance plus the number of remaining
goals to satisfy.
"""
struct GoalManhattan <: Heuristic end

function compute(heuristic::GoalManhattan,
                 domain::Domain, state::State, spec::Specification)
  goals = get_goal_terms(spec)
  has_goals = [g for g in goals if g.name == :has]
  n_agents = length(PDDL.get_objects(state, :human)) +
             length(PDDL.get_objects(state, :robot))
  noop_cost = spec isa MinActionCosts ? spec.costs[:noop] : 1
  dists = map(has_goals) do goal
      if state[goal] return 0 end
      agent, item = goal.args
      item_loc = get_obj_loc(state, item; check_has=true)
      agent_loc = get_obj_loc(state, agent)
      agent_item_dist = sum(abs.(agent_loc .- item_loc))
      min_other_dist = Inf
      for other in PDDL.get_objects(domain, state, :agent)
          other == agent && continue
          other_loc = get_obj_loc(state, other)
          other_dist = agent_item_dist
          if !state[Compound(:has, Term[other, item])]
              other_item_dist = sum(abs.(other_loc .- item_loc))
              other_dist += other_item_dist * (n_agents - 1) + 1
          end
          min_other_dist = min(min_other_dist, other_dist)
      end
      agent_dist = agent_item_dist * (1 + noop_cost * (n_agents - 1))
      return min(agent_dist, min_other_dist)
  end
  min_dist = length(dists) > 0 ? minimum(dists) : 0
  return min_dist
end

"""
    RelaxedMazeDist([planner::Planner])

Custom relaxed distance heuristic. Estimates the cost of achieving the goal 
by removing all doors from the state, then computing the length of the plan 
to achieve the goal in the relaxed state.

A `planner` can specified to compute the relaxed plan. By default this is
`AStarPlanner(heuristic=GoalManhattan())`.
"""
function RelaxedMazeDist()
    planner = AStarPlanner(GoalManhattan())
    return RelaxedMazeDist(planner)
end

function RelaxedMazeDist(planner::Planner)
    heuristic = PlannerHeuristic(planner, s_transform=unlock_doors)
    heuristic = memoized(heuristic)
    return heuristic
end

"Unlocks all doors in the state."
function unlock_doors(state::State)
    state = copy(state)
    for d in PDDL.get_objects(state, :door)
        state[Compound(:locked, Term[d])] = false
    end
    return state
end

"""
    DKGCombinedCallback(renderer, domain; kwargs...)

Convenience constructor for a combined particle filter callback that 
logs data and visualizes inference for the doors, keys and gems domain.

# Keyword Arguments

- `goal_addr`: Trace address of goal variable.
- `goal_names`: Names of goals.
- `goal_colors`: Colors of goals.
- `obs_trajectory = nothing`: Ground truth / observed trajectory.
- `print_goal_probs = true`: Whether to print goal probabilities.
- `render = true`: Whether to render the gridworld.
- `inference_overlay = true`: Whether to render inference overlay.
- `plot_goal_bars = false`: Whether to plot goal probabilities as a bar chart.
- `plot_goal_lines = false`: Whether to plot goal probabilities over time.
- `record = false`: Whether to record the figure.
- `sleep = 0.2`: Time to sleep between frames.
- `framerate = 5`: Framerate of recorded video.
- `format = "mp4"`: Format of recorded video.
"""    
function DKGCombinedCallback(
    renderer::GridworldRenderer, domain::Domain;
    goal_addr = :init => :agent => :goal => :goal,
    goal_names = ["(has gem1)", "(has gem2)", "(has gem3)"],
    goal_colors = PDDLViz.colorschemes[:vibrant][1:length(goal_names)],
    obs_trajectory = nothing,
    print_goal_probs::Bool = true,
    render::Bool = true,
    inference_overlay = true,
    plot_goal_bars::Bool = false,
    plot_goal_lines::Bool = false,
    record::Bool = false,
    sleep::Real = 0.2,
    framerate = 5,
    format = "mp4"
)
    callbacks = OrderedDict{Symbol, SIPSCallback}()
    n_goals = length(goal_names)
    # Construct data logger callback
    callbacks[:logger] = DataLoggerCallback(
        t = (t, pf) -> t::Int,
        goal_probs = pf -> probvec(pf, goal_addr, 1:n_goals)::Vector{Float64},
        lml_est = pf -> log_ml_estimate(pf)::Float64,
    )
    # Construct print callback
    if print_goal_probs
        callbacks[:print] = PrintStatsCallback(
            (goal_addr, 1:n_goals);
            header="t\t" * join(goal_names, "\t") * "\n"
        )
    end
    # Construct render callback
    if render
        figure = Figure(resolution=(600, 700))
        if inference_overlay
            function trace_color_fn(tr)
                goal_idx = tr[goal_addr]
                return goal_colors[goal_idx]
            end
            overlay = DKGInferenceOverlay(trace_color_fn=trace_color_fn)
        end
        callbacks[:render] = RenderCallback(
            renderer, figure[1, 1], domain;
            trajectory=obs_trajectory, trail_length=10,
            overlay = inference_overlay ? overlay : nothing
        )
    end
    # Construct plotting callbacks
    if plot_goal_bars || plot_goal_lines
        if render
            resize!(figure, (1200, 700))
        else
            figure = Figure(resolution=(600, 700))
        end
        side_layout = GridLayout(figure[1, 2])
    end
    if plot_goal_bars
        callbacks[:goal_bars] = BarPlotCallback(
            side_layout[1, 1],
            pf -> probvec(pf, goal_addr, 1:n_goals)::Vector{Float64};
            color = goal_colors,
            axis = (xlabel="Goal", ylabel = "Probability",
                    limits=(nothing, (0, 1)), 
                    xticks=(1:length(goals), goal_names))
        )
    end
    if plot_goal_lines
        callbacks[:goal_lines] = SeriesPlotCallback(
            side_layout[2, 1],
            callbacks[:logger], 
            :goal_probs, # Look up :goal_probs variable
            ps -> reduce(hcat, ps); # Convert vectors to matrix for plotting
            color = goal_colors, labels=goal_names,
            axis = (xlabel="Time", ylabel = "Probability",
                    limits=((1, nothing), (0, 1)))
        )
    end
    # Construct recording callback
    if record
        callbacks[:record] = RecordCallback(figure, framerate=framerate,
                                            format=format)
    end
    # Display figure
    if render || plot_goal_bars || plot_goal_lines
        display(figure)
    end
    # Combine all callback functions
    callback = CombinedCallback(;sleep=sleep, callbacks...)
    return callback
end

"""
    DKGInferenceOverlay(; kwargs...)

Inference overlay renderer for the doors, keys and gems domain.

# Keyword Arguments

- `show_state = false`: Whether to show the current estimated state distribution.
- `show_future_states = true`: Whether to show future predicted states.
- `max_future_steps = 50`: Maximum number of future steps to render.
- `trace_color_fn = tr -> :red`: Function to determine the color of a trace.
"""
@kwdef mutable struct DKGInferenceOverlay
    show_state::Bool = false
    show_future_states::Bool = true
    max_future_steps::Int = 50
    trace_color_fn::Function = tr -> :red
    color_obs::Vector = Observable[]
    state_obs::Vector = Observable[]
    future_obs::Vector = Observable[]
end

function (overlay::DKGInferenceOverlay)(
    canvas::Canvas, renderer::GridworldRenderer, domain::Domain,
    t::Int, obs::ChoiceMap, pf_state::ParticleFilterState
)
    traces = get_traces(pf_state)
    weights = get_norm_weights(pf_state)
    # Render future states (skip t = 0 since plans are not yet available) 
    if overlay.show_future_states && t > 0
        for (i, (tr, w)) in enumerate(zip(traces, weights))
            # Get current belief, goal, and plan
            belief_state = tr[:timestep => t => :agent => :belief]
            goal_state = tr[:timestep => t => :agent => :goal]
            plan_state = tr[:timestep => t => :agent => :plan]
            # Rollout planning solution until goal is reached
            state = convert(State, belief_state)
            spec = convert(Specification, goal_state)
            sol = plan_state.sol
            future_states = Vector{typeof(state)}()
            for _ in 1:overlay.max_future_steps
                act = best_action(sol, state)
                if ismissing(act) break end
                state = transition(domain, state, act)
                push!(future_states, state)
                if is_goal(spec, domain, state) break end
            end
            # Render or update future states
            color = overlay.trace_color_fn(tr)
            future_obs = get(overlay.future_obs, i, nothing)
            color_obs = get(overlay.color_obs, i, nothing)
            if isnothing(future_obs)
                future_obs = Observable(future_states)
                color_obs = Observable(to_color((color, w)))
                push!(overlay.future_obs, future_obs)
                push!(overlay.color_obs, color_obs)
                options = renderer.trajectory_options
                object_colors=fill(color_obs, length(options[:tracked_objects]))
                type_colors=fill(color_obs, length(options[:tracked_types]))
                render_trajectory!(
                    canvas, renderer, domain, future_obs;
                    track_markersize=0.5, agent_color=color_obs,
                    object_colors=object_colors, type_colors=type_colors
                )
            else
                future_obs[] = future_states
                color_obs[] = to_color((color, w))
            end
        end
    end
    # Render current state's agent location
    if overlay.show_state
        for (i, (tr, w)) in enumerate(zip(traces, weights))
            # Get current inferred environment state
            env_state = t == 0 ? tr[:init => :env] : tr[:timestep => t => :env]
            state = convert(State, env_state)
            # Construct or update color observable
            color = overlay.trace_color_fn(tr)
            color_obs = get(overlay.color_obs, i, nothing)
            if isnothing(color_obs)
                color_obs = Observable(to_color((color, w)))
            else
                color_obs[] = to_color((color, w))
            end
            # Render or update state
            state_obs = get(overlay.state_obs, i, nothing)
            if isnothing(state_obs)
                state_obs = Observable(state)
                push!(overlay.state_obs, state_obs)
                _trajectory = @lift [$state_obs]
                render_trajectory!(
                    canvas, renderer, domain, _trajectory;
                    agent_color=color_obs, track_markersize=0.6,
                    track_stopmarker='▣' 
                ) 
            else
                state_obs[] = state
            end
        end
    end
end

"Adds a subplot to a storyboard with a line plot of goal probabilities."
function storyboard_goal_lines!(
    storyboard::Figure, goal_probs, ts=Int[];
    goal_names = ["(has gem1)", "(has gem2)", "(has gem3)", "(has gem4)"],
    goal_colors = PDDLViz.colorschemes[:vibrant][1:length(goal_names)],
    show_legend = false
)
    n_rows, n_cols = size(storyboard.layout)
    width, height = size(storyboard.scene)
    # Add goal probability subplot
    ax, _ = series(
        storyboard[n_rows+1, 1:n_cols], goal_probs,
        color = goal_colors, labels=goal_names,
        axis = (xlabel="Time", ylabel = "Probability",
                limits=((1, size(goal_probs, 2)), (0, 1)))
    )
    # Add legend to subplot
    if show_legend
        axislegend("Goals", framevisible=false)
    end
    # Add vertical lines at timesteps
    if !isempty(ts)
        vlines!(ax, ts, color=:black, linestyle=:dash)
        positions = [(t + 0.1, 0.85) for t in ts]
        labels = ["t = $t" for t in ts]
        text!(ax, positions; text=labels, color = :black, fontsize=14)
    end
    # Resize figure to fit new plot
    rowsize!(storyboard.layout, n_rows+1, Auto(0.25))
    resize!(storyboard, (width, height * 1.3))
    return storyboard
end
