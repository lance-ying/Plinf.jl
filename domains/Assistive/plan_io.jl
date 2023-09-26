using PDDL

"""
    load_plan(path::AbstractString)
    load_plan(io::IO)

Load a comment-annotated PDDL plan from file.
"""
function load_plan(io::IO)
    str = read(io, String)
    return parse_plan(str)
end
load_plan(path::AbstractString) = open(io->load_plan(io), path)

"""
    parse_plan(str::AbstractString)

Parse a comment-annotated PDDL plan from a string.
"""
function parse_plan(str::AbstractString)
    plan = Term[]
    annotations = String[]
    annotation_idxs = Int[]
    for line in split(str, "\n")
        line = strip(line)
        if isempty(line)
            continue
        elseif line[1] == ';'
            push!(annotations, strip(line[2:end]))
            push!(annotation_idxs, length(plan))
        else
            push!(plan, parse_pddl(line))
        end
    end
    return plan, annotations, annotation_idxs
end

"""
    save_plan(path, plan, annotations, annotation_idxs)

Save a comment-annotated PDDL plan to file.
"""
function save_plan(
    path::AbstractString,
    plan::AbstractVector{<:Term},
    annotations::AbstractVector{<:AbstractString} = String[],
    annotation_idxs::AbstractVector{Int} = Int[],
)
    str = write_plan(plan, annotations, annotation_idxs)
    open(path, "w") do io
        write(io, str)
    end
    return path
end

"""
    write_plan(plan, annotations, annotation_idxs)

Write a comment-annotated PDDL plan to a string.
"""
function write_plan(
    plan::AbstractVector{<:Term},
    annotations::AbstractVector{<:AbstractString} = String[],
    annotation_idxs::AbstractVector{Int} = Int[],
)
    str = ""
    if 0 in annotation_idxs
        j = findfirst(==(0), annotation_idxs)
        annotation = annotations[j]  
        str *= "; $annotation\n"
    end
    for (i, term) in enumerate(plan)
        str *= write_pddl(term) * "\n"
        if i in annotation_idxs
            j = findfirst(==(i), annotation_idxs)
            annotation = annotations[j]  
            str *= "; $annotation\n"
        end
    end
    return str
end

"""
    load_plan_dataset(dir::AbstractString)

Load utterance-annotated plan dataset from a directory.
"""
function load_plan_dataset(dir::AbstractString)
    paths = readdir(dir)
    filter!(path -> endswith(path, ".pddl"), paths)
    names = String[]
    plans = Dict{String, Vector{Term}}()
    utterances = Dict{String, Vector{String}}()
    utterance_times = Dict{String, Vector{Int}}()
    for path in paths
        name = splitext(path)[1]
        push!(names, name)
        plan, annotations, annotation_idxs = load_plan(joinpath(dir, path))
        plans[name] = plan
        utterances[name] = annotations
        utterance_times[name] = annotation_idxs
    end
    sort!(names, by = x -> parse.(Int, match(r"\D*(\d+)\w?\.(\d+)\..*", x).captures))
    return names, plans, utterances, utterance_times
end