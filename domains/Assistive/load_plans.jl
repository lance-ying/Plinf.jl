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
            push!(annotation_idxs, length(plan) + 1)
        else
            push!(plan, parse_pddl(line))
        end
    end
    return plan, annotations, annotation_idxs
end

"Load utterance-annotated plan dataset from a directory."
function load_plan_dataset(dir::AbstractString)
    paths = readdir(dir)
    filter!(path -> endswith(path, ".pddl"), paths)
    plans = Dict{String, Vector{Term}}()
    utterances = Dict{String, String}()
    splitpoints = Dict{String, Vector{Int}}()
    for path in paths
        name = splitext(path)[1]
        plan, annotations, annotation_idxs = load_plan(joinpath(dir, path))
        plans[name] = plan
        utterances[name] = annotations[1]
        splitpoints[name] = annotation_idxs
    end
    return plans, utterances, splitpoints
end
