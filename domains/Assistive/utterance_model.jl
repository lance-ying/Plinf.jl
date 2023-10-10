using PDDL, SymbolicPlanners
using Gen, GenGPT3
using IterTools
using Random
using StatsBase

include("utils.jl")
include("heuristics.jl")

# Example translations from salient actions to instructions/requests
utterance_examples = [
    # Single assistant actions (no predicates)
    ("(pickup you key1)",
     "Get the key over there."),
    ("(handover you me key1)",
     "Can you hand me that key?"),
    ("(unlock you key1 door1)",
     "Unlock this door for me please."),
    # Single assistant actions (with predicates)
    ("(pickup you key1) where (iscolor key1 yellow)",
     "Please pick up the yellow key."),
    ("(handover you me key1) where (iscolor key1 blue)",
     "Could you pass me the blue key?"),
    ("(unlock you key1 door1) where (iscolor door1 blue)",
     "Can you open the blue door?"),
    # Multiple assistant actions (distinct)
    ("(unlock you key1 door1) (handover you me key2)",
     "Would you unlock the door and bring me that key?"),
    ("(handover you me key1) (handover you me key2) where (iscolor key1 green) (iscolor key2 red)",
     "Hand me the green and red keys."),
    ("(unlock you key1 door1) (unlock you key2 door2) where (iscolor door1 green) (iscolor door2 yellow)",
     "Help me unlock the green and yellow doors."),
    # Multiple assistant actions (combined)
    ("(pickup you key1) (pickup you key2) where (iscolor key1 green) (iscolor key2 green)",
     "Can you go and get the green keys?"),
    ("(handover you me key1) (handover you me key2) where (iscolor key1 red) (iscolor key2 red)",
     "Can you pass me two red keys?"),
    ("(unlock you key1 door1) (unlock you key2 door2) (unlock you key3 door3)",
     "Could you unlock these three doors for me?"),
    # Joint actions (all distinct)
    ("(pickup me key1) (pickup you key2) where (iscolor key1 red) (iscolor key2 blue)",
     "I will get the red key, can you pick up the blue one?"),
    ("(unlock you key1 door1) (pickup me key2) where (iscolor door1 green) (iscolor key2 blue)",
     "I'm getting the blue key, can you open the green door?"),
    ("(pickup you key1) (pickup me key2) where (iscolor key1 yellow) (iscolor key2 blue)",
     "Can you pick up the yellow key while I get the blue one?"),
    # Joint actions (some combined)
    ("(pickup me key1) (handover you me key2) (handover you me key3) where (iscolor key1 blue) (iscolor key2 yellow) (iscolor key3 yellow)",
     "Can you hand me the yellow keys? I'm getting the blue one."),
    ("(pickup me key1) (pickup me key2) (unlock you key3 door1) (unlock you key4 door2)",
     "I'm picking up these keys, can you unlock those doors?"),
    ("(handover you me key1) (handover you me key2) (pickup me ?gem1) where (iscolor key1 red) (iscolor key2 red) (iscolor gem1 green)",
     "Pass me the red keys, I'm going for the green gem.")
]

Random.seed!(0)
shuffled_examples = shuffle(utterance_examples)

"""
    ActionCommand

A sequence of one or more actions to be executed, with optional predicate
modifiers for action arguments.
"""
struct ActionCommand
    "Actions to be executed."
    actions::Vector{Term}
    "Predicate modifiers for action arguments."
    predicates::Vector{Term}
end

Base.hash(command::ActionCommand, h::UInt) =
    hash(command.predicates, hash(command.actions, h))
Base.:(==)(cmd1::ActionCommand, cmd2::ActionCommand) =
    cmd1.actions == cmd2.actions && cmd1.predicates == cmd2.predicates
Base.issetequal(cmd1::ActionCommand, cmd2::ActionCommand) =
    issetequal(cmd1.actions, cmd2.actions) && issetequal(cmd1.predicates, cmd2.predicates)

function Base.show(io::IO, ::MIME"text/plain", command::ActionCommand)
    # Note that this filters out the ? token for variables before printing
    action_str = join(write_pddl.(command.actions), " ")
    action_str = filter(!=('?'), action_str)
    print(io, action_str)
    if !isempty(command.predicates)
        print(io, " where ")
        pred_str = join(write_pddl.(command.predicates), " ")
        pred_str = filter(!=('?'), pred_str)
        print(io, pred_str)
    end
end

"Replace arguments in an action command with variables."
function lift_command(
    command::ActionCommand, state::State;
    ignore = [pddl"(me)", pddl"(you)"],
)
    args_to_vars = Dict{Const, Var}()
    type_count = Dict{Symbol, Int}()
    actions = map(command.actions) do act
        args = map(act.args) do arg
            arg in ignore && return arg
            arg isa Const || return arg
            var = get!(args_to_vars, arg) do
                type = PDDL.get_objtype(state, arg)
                count = get(type_count, type, 0) + 1
                type_count[type] = count
                name = Symbol(uppercasefirst(string(type)), count)
                return Var(name)
            end
            return var
        end
        return Compound(act.name, args)
    end
    predicates = map(command.predicates) do pred
        pred isa Compound || return pred
        args = map(pred.args) do arg
            arg isa Const || return arg
            return get(args_to_vars, arg, arg)
        end
        return Compound(pred.name, args)
    end
    return ActionCommand(actions, predicates)
end

"Grounds a lifted action command into a set of ground action commands."
function ground_command(
    command::ActionCommand, domain::Domain, state::State
)
    # Extract variables and infer their types
    vars = Var[]
    types = Symbol[]
    for act in command.actions
        for arg in act.args
            arg isa Var || continue
            push!(vars, arg)
            type = Symbol(lowercase(string(arg.name)[1:end-1]))
            push!(types, type)
        end
    end
    # Find all possible groundings
    typeconds = Term[Compound(ty, Term[var]) for (ty, var) in zip(types, vars)]
    neqconds = Term[Compound(:not, [Compound(:(==), Term[vars[i], vars[j]])])
                    for i in eachindex(vars) for j in 1:i-1]
    conds = [command.predicates; neqconds; typeconds]
    substs = satisfiers(domain, state, conds)
    g_commands = ActionCommand[]
    for s in substs
        actions = map(act -> PDDL.substitute(act, s), command.actions)
        predicates = map(pred -> PDDL.substitute(pred, s), command.predicates)
        push!(g_commands, ActionCommand(actions, predicates))
    end
    # Remove duplicate groundings according to set equality
    unique_g_commands = ActionCommand[]
    for g_cmd in g_commands
        if !any(issetequal(g_cmd, ug_cmd) for ug_cmd in unique_g_commands)
            push!(unique_g_commands, g_cmd)
        end
    end
    return unique_g_commands
end

"Statically check if a ground action command is possible in a domain and state."
function is_command_possible(
    command::ActionCommand, domain::Domain, state::State;
    speaker = pddl"(human)", listener = pddl"(robot)",
    statics = PDDL.infer_static_fluents(domain)
)
    possible = true
    command = pronouns_to_names(command; speaker, listener)
    for act in command.actions
        # Substitute and simplify precondition
        act_schema = PDDL.get_action(domain, act.name)
        act_vars = PDDL.get_argvars(act_schema)
        subst = PDDL.Subst(var => val for (var, val) in zip(act_vars, act.args))
        precond = PDDL.substitute(PDDL.get_precond(act_schema), subst)
        # Append predicates
        preconds = append!(PDDL.flatten_conjs(precond), command.predicates)
        precond = Compound(:and, preconds)
        # Simplify static terms
        precond = PDDL.dequantify(precond, domain, state)
        precond = PDDL.simplify_statics(precond, domain, state, statics)
        possible = precond.name != false
    end
    return possible
end

"Convert an action command to one or more goal formulas."
function command_to_goals(
    command::ActionCommand;
    speaker = pddl"(human)",
    listener = pddl"(robot)",
    act_goal_map = Dict(
        :pickup => act -> Compound(:has, Term[act.args[1], act.args[2]]),
        :handover => act -> Compound(:and,
            [Compound(:has, Term[act.args[2], act.args[3]]),
             Compound(Symbol("pickedup-by"), Term[act.args[1], act.args[3]])]
        ),
        :unlock => act -> Compound(:and, 
            [Compound(Symbol("unlocked-by"), Term[act.args[1], act.args[3]]),
             Compound(Symbol("unlocked-with"), Term[act.args[2], act.args[3]])]
        )
    )
)
    # Extract variables and infer their types
    vars = Var[]
    types = Symbol[]
    for act in command.actions
        for arg in act.args
            arg isa Var || continue
            push!(vars, arg)
            type = Symbol(lowercase(string(arg.name)[1:end-1]))
            push!(types, type)
        end
    end
    # Convert each action to goal
    goals = map(command.actions) do action
        action = pronouns_to_names(action; speaker, listener)
        goal = act_goal_map[action.name](action)
        return PDDL.flatten_conjs(goal)        
        if PDDL.is_ground(goal)
            return PDDL.flatten_conjs(goal)
        end
        # Costruct existential quantifier
        body = Compound(:and, pushfirst!(constraints, goal))
        return Term[Compound(:exists, Term[typecond, body])]
    end
    goals = reduce(vcat, goals)
    # Convert to existential quantifier if variables are present
    if !isempty(vars)
        # Find predicate constraints which include some variables
        constraints = filter(pred -> any(arg in vars for arg in pred.args),
                             command.predicates)
        # Construct type constraints
        typeconds = Term[Compound(ty, Term[v]) for (ty, v) in zip(types, vars)]
        typecond = length(typeconds) > 1 ?
            Compound(:and, typeconds) : typeconds[1]
        neqconds = Term[Compound(:not, [Compound(:(==), Term[vars[i], vars[j]])])
        for i in eachindex(vars) for j in 1:i-1]
        # Construct existential quantifier
        body = Compound(:and, append!(goals, neqconds, constraints))
        goals = [Compound(:exists, Term[typecond, body])]
    end
    return goals
end

"Replace speaker and listener names with pronouns."
function names_to_pronouns(
    command::ActionCommand; speaker = pddl"(human)", listener = pddl"(robot)"
)
    actions = map(command.actions) do act
        names_to_pronouns(act; speaker, listener)
    end
    predicates = map(command.predicates) do pred
        names_to_pronouns(pred; speaker, listener)
    end
    return ActionCommand(actions, predicates)
end

function names_to_pronouns(
    term::Compound; speaker = pddl"(human)", listener = pddl"(robot)"
)
    new_args = map(term.args) do arg
        if arg == speaker
            pddl"(me)"
        elseif arg == listener
            pddl"(you)"
        else
            names_to_pronouns(arg; speaker, listener)
        end
    end
    return Compound(term.name, new_args)
end
names_to_pronouns(term::Var; kwargs...) = term
names_to_pronouns(term::Const; kwargs...) = term

"Replace pronouns with speaker and listener names."
function pronouns_to_names(
    command::ActionCommand; speaker = pddl"(human)", listener = pddl"(robot)"
)
    actions = map(command.actions) do act
        pronouns_to_names(act; speaker, listener)
    end
    predicates = map(command.predicates) do pred
        pronouns_to_names(pred; speaker, listener)
    end
    return ActionCommand(actions, predicates)
end

function pronouns_to_names(
    term::Compound; speaker = pddl"(human)", listener = pddl"(robot)"
)
    new_args = map(term.args) do arg
        if arg == pddl"(me)"
            speaker
        elseif arg == pddl"(you)"
            listener
        else
            pronouns_to_names(arg; speaker, listener)
        end
    end
    return Compound(term.name, new_args)
end
pronouns_to_names(term::Var; kwargs...) = term
pronouns_to_names(term::Const; kwargs...) = term

"Extract focal objects from an action command or plan."
function extract_focal_objects(
    command::ActionCommand;
    obj_arg_idxs = Dict(:pickup => 2, :handover => 3, :unlock => 3)
)
    objects = Term[]
    for act in command.actions
        act.name in keys(obj_arg_idxs) || continue
        idx = obj_arg_idxs[act.name]
        obj = act.args[idx]
        push!(objects, obj)
    end
    return unique!(objects)
end

function extract_focal_objects(
    plan::AbstractVector{<:Term};
    obj_arg_idxs = Dict(:pickup => 2, :handover => 3, :unlock => 3)
)
    focal_objs = Term[]
    for act in plan
        act.name in keys(obj_arg_idxs) || continue
        idx = obj_arg_idxs[act.name]
        obj = act.args[idx]
        push!(focal_objs, obj)
    end
    return unique!(focal_objs)
end

"Extract focal objects from a plan that matches a lifted action command."
function extract_focal_objects_from_plan(
    command::ActionCommand, plan::AbstractVector{<:Term}
)
    focal_vars = extract_focal_objects(command)
    focal_objs = Term[]
    command = pronouns_to_names(command)
    for cmd_act in command.actions
        for act in plan
            unifiers = PDDL.unify(cmd_act, act)
            isnothing(unifiers) && continue
            for var in focal_vars
                if haskey(unifiers, var)
                    push!(focal_objs, unifiers[var])
                end
            end
        end
    end
    return unique!(focal_objs)
end

"Extract salient actions (with predicate modifiers) from a plan."
function extract_salient_actions(
    domain::Domain, state::State, plan::AbstractVector{<:Term};
    salient_actions = [
        (:pickup, 1, 2),
        (:handover, 1, 3),
        (:unlock, 1, 3)
    ],
    salient_predicates = [
        (:iscolor, (d, s, o) -> get_obj_color(s, o))
    ],
    exclude_distal_actions = true,
    all_agents = PDDL.get_objects(domain, state, :agent)
)
    actions = Term[]
    agents = Const[]
    predicates = Vector{Term}[]
    # Construct room labels and connectivity graph
    if exclude_distal_actions
        room_labels = label_rooms_and_doors(domain, state)
        room_graph = construct_room_graph(domain, state, room_labels)
    end
    for act in plan # Extract manually-defined salient actions
        for (name, agent_idx, obj_idx) in salient_actions
            if act.name == name
                agent = act.args[agent_idx]
                obj = act.args[obj_idx]
                # Exclude actions about distal objects
                if exclude_distal_actions
                    is_distal = true
                    for a in all_agents
                        x, y = get_obj_loc(state, a)
                        r_agent = room_labels[y, x]
                        x, y = get_obj_loc(state, obj, check_has=true)
                        r_obj = room_labels[y, x]
                        if (r_agent == r_obj ||
                            r_obj in neighbors(room_graph, r_agent))
                            is_distal = false
                        end
                    end
                    is_distal && continue
                end
                push!(actions, act)
                push!(agents, agent)
                push!(predicates, Term[])
                for (pred_name, pred_fn) in salient_predicates
                    val = pred_fn(domain, state, obj)
                    if val != pddl"(none)"
                        pred = Compound(pred_name, Term[obj, val])
                        push!(predicates[end], pred)
                    end
                end
            end
        end
    end
    return actions, agents, predicates
end

"Enumerate all possible salient actions (with predicate modifiers) in a state."
function enumerate_salient_actions(
    domain::Domain, state::State;
    salient_actions = [
        (:pickup, 1, 2),
        (:handover, 1, 3),
        (:unlock, 1, 3)
    ],
    salient_agents = [
        pddl"(robot)"
    ],
    salient_predicates = [
        (:iscolor, (d, s, o) -> get_obj_color(s, o))
    ],
    exclude_distal_actions = true
)
    actions = Term[]
    agents = Const[]
    predicates = Vector{Term}[]
    statics = PDDL.infer_static_fluents(domain)
    # Enumerate over salient actions
    for (name, agent_idx, obj_idx) in salient_actions
        act_schema = PDDL.get_action(domain, name)
        # Enumerate over all possible groundings
        args_iter = PDDL.groundargs(domain, state, act_schema; statics)
        for args in args_iter
            # Skip actions with non-salient agents
            agent = args[agent_idx]
            agent in salient_agents || continue
            # Construct action term
            act = Compound(name, collect(Term, args))
            # Substitute and simplify precondition
            act_vars = PDDL.get_argvars(act_schema)
            subst = PDDL.Subst(var => val for (var, val) in zip(act_vars, args))
            precond = PDDL.substitute(PDDL.get_precond(act_schema), subst)
            precond = PDDL.simplify_statics(precond, domain, state, statics)
            # Skip actions that are never possible
            precond.name == false && continue
            # Add action and agent
            push!(actions, act)
            push!(agents, agent)
            # Extract predicates
            push!(predicates, Term[])
            obj = act.args[obj_idx]
            for (pred_name, pred_fn) in salient_predicates
                val = pred_fn(domain, state, obj)
                if val != pddl"(none)"
                    pred = Compound(pred_name, Term[obj, val])
                    push!(predicates[end], pred)
                end
            end
        end
    end
    return actions, agents, predicates
end

"Enumerate action commands from salient actions and predicates."
function enumerate_commands(
    actions::Vector{Term},
    agents::Vector{Const},
    predicates::Vector{Vector{Term}};
    speaker = pddl"(human)",
    listener = pddl"(robot)",
    max_commanded_actions = 3,
    max_distinct_actions = 2,
    exclude_action_chains = true,
    exclude_speaker_only_commands = true
)
    commands = ActionCommand[]
    # Replace speaker and listener names in actions
    actions = map(actions) do act
        names_to_pronouns(act; speaker, listener)
    end
    # Enumerate commands of increasing length
    max_commanded_actions = min(max_commanded_actions, length(actions))
    for n in 1:max_commanded_actions
        # Iterate over subsets of planned actions
        for idxs in IterTools.subsets(1:length(actions), n)
            # Skip subsets where all actions are speaker actions
            if exclude_speaker_only_commands
                if all(a == speaker for a in @view(agents[idxs])) continue end
            end
            # Skip subsets with too many distinct actions
            if n > max_distinct_actions
                agent_act_pairs = [(agents[i], actions[i].name) for i in idxs]
                agent_act_pairs = unique!(agent_act_pairs)
                n_distinct_actions = length(agent_act_pairs)
                if n_distinct_actions > max_distinct_actions continue end
            end
            # Skip subsets where future actions depend on previous ones
            if exclude_action_chains
                skip = false
                objects = Set{Const}()
                for act in @view(actions[idxs]), arg in act.args
                    (arg == pddl"(you)" || arg == pddl"(me)") && continue
                    if arg in objects
                        skip = true
                        break
                    end
                    push!(objects, arg)
                end
                skip && continue
            end
            # Add command without predicate modifiers
            cmd = ActionCommand(actions[idxs], Term[])
            push!(commands, cmd)
            # Skip subsets with too many distinct predicate modifiers
            if n > max_distinct_actions
                action_groups = [Int[] for _ in agent_act_pairs]
                for i in idxs
                    agent, act = agents[i], actions[i]
                    idx = findfirst(p -> p[1] == agent && p[2] == act.name,
                                    agent_act_pairs)
                    push!(action_groups[idx], i)
                end
                skip = false
                for group in action_groups
                    length(group) > 1 || continue
                    ref_predicates = map(predicates[group[1]]) do pred
                        obj, val = pred.args
                        return Compound(pred.name, Term[Var(:X), val])
                    end
                    for i in group[2:end], pred in predicates[i]
                        obj, val = pred.args
                        lifted_pred = Compound(pred.name, Term[Var(:X), val])
                        if lifted_pred ∉ ref_predicates
                            skip = true
                            break
                        end
                    end
                    skip && break
                end
                skip && continue
            end
            # Add command with predicate modifiers
            preds = reduce(vcat, @view(predicates[idxs]))
            cmd = ActionCommand(actions[idxs], preds)
            push!(commands, cmd)
        end
    end
    return commands
end

"Construct utterance prompt from an action command and previous examples."
function construct_utterance_prompt(command::ActionCommand, examples)
    # Empty prompt if nothing to communicate
    if isempty(command.actions) return "\n" end
    # Construct example string
    example_strs = ["Input: $cmd\nOutput: $utt" for (cmd, utt) in examples]
    example_str = join(example_strs, "\n")
    command_str = repr(MIME"text/plain"(), command)
    prompt = "$example_str\nInput: $command_str\nOutput:"
    return prompt
end

"Extract unnormalized logprobs of utterance conditioned on each command."
function extract_utterance_scores_per_command(trace::Trace, addr=:utterance)
    # Extract GPT-3 mixture trace over utterances
    utt_trace = trace.trie.leaf_nodes[addr].subtrace_or_retval
    return utt_trace.scores
end

"Extract command distribution from pragmatic goal inference trace."
function extract_inferred_commands(trace::Trace, t::Int)
    if t == 0
        step_trace = Gen.static_get_subtrace(trace, Val(:init))
    else
        step_trace = Gen.static_get_subtrace(trace, Val(:timestep)).subtraces[t]
    end
    act_trace = step_trace.trie[:act].subtrace_or_retval
    utt_trace = act_trace.trie[:utterance].subtrace_or_retval
    prompts = utt_trace.prompts
    commands = map(prompts) do p
        isempty(p) ? "" : split(p, "\n")[end-1]
    end
    scores = utt_trace.scores
    perm = sortperm(scores, rev=true)
    commands = commands[perm]
    scores = scores[perm]
    probs = softmax(scores)
    return commands, scores, probs
end

# Define GPT-3 mixture generative function for literal utterance model
literal_gpt3_mixture = GPT3Mixture(model="text-curie-001", stop="\n", max_tokens=64)

"Literal utterance model for human instructions using an LLM likelihood."
@gen function literal_utterance_model(
    domain::Domain, state::State,
    commands = nothing,
    examples = shuffled_examples
)
    # Enumerate commands if not already provided
    if isnothing(commands)
        actions, agents, predicates = enumerate_salient_actions(domain, state)
        commands = enumerate_commands(actions, agents, predicates)
        commands = lift_command.(commands, [state])
        unique!(commands)        
    end
    # Construct prompts for each action command
    if isempty(commands)
        prompts = ["\n"]
    else
        prompts = map(commands) do command
            construct_utterance_prompt(command, examples)
        end
    end
    # Sample utterance from GPT-3 mixture over prompts
    utterance ~ literal_gpt3_mixture(prompts)
    return utterance
end

# Define GPT-3 mixture generative function for pragmatic utterance model
pragmatic_gpt3_mixture = GPT3Mixture(model="curie", stop="\n", max_tokens=64)

"Pragmatic utterance model for human instructions using an LLM likelihood."
@gen function pragmatic_utterance_model(
    t, act_state, agent_state, env_state, act,
    domain,
    planner,
    p_speak = 0.05,
    examples = shuffled_examples
)
    # Decide whether utterance should be communicated
    speak ~ bernoulli(p_speak)
    # Return empty utterance if not speaking
    !speak && return ""
    # Extract environment state, plann state and goal specification
    state = env_state
    sol = agent_state.plan_state.sol
    spec = convert(Specification, agent_state.goal_state)
    # Rollout planning solution to get future plan
    planner = copy(planner)
    planner.max_nodes = 2^16
    plan = rollout_sol(domain, planner, state, sol, spec)
    # Extract salient actions and predicates from plan
    actions, agents, predicates = extract_salient_actions(domain, state, plan)
    # Enumerate action commands
    commands = enumerate_commands(actions, agents, predicates)
    commands = lift_command.(commands, [state])
    # Construct prompts for each unique action command
    if isempty(commands)
        prompts = ["\n"]
        probs = [1.0]
    else
        command_probs = proportionmap(commands) # Compute probabilities
        prompts = String[]
        probs = Float64[]
        for (command, prob) in command_probs
            prompt = construct_utterance_prompt(command, examples)
            push!(prompts, prompt)
            push!(probs, prob)
        end
    end
    # Sample utterance from GPT-3 mixture over prompts
    utterance ~ pragmatic_gpt3_mixture(prompts, probs)
    return utterance
end
