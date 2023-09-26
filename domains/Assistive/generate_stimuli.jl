using PDDL
using SymbolicPlanners
using PDDLViz
using JSON3

PDDL.Arrays.@register()

include("plan_io.jl")
include("utils.jl")
include("render.jl")

renderer_dict = Dict(
    "none" => renderer,
    "keys" => renderer_labeled_keys,
    "doors" => renderer_labeled_doors,
)

"Generates stimulus animation for an utterance-annotated plan."
function generate_stim_anim(
    path::Union{AbstractString, Nothing},
    domain::Domain,
    state::State,
    plan::AbstractVector{<:Term},
    utterances::AbstractVector{<:AbstractString} = String[],
    utterance_times::AbstractVector{Int} = Int[];
    assist_type = "none",
    renderer = renderer_dict[assist_type],
    caption_prefix = "Human: ",
    caption_quotes = "\"",
    caption_line_length = 40,
    caption_lines = 1,
    caption_color = :black,
    caption_dur = 4,
    caption_size = 28,
    framerate = 3,
    trail_length = 15,
    format = "gif",
    loop = -1,
)
    # Determine number of lines
    for u in utterances
        len = length(u) + length(caption_prefix) + 2*length(caption_quotes)
        n_lines = (len-1) ÷ caption_line_length + 1
        caption_lines = max(caption_lines, n_lines)
    end
    # Preprocess utterances into multiple lines
    delims = ['?', '!', '.', ',', ';', ' ']
    utterances = map(utterances) do u
        u = caption_prefix * caption_quotes * u * caption_quotes
        lines = String[]
        l_start = 1
        count = 0
        while l_start <= length(u) && count < caption_lines
            count += 1
            l_stop_max = min(l_start + caption_line_length - 1, length(u))
            if l_stop_max >= length(u)
                push!(lines, u[l_start:end])
                break
            end
            l_stop = nothing
            for d in delims
                l_stop = findlast(d, u[l_start:l_stop_max])
                !isnothing(l_stop) && break
            end
            l_stop = isnothing(l_stop) ? l_stop_max : l_stop + l_start - 1
            push!(lines, u[l_start:l_stop])
            l_start = l_stop + 1
        end
        if length(lines) < caption_lines
            append!(lines, fill("", caption_lines - length(lines)))
        end
        u = join(lines, "\n")
        return u
    end
    # Construct caption dictionary
    blank_str = join(fill("...", caption_lines), "\n")
    if isempty(utterances)
        captions = Dict(1 => blank_str)
        caption_color = :white
    else
        captions = Dict(1 => blank_str)
        for (t, u) in zip(utterance_times, utterances)
            captions[t+1] = u
            if !any(t+1 <= k <= t+caption_dur for k in keys(captions))
                captions[t+1+caption_dur] = blank_str
            end
        end
    end
    # Animate plan
    anim = anim_plan(renderer, domain, state, plan;
                     captions, caption_color, caption_size,
                     trail_length, framerate, format, loop)
    # Save animation
    if !isnothing(path)
        save(path, anim)
    end
    return anim
end

function generate_stim_anim(
    path::Union{AbstractString, Nothing},
    domain::Domain,
    problem::Problem,
    plan::AbstractVector{<:Term},
    utterances::AbstractVector{<:AbstractString} = String[],
    utterance_times::AbstractVector{Int} = Int[];
    kwargs...
)
    state = initstate(domain, problem)
    return generate_stim_anim(path, domain, state, plan,
                              utterances, utterance_times; kwargs...)
end

"Generates stimulus animation set for an utterance-annotated plan."
function generate_stim_anim_set(
    path::Union{AbstractString, Nothing},
    domain::Domain,
    problem::Problem,
    plan::AbstractVector{<:Term},
    completion::AbstractVector{<:Term},
    utterances::AbstractVector{<:AbstractString} = String[],
    utterance_times::AbstractVector{Int} = Int[];
    assist_type = "none",
    framerate = 3,
    kwargs...
)
    # Determine number of lines
    caption_lines = get(kwargs, :caption_lines, 1)
    caption_line_length = get(kwargs, :caption_line_length, 40)
    caption_prefix = get(kwargs, :caption_prefix, "Human: ")
    caption_quotes = get(kwargs, :caption_quotes, "\"")
    for u in utterances
        len = length(u) + length(caption_prefix) + 2*length(caption_quotes)
        n_lines = (len-1) ÷ caption_line_length + 1
        caption_lines = max(caption_lines, n_lines)
    end
    name, ext = splitext(path)
    state = initstate(domain, problem)
    # Generate initial frame
    init_path = name * "_0_init" * ext
    println("Generating $init_path...")
    init_anim = generate_stim_anim(
        init_path, domain, state, Term[], utterances, utterance_times;
        assist_type, caption_lines, kwargs...
    )
    # Generate plan animation
    plan_path = name * "_1_observed" * ext
    println("Generating $plan_path...")
    plan_anim = generate_stim_anim(
        plan_path, domain, state, plan, utterances, utterance_times;
        assist_type, framerate, caption_lines, kwargs...
    )
    # Generate completion animation
    state = PDDL.simulate(PDDL.EndStateSimulator(), domain, state, plan)
    completion_path = name * "_2_completed" * ext
    println("Generating $completion_path...")
    completion_anim = generate_stim_anim(
        completion_path, domain, state, completion;
        assist_type, framerate=framerate+1, caption_lines, kwargs...
    )
    return [init_anim, plan_anim, completion_anim]
end

"Generate stimuli JSON dictionary."
function generate_stim_json(
    name::String,
    domain::Domain,
    problem::Problem,
    plan::AbstractVector{<:Term},
    completion::AbstractVector{<:Term},
    utterances::AbstractVector{<:AbstractString} = String[];
    assist_type = match(r".*\.(\w+)", name).captures[1]
)
    state = initstate(domain, problem)
    if assist_type == "keys"
        option_count = length(PDDL.get_objects(state, :key))
    else
        option_count = length(PDDL.get_objects(state, :door))
    end
    goal_obj = completion[end].args[2]
    goal_idx = parse(Int, string(goal_obj)[end]) - 1
    best_option = Int[]
    for act in completion
        if assist_type == "keys"
            act.name != :pickup && continue
            obj = act.args[2]
        elseif assist_type == "doors"
            act.name != :unlock && continue
            obj = act.args[3]
        end
        obj_idx = parse(Int, string(obj)[end])
        push!(best_option, obj_idx)
    end
    json = (
        name = name,
        images = [
            "$(name)_0_init.gif",
            "$(name)_1_observed.gif",
            "$(name)_2_completed.gif",
        ],
        type = assist_type,
        utterance = isempty(utterances) ? "" : utterances[1],
        timesteps = length(plan),
        option_count = option_count,
        goal = [goal_idx],
        best_option = [best_option]
    )
    return json
end

"Read stimulus inputs from plan and problem datasets."
function read_stim_inputs(
    name::String, problems, plans, completions, utterances, utterance_times
)
    m = match(r"(\d+\w?).(\d+)\.(\w+)", name)
    problem_name = m.captures[1]
    assist_type = m.captures[3]
    problem = problems[problem_name]
    plan = plans[name]
    completion = completions[name]
    utts = utterances[name]
    utt_times = utterance_times[name]
    return problem, plan, completion, utts, utt_times, assist_type
end

# Define directory paths
PROBLEM_DIR = joinpath(@__DIR__, "problems")
PLAN_DIR = joinpath(@__DIR__, "plans", "observed")
COMPLETION_DIR = joinpath(@__DIR__, "plans", "completed")
STIMULI_DIR = joinpath(@__DIR__, "stimuli")

# Load domain
domain = load_domain(joinpath(@__DIR__, "domain.pddl"))

# Load problems
problems = Dict{String, Problem}()
for path in readdir(PROBLEM_DIR)
    name, ext = splitext(path)
    ext == ".pddl" || continue
    problems[name] = load_problem(joinpath(PROBLEM_DIR, path))
end

# Load utterance-annotated plans and completions
pnames, plans, utterances, utterance_times = load_plan_dataset(PLAN_DIR)
pnames, completions, _, _ = load_plan_dataset(COMPLETION_DIR)

# Generate stimuli animations
for name in pnames
    problem, plan, completion, utts, utt_times, assist_type =
        read_stim_inputs(name, problems, plans, completions,
                         utterances, utterance_times)

    path = joinpath(STIMULI_DIR, name * ".gif")
    generate_stim_anim_set(path, domain, problem, plan, completion,
                           utts, utt_times; assist_type)
    GC.gc()
end

# Generate stimuli metadata
all_metadata = []
for name in pnames
    problem, plan, completion, utts, utt_times, assist_type =
        read_stim_inputs(name, problems, plans, completions,
                         utterances, utterance_times)
    json = generate_stim_json(name, domain, problem, plan, completion, utts;
                              assist_type)
    push!(all_metadata, json)
end
metadata_path = joinpath(STIMULI_DIR, "stimuli.json")
open(metadata_path, "w") do io
    JSON3.pretty(io, all_metadata)
end
