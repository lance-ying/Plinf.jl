using PDDL, Printf
using SymbolicPlanners, Plinf
using Gen, GenParticleFilters
using PDDLViz, GLMakie, CairoMakie
using CSV, DataFrames

include("utils.jl")
include("ascii.jl")
include("render.jl")
include("load_plans.jl")

# Register PDDL array theory
PDDL.Arrays.register!()

# Load domain and problems
domain = load_domain(joinpath(@__DIR__, "domain.pddl"))
problem_names = ["p$i" for i in 1:6]
problems = [load_problem(joinpath(@__DIR__, s * ".pddl")) for s in problem_names]

# Load plans
plans, utterances, splitpoints = load_plan_dataset(joinpath(@__DIR__, "plans"))

# Load model results
df_path = joinpath(@__DIR__, "inference_no_language_results.csv")
model_no_lang_df = CSV.read(df_path, DataFrame)
model_no_lang_df = filter!(r -> r.temperature == 1.0, model_no_lang_df)
df_path = joinpath(@__DIR__, "inference_language_results.csv")
model_lang_df = CSV.read(df_path, DataFrame)
model_lang_df = filter!(r -> r.temperature == 1.0, model_lang_df)

# Load human results
df_path = joinpath(@__DIR__, "human_no_language_results.csv")
human_no_lang_df = CSV.read(df_path, DataFrame, header=[1, 2])
rename!(human_no_lang_df, 1 => :problem_id, 2 => :goal_id, 3 => :timestep)
df_path = joinpath(@__DIR__, "human_language_results.csv")
human_lang_df = CSV.read(df_path, DataFrame, header=[1, 2])
rename!(human_lang_df, 1 => :problem_id, 2 => :goal_id, 3 => :timestep)

# Loop over problems
plan_ids = sort!(collect(keys(plans)))
for plan_index in plan_ids
    m = match(r"p(\d+)_g(\d+)", plan_index).captures
    problem_id = parse(Int, m[1])
    goal_id = parse(Int, m[2])

    problem_id < 3 && continue

    plan = plans[plan_index]
    utterance = utterances[plan_index]
    times = splitpoints[plan_index]

    # Filter out results for this plan stimuli
    filter_fn = r -> r.problem_id == problem_id && r.goal_id == goal_id && (r.is_judgment_point || r.timestep == length(plan))
    model_no_lang_sub_df = filter(filter_fn, model_no_lang_df)
    model_lang_sub_df = filter(filter_fn, model_lang_df)

    filter_fn = r -> r.problem_id == problem_id && r.goal_id == goal_id
    human_no_lang_sub_df = filter(filter_fn, human_no_lang_df)
    human_lang_sub_df = filter(filter_fn, human_lang_df)

    # Use GLMakie for rendering
    GLMakie.activate!()

    # Initialize state, and set renderer resolution to fit state grid
    state = initstate(domain, problems[problem_id])
    grid = state[pddl"(walls)"]
    height, width = size(grid)
    renderer.resolution = (width * 100 + 40, (height + 2) * 100 + 200)

    # Initialize canvas for animation
    canvas = new_canvas(renderer)
    canvas = anim_initialize!(
        canvas, renderer, domain, state;
        caption = "Human: " * utterance, caption_size = 40,
        trail_length = 10
    )
    canvas.blocks[2].titlesize = 30
    canvas.blocks[3].titlesize = 30
    display(canvas)

    # Animate plan
    anim = anim_plan!(
        canvas, renderer, domain, state, plan;
        trail_length=10,
        format = "gif",
        captions=Dict(1 => "Human: " * utterance, times[2] => "...")
    )
    anim_dir = mkpath(joinpath(@__DIR__, "animations"))
    save(joinpath(anim_dir, "anim_p$(problem_id)_g$(goal_id).gif"), anim)

    # Switch to CairoMakie for plotting
    CairoMakie.activate!()

    # Plot storyboard
    storyboard = render_storyboard(
        anim, times;
        xlabels = ["t = $t" for t in times],
        xlabelsize = 36, xlabelfont = :italic
    );

    # Plot human goal probabilities given language and actions
    goal_probs = Matrix(human_lang_sub_df[:, r"goal_probs_\d+_mean"])
    final_goal_probs = zeros(4)
    final_goal_probs[goal_id] = 1.0
    goal_probs = vcat(goal_probs, final_goal_probs')
    storyboard_goal_lines!(
        storyboard, goal_probs', [times; length(plan) + 1],
        goal_names = ["Red Gem", "Yellow Gem", "Blue Gem", "Green Gem"],
        goal_colors = gem_colors,
        ts_linewidth = 4, ts_fontsize = 30,
        marker = :circle, markersize = 24, strokewidth = 1.0,
        linewidth = 4, linestyle = [:dash, :solid, :dashdot, :dashdotdot], 
        ax_args = (xlabelsize = 36, xticklabelsize = 24,
                ylabelsize = 36, yticklabelsize = 24)
    )

    # Add error ribbons
    goal_probs_std = Matrix(human_lang_sub_df[:, r"goal_probs_\d+_std"])
    goal_probs_count = Matrix(human_lang_sub_df[:, r"goal_probs_\d+_count"])
    goal_probs_sem = goal_probs_std ./ sqrt.(goal_probs_count)
    goal_probs_ci = 1.96 * goal_probs_sem
    goal_probs_ci = vcat(goal_probs_ci, zeros(4)')
    upper = min.(goal_probs .+ goal_probs_ci, 1.0)
    lower = max.(goal_probs .- goal_probs_ci, 0.0)

    axis = content(storyboard[2, :])
    for (j, (l, u)) in enumerate(zip(eachcol(lower), eachcol(upper)))
        band!(axis, [times; length(plan) + 1], l, u, color=(gem_colors[j], 0.2))
    end

    # Add legend
    legend = axislegend("Goals", framevisible=false, position=:rc,
                        titlesize=30, labelsize=24)

    # Add axis title
    axis = content(storyboard[2, :])
    axis.title = "Human Inferences (Actions & Instructions)"
    axis.titlesize = 44
    axis.titlefont = :regular
    axis.titlealign = :left
    axis.xlabel = ""

    # Plot model goal probabilities given language and actions
    goal_probs = Matrix(model_lang_sub_df[:, r"goal_probs_\d+"])
    storyboard_goal_lines!(
        storyboard, goal_probs', [times; length(plan) + 1],
        goal_names = ["Red Gem", "Yellow Gem", "Blue Gem", "Green Gem"],
        goal_colors = gem_colors,
        ts_linewidth = 4, ts_fontsize = 30,
        marker = :circle, markersize = 24, strokewidth = 1.0,
        linewidth = 4, linestyle = [:dash, :solid, :dashdot, :dashdotdot], 
        ax_args = (xlabelsize = 36, xticklabelsize = 24,
                ylabelsize = 36, yticklabelsize = 24)
    )

    # Add axis title
    axis = content(storyboard[3, :])
    axis.title = "Model Inferences (Actions & Instructions)"
    axis.titlesize = 44
    axis.titlefont = :regular
    axis.titlealign = :left
    axis.xlabel = ""

    # Plot human goal probabilities given actions only
    goal_probs = Matrix(human_no_lang_sub_df[:, r"goal_probs_\d+_mean"])
    final_goal_probs = zeros(4)
    final_goal_probs[goal_id] = 1.0
    goal_probs = vcat(goal_probs, final_goal_probs')
    storyboard_goal_lines!(
        storyboard, goal_probs', [times; length(plan) + 1],
        goal_names = ["Red Gem", "Yellow Gem", "Blue Gem", "Green Gem"],
        goal_colors = gem_colors,
        ts_linewidth = 4, ts_fontsize = 30,
        marker = :circle, markersize = 24, strokewidth = 1.0,
        linewidth = 4, linestyle = [:dash, :solid, :dashdot, :dashdotdot], 
        ax_args = (xlabelsize = 36, xticklabelsize = 24,
                ylabelsize = 36, yticklabelsize = 24)
    )

    # Add error ribbons
    goal_probs_std = Matrix(human_no_lang_sub_df[:, r"goal_probs_\d+_std"])
    goal_probs_count = Matrix(human_no_lang_sub_df[:, r"goal_probs_\d+_count"])
    goal_probs_sem = goal_probs_std ./ sqrt.(goal_probs_count)
    goal_probs_ci = 1.96 * goal_probs_sem
    goal_probs_ci = vcat(goal_probs_ci, zeros(4)')
    upper = min.(goal_probs .+ goal_probs_ci, 1.0)
    lower = max.(goal_probs .- goal_probs_ci, 0.0)

    axis = content(storyboard[4, :])
    for (j, (l, u)) in enumerate(zip(eachcol(lower), eachcol(upper)))
        band!(axis, [times; length(plan) + 1], l, u, color=(gem_colors[j], 0.2))
    end

    # Add axis title
    axis = content(storyboard[4, :])
    axis.title = "Human Inferences (Actions Only)"
    axis.titlesize = 44
    axis.titlefont = :regular
    axis.titlealign = :left
    axis.xlabel = ""

    # Plot model goal probabilities given actions only
    goal_probs = Matrix(model_no_lang_sub_df[:, r"goal_probs_\d+"])
    storyboard_goal_lines!(
        storyboard, goal_probs', [times; length(plan) + 1],
        goal_names = ["Red Gem", "Yellow Gem", "Blue Gem", "Green Gem"],
        goal_colors = gem_colors,
        ts_linewidth = 4, ts_fontsize = 30,
        marker = :circle, markersize = 24, strokewidth = 1.0,
        linewidth = 4, linestyle = [:dash, :solid, :dashdot, :dashdotdot], 
        ax_args = (xlabelsize = 36, xticklabelsize = 24,
                ylabelsize = 36, yticklabelsize = 24)
    )

    # Add axis title
    axis = content(storyboard[5, :])
    axis.title = "Model Inferences (Actions Only)"
    axis.titlesize = 44
    axis.titlefont = :regular
    axis.titlealign = :left
    axis.xlabel = "Time"

    width, _ = size(storyboard.scene)
    height = renderer.resolution[2] * (1.0 + 0.375 * 4)
    resize!(storyboard, (width, height))

    # Add figure title
    figtitle = Label(storyboard[0, :], "Problem $problem_id: Goal $goal_id")
    figtitle.fontsize = 60
    figtitle.font = :bold
    figtitle.halign = :left

    # Save figure
    mkpath(joinpath(@__DIR__, "figures"))
    path = joinpath(@__DIR__, "figures", "storyboard_p$(problem_id)_g$(goal_id)")
    save(path * ".png", storyboard)
    save(path * ".pdf", storyboard)
end

# Select featured stimuli for plotting

problem_id = 1
goal_id = 3
plan_index = "p1_g3"

plan = plans[plan_index]
utterance = utterances[plan_index]
times = splitpoints[plan_index]

# Filter out results for this plan stimuli
filter_fn = r -> r.problem_id == problem_id && r.goal_id == goal_id && (r.is_judgment_point || r.timestep == length(plan))
model_no_lang_sub_df = filter(filter_fn, model_no_lang_df)
model_lang_sub_df = filter(filter_fn, model_lang_df)

filter_fn = r -> r.problem_id == problem_id && r.goal_id == goal_id
human_no_lang_sub_df = filter(filter_fn, human_no_lang_df)
human_lang_sub_df = filter(filter_fn, human_lang_df)

# Use GLMakie for rendering
GLMakie.activate!()

# Initialize state, and set renderer resolution to fit state grid
state = initstate(domain, problems[problem_id])
grid = state[pddl"(walls)"]
height, width = size(grid)
renderer.resolution = (width * 100 + 40, (height + 2) * 100 + 200)

# Initialize canvas for animation
canvas = new_canvas(renderer)
canvas = anim_initialize!(
    canvas, renderer, domain, state;
    caption = "Human: " * utterance, caption_size = 38, caption_font = :bold_italic,
    trail_length = 10
)
canvas.blocks[2].titlesize = 30
canvas.blocks[3].titlesize = 30

# Animate plan
anim = anim_plan!(
    canvas, renderer, domain, state, plan;
    trail_length=10,
    format = "gif",
    captions=Dict(1 => "Human: " * utterance, times[2] => "...")
)

# Switch to CairoMakie for plotting
CairoMakie.activate!()

# Plot storyboard
storyboard = render_storyboard(
    anim, times;
    subtitles = [
        "(i) Human gives an instruction.",
        "(ii) Robot moves left, human goes up.",
        "(iii) Human moves right, robot gets blue key.",
        "(iv) Robot unlocks blue door.",
        "(v) Human moves towards blue gem."
    ], 
    subtitlesize = 44, subtitlefont = :regular,
    xlabels = ["t = $t" for t in times],
    xlabelsize = 40, xlabelfont = :italic
)

# Plot human goal probabilities given language and actions
goal_probs = Matrix(human_lang_sub_df[:, r"goal_probs_\d+_mean"])
final_goal_probs = zeros(4)
final_goal_probs[goal_id] = 1.0
goal_probs = vcat(goal_probs, final_goal_probs')
storyboard_goal_lines!(
    storyboard, goal_probs', [times; length(plan) + 1],
    goal_names = ["Red Gem", "Yellow Gem", "Blue Gem", "Green Gem"],
    goal_colors = gem_colors,
    ts_linewidth = 4, ts_fontsize = 36,
    linewidth = 4, linestyle = [:dash, :solid, :dashdot, :dashdotdot],
    marker = :circle, markersize = 24, strokewidth = 1.0,
    ax_args = (xlabelsize = 40, xticklabelsize = 24,
               ylabelsize = 40, yticklabelsize = 24)
)

# Add error ribbons
goal_probs_std = Matrix(human_lang_sub_df[:, r"goal_probs_\d+_std"])
goal_probs_count = Matrix(human_lang_sub_df[:, r"goal_probs_\d+_count"])
goal_probs_sem = goal_probs_std ./ sqrt.(goal_probs_count)
goal_probs_ci = 1.96 * goal_probs_sem
goal_probs_ci = vcat(goal_probs_ci, zeros(4)')
upper = min.(goal_probs .+ goal_probs_ci, 1.0)
lower = max.(goal_probs .- goal_probs_ci, 0.0)

axis = content(storyboard[2, :])
for (j, (l, u)) in enumerate(zip(eachcol(lower), eachcol(upper)))
    band!(axis, [times; length(plan) + 1], l, u, color=(gem_colors[j], 0.2))
end

# Add legend
legend = axislegend("Goals", framevisible=false, position=:rc,
                    titlesize=40, labelsize=36)

# Add axis title
axis = content(storyboard[2, :])
axis.title = "Human Inferences (Actions & Instructions)"
axis.titlesize = 60
axis.titlefont = :regular
axis.titlealign = :left
axis.xlabel = ""

# Plot model goal probabilities given language and actions
goal_probs = Matrix(model_lang_sub_df[:, r"goal_probs_\d+"])
storyboard_goal_lines!(
    storyboard, goal_probs', [times; length(plan) + 1],
    goal_names = ["Red Gem", "Yellow Gem", "Blue Gem", "Green Gem"],
    goal_colors = gem_colors,
    ts_linewidth = 4, ts_fontsize = 36,
    linewidth = 4, linestyle = [:dash, :solid, :dashdot, :dashdotdot],
    marker = :circle, markersize = 24, strokewidth = 1.0,
    ax_args = (xlabelsize = 40, xticklabelsize = 24,
               ylabelsize = 40, yticklabelsize = 24)
)

# Add axis title
axis = content(storyboard[3, :])
axis.title = "Model Inferences (Actions & Instructions)"
axis.titlesize = 60
axis.titlefont = :regular
axis.titlealign = :left
axis.xlabel = ""

# Plot human goal probabilities given actions only
goal_probs = Matrix(human_no_lang_sub_df[:, r"goal_probs_\d+_mean"])
final_goal_probs = zeros(4)
final_goal_probs[goal_id] = 1.0
goal_probs = vcat(goal_probs, final_goal_probs')
storyboard_goal_lines!(
    storyboard, goal_probs', [times; length(plan) + 1],
    goal_names = ["Red Gem", "Yellow Gem", "Blue Gem", "Green Gem"],
    goal_colors = gem_colors,
    ts_linewidth = 4, ts_fontsize = 36,
    linewidth = 4, linestyle = [:dash, :solid, :dashdot, :dashdotdot], 
    marker = :circle, markersize = 24, strokewidth = 1.0,
    ax_args = (xlabelsize = 40, xticklabelsize = 24,
               ylabelsize = 40, yticklabelsize = 24)
)

# Add error ribbons
goal_probs_std = Matrix(human_no_lang_sub_df[:, r"goal_probs_\d+_std"])
goal_probs_count = Matrix(human_no_lang_sub_df[:, r"goal_probs_\d+_count"])
goal_probs_sem = goal_probs_std ./ sqrt.(goal_probs_count)
goal_probs_ci = 1.96 * goal_probs_sem
goal_probs_ci = vcat(goal_probs_ci, zeros(4)')
upper = min.(goal_probs .+ goal_probs_ci, 1.0)
lower = max.(goal_probs .- goal_probs_ci, 0.0)

axis = content(storyboard[4, :])
for (j, (l, u)) in enumerate(zip(eachcol(lower), eachcol(upper)))
    band!(axis, [times; length(plan) + 1], l, u, color=(gem_colors[j], 0.2))
end

# Add axis title
axis = content(storyboard[4, :])
axis.title = "Human Inferences (Actions Only)"
axis.titlesize = 60
axis.titlefont = :regular
axis.titlealign = :left
axis.xlabel = ""

# Plot model goal probabilities given actions only
goal_probs = Matrix(model_no_lang_sub_df[:, r"goal_probs_\d+"])
storyboard_goal_lines!(
    storyboard, goal_probs', [times; length(plan) + 1],
    goal_names = ["Red Gem", "Yellow Gem", "Blue Gem", "Green Gem"],
    goal_colors = gem_colors,
    ts_linewidth = 4, ts_fontsize = 36,
    linewidth = 4, linestyle = [:dash, :solid, :dashdot, :dashdotdot], 
    marker = :circle, markersize = 24, strokewidth = 1.0,
    ax_args = (xlabelsize = 40, xticklabelsize = 24,
               ylabelsize = 40, yticklabelsize = 24)
)

# Add axis title
axis = content(storyboard[5, :])
axis.title = "Model Inferences (Actions Only)"
axis.titlesize = 60
axis.titlefont = :regular
axis.titlealign = :left
axis.xlabel = "Time"

width, height = size(storyboard.scene)
resize!(storyboard, (width, 3200))

# Add figure title
figtitle = Label(
    storyboard[0, :],
    "Bayesian Multi-Agent Goal Inference from Actions and Instructions"
)
figtitle.fontsize = 72
figtitle.font = :bold
figtitle.halign = :left
figtitle.text = "Bayesian Multi-Agent Goal Inference from Actions and Instructions"

storyboard

# Save figure
mkpath(joinpath(@__DIR__, "figures"))
path = joinpath(@__DIR__, "figures", "featured_storyboard")
save(path * ".png", storyboard)
save(path * ".pdf", storyboard)
