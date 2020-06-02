export labeled_cat, labeled_unif, flip, block_words_RNN_conversion

"Unzips an array of tuples to a tuple of arrays."
unzip(a) = map(x->getfield.(a, x), fieldnames(eltype(a)))

"Pad / truncate vector to specified length."
pad_vector(v::Vector, n::Int) =
    length(v) < n ? [v; fill(v[end], n - length(v))] : v[1:n]

"Repeat arguments so they can be passed to a Map combinator."
repeat_args(args::Tuple, n::Int) = [fill(a, n) for a in obs_args]

"Normalize log weights."
lognorm(w) = w .- logsumexp(w)

"Convert vector of scores to probabiities."
softmax(score) =
    (exp_score = exp.(score .- maximum(score)); exp_score ./ sum(exp_score))

"Return output type of distribution."
dist_type(d::Distribution{T}) where {T} = T

"Labeled categorical distribution."
@dist labeled_cat(labels, probs) = labels[categorical(probs)]

"Labeled uniform distribution."
@dist labeled_unif(labels) = labels[uniform_discrete(1, length(labels))]

"Boolean corruption noise."
@dist flip(val::Bool, prob::Float64) = bernoulli((1-val)*prob + val*(1-prob))

"Sample functions passed as args to a static generative function."
@gen function sample_fn(fn, args::Tuple=())
    if isa(fn, GenerativeFunction)
        return @trace(fn(args...))
    elseif isa(fn, Function)
        return fn(args...)
    else
        return fn
    end
end

function get_arg_dims(argtypes, type_counts)
    dims = []
    for (i, argtype) in enumerate(argtypes)
        # Assuming one object can't be passed as multiple inputs to a predicate
        dim = type_counts[argtype] - count(isequal(argtype), argtypes[1:i-1])
        push!(dims, dim)
    end
    return dims
end

#= Within the ordered objects, finds the index position of the given object among
the other objects of the given type =#
function get_object_type_index(ordered_objects, type_map, type, object_name)
    count = 1
    for object in ordered_objects
        if object == object_name
            return count
        end
        if type_map[object] == type
            count += 1
        end
    end
    return nothing
end

function calculate_vector_sublengths(predtypes, predicate_names, type_counts)
    vec_sublens = [1]
    for name in predicate_names
        argtypes = predtypes[name]
        # Making a single boolean if the predicate takes no arguments
        if length(argtypes) == 0
            dims = [1]
        else
            dims = get_arg_dims(argtypes, type_counts)
        end

        push!(vec_sublens, vec_sublens[length(vec_sublens)] + prod(dims))
    end
    return vec_sublens
end

function set_bools(fact::Compound, base_idx, ordered_objects, type_map, type_counts, predtypes)
    args = fact.args
    argtypes = predtypes[fact.name]
    ordered_object_types = [type_map[obj_name] for obj_name in ordered_objects]
    arg_order_idxs = [findfirst(isequal(arg.name), ordered_objects) for arg in args]
    num_args = length(args)
    idx = base_idx
    terms = []
    for (i, arg) in enumerate(args)
        object_name = arg.name
        type = type_map[object_name]
        baseline = get_object_type_index(ordered_objects, type_map, type, object_name)
        # Get the number of other args of the same type and prior to the current
        # arg alphabetically before the current arg in order of the ordered objects
        repeat_count = 0
        for (j, arg_order_idx) in enumerate(arg_order_idxs[1:i-1])
            if type_map[args[j].name] == type && arg_order_idx < arg_order_idxs[i]
                repeat_count += 1
            end
        end
        #repeat_count = count(isequal(type), ordered_object_types[1:args_ordered_idx-1])
        push!(terms, baseline - repeat_count)
    end
    for (i, term) in enumerate(terms)
        dims = get_arg_dims(argtypes, type_counts)
        remaining = dims[i+1:length(dims)]
        multiplicand = 1
        if length(remaining) != 0
            multiplicand = prod(remaining)
        end
        idx += (term - 1) * multiplicand
    end
    return idx
end

function set_bools(fact::Const, base_idx, ordered_objects, type_map, type_counts, predtypes)
    return base_idx
end

"Convert from block-words PDDL state representation to RNN input representation"
function block_words_RNN_conversion(domain::Domain, state::State)
    predicates, predtypes, fluents = domain.predicates, domain.predtypes, domain.functions
    types, facts = state.types, state.facts

    # Map each object name to its type name
    type_map = Dict(term.args[1].name => term.name for term in types)

    # Get the number of each type of object
    type_counts = Dict(type.name => 0 for type in types)
    for type in types
        type_counts[type.name] += 1
    end

    # Alphabetized names of predicates, objects, and fluents
    ordered_predicates = sort(collect(keys(predicates)))
    println(ordered_predicates)
    ordered_objects = sort([term.args[1].name for term in types])
    println(ordered_objects)
    ordered_fluents = sort(collect(keys(fluents)))

    pred_start_idxs = calculate_vector_sublengths(predtypes, ordered_predicates,
                                                  type_counts)
    vec_len = pred_start_idxs[length(pred_start_idxs)] + length(ordered_fluents) - 1
    encoding = zeros(vec_len)
    for fact in facts
        println(fact)
        base_idx = pred_start_idxs[findfirst(isequal(fact.name), ordered_predicates)]
        idx = set_bools(fact, base_idx, ordered_objects, type_map, type_counts, predtypes)
        println(idx)
        encoding[idx] = 1
    end
    for (fluent, val) in fluents
        idx += 1
        encoding[idx] = val
    end
    return encoding
end

"Convert from gems, keys, doors PDDL state representation to RNN input representation"
function gems_keys_doors_RNN_conversion(state::State)
    encoding = []
    types = state.types
    facts = state.facts
    fluents = state.fluents
    return encoding
end
