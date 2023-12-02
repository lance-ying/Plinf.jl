using PDDL, SymbolicPlanners
using Gen, GenGPT3
using IterTools
using Random
using StatsBase

include("utils.jl")

# Example translations from salient actions to instructions/requests
utterance_examples = [
    # Single assistant actions (no predicates)
    ("(grab you plate1 l)",
     "Can you get a plate?"),
    ("(grab you cheese1 l)",
     "Can you go get the cheese?"),
    ("(grab you cutleryfork1 l)",
     "We need a fork."),
    # Multiple assistant actions (distinct)
    ("(grab you cutleryfork1 l) (grab you cutleryknife1 l)",
     "Can you get me a fork and knife?"),
    ("(grab you carrot1 l) (grab you onion1 l)",
     "Hand me the veggies."),
    ("(grab you juice1 l) (grab you waterglass1 l)",
     "Give me juice and a glass."),
    # Multiple assistant actions (combined)
    ("(grab you cutleryfork1 l) (grab you cutleryfork2 l)",
     "Go get two forks"),
    ("(grab you plate1 l) (grab you plate2 l)",
     "Go find two plates"),
    ("(grab you plate1 l) (grab you plate2 l) (grab you plate3 l) (grab you bowl1 l) (grab you bowl2 l) (grab you bowl3 l)",
     "Can you go find three plates and bowls?"),
    ("(grab you waterglass1 l) (grab you waterglass2 l) (grab you waterglass3 l)",
     "Could you get the waterglasses?"),
    # Joint actions
    ("(grab me plate1 l)(grab me plate2 l) (grab you bowl1 l)(grab you bowl2 l)",
     "I will find two plates. Can you get the bowls?"),
    ("(grab me cutleryfork1 l) (grab me cutleryfork2 l) (grab me cutleryknife1 l) (grab me cutleryknife2 l)",
     "We need some cutlery for 2 people. I'm picking up forks, can you get knives?"),
    ("(grab me chefknife1 l) (grab you carrot1 l)",
     "Can you get the carrot from the fridge while I get the knife?")
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
    args_to_vars = Dict{Const, Const}()
    type_count = Dict{Symbol, Int}()
    actions = map(command.actions) do act
        args = map(act.args) do arg
            arg in ignore && return arg
            arg isa Const || return arg
            var = get!(args_to_vars, arg) do
                type = Symbol(String(arg.name)[1:end-1])
                count = get(type_count, type, 0) + 1
                type_count[type] = count
                if length(String(arg.name))==1
                    return Var(Symbol(uppercasefirst(string(type))))
                end
                name = Symbol(string(type), count)
                return Const(name)
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
            if arg.name == :L
                push!(types, :location)
            end
            # arg isa Var || continue
            # push!(vars, arg)
            # type = Symbol(lowercase(string(arg.name)[1:end-1]))
            # push!(types, type)
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
    return g_commands
end

"Convert an action command to one or more goal formulas."
function command_to_goals(
    command::ActionCommand;
    speaker = pddl"(human)",
    listener = pddl"(robot)",
    act_goal_map = Dict(
        :grab => act -> Compound(:delivered, Term[act.args[2]]),
        # :handover => act -> Compound(:and,
        #     [Compound(:has, Term[act.args[2], act.args[3]]),
        #      Compound(Symbol("pickedup-by"), Term[act.args[1], act.args[3]])]
        # ),
        # :unlock => act -> Compound(:and, 
        #     [Compound(Symbol("unlocked-by"), Term[act.args[1], act.args[3]]),
        #      Compound(Symbol("unlocked-with"), Term[act.args[2], act.args[3]])]
        # )
    )
)
    # Extract variables and infer their types
    vars = Var[]
    types = Symbol[]
    for act in command.actions
        for arg in act.args
            if arg.name == :L
                push!(types, :location)
            end
            # arg isa Var || continue
            # push!(vars, arg)
            # type = Symbol(lowercase(string(arg.name)[1:end-1]))
            # push!(types, type)
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
    obj_arg_idxs = Dict(:grab => 2)
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
    obj_arg_idxs = Dict(:grab => 2)
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
    # focal_objs = Term[]
    # command = pronouns_to_names(command)
    # print(focal_vars)
    # print(command)
    # for cmd_act in command.actions
    #     for act in plan
    #         unifiers = PDDL.unify(cmd_act, act)
            
    #         isnothing(unifiers) && continue
    #         for var in focal_vars
    #             print(unifiers)
    #             if haskey(unifiers, var)
    #                 push!(focal_objs, unifiers[var])
    #             end
    #         end
    #     end
    # end
    # print(focal_objs)
    return focal_vars
end

"Extract salient actions (with predicate modifiers) from a plan."
function extract_salient_actions(
    domain::Domain, state::State, plan::AbstractVector{<:Term};
    salient_actions = [
        (:grab, 1, 2),
    ],
    salient_predicates = []
)
    actions = Term[]
    agents = Const[]
    predicates = Vector{Term}[]
    for act in plan # Extract manually-defined salient actions
        for (name, agent_idx, obj_idx) in salient_actions
            if act.name == name
                push!(actions, act)
                push!(agents, act.args[agent_idx])
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
    end
    return actions, agents, predicates
end

"Enumerate all possible salient actions (with predicate modifiers) in a state."
function enumerate_salient_actions(
    domain::Domain, state::State;
    salient_actions = [
        (:grab, 1, 2),
    ],
    salient_agents = [
        pddl"(robot)"
    ],
    salient_predicates = [
    ]
)
    actions = Term[]
    agents = Const[]
    predicates = Vector{Term}[]
    statics = PDDL.infer_static_fluents(domain)
    # Enumerate over salient actions
    for (name, agent_idx, obj_idx) in salient_actions
        act_schema = PDDL.get_action(domain, name)
        # Enumerate over all possible groundings
        arg1_iter = PDDL.get_objects(domain, state, PDDL.get_argtypes(act_schema)[1])
        arg2_iter = PDDL.get_objects(domain, state, PDDL.get_argtypes(act_schema)[2])
        args_iter = IterTools.product(arg1_iter, arg2_iter)
        for args in args_iter
            # Skip actions with non-salient agents
            agent = args[agent_idx]
            agent in salient_agents || continue
            # Construct action term
            args = [args[1], args[2], Var(:L)]
            act = Compound(name, collect(Term, args))
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
    max_commanded_actions = 4,
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
            # if exclude_action_chains
            #     skip = false
            #     objects = Set{Term}()
            #     for act in @view(actions[idxs]), arg in act.args
            #         (arg == pddl"(you)" || arg == pddl"(me)") && continue
            #         if arg in objects
            #             skip = true
            #             break
            #         end
            #         push!(objects, arg)
            #     end
            #     skip && continue
            # end
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

# Define GPT-3 mixture generative function
gpt3_mixture = GPT3Mixture(model="text-davinci-002", stop="\n", max_tokens=64, temperature = 0.5)

"Extract unnormalized logprobs of utterance conditioned on each command."
function extract_utterance_scores_per_command(trace::Trace, addr=:utterance)
    # Extract GPT-3 mixture trace over utterances
    utt_trace = trace.trie.leaf_nodes[addr].subtrace_or_retval
    return utt_trace.scores
end

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
    # print(prompts)
    # println()
    utterance ~ gpt3_mixture(prompts)
    return utterance
end

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
    plan = rollout_sol(domain, planner, state, sol, spec)
     # Extract salient actions and predicates from plan
    actions, agents, predicates = extract_salient_actions(domain, state, plan)
     # Enumerate action commands
    commands = ActionCommand[]
    actions = map(actions) do act
        names_to_pronouns(act; speaker=pddl"(human)",listener=pddl"(robot)")
    end
    # print("Actions",actions)
    for idxs in 1:length(actions)
        cmd = ActionCommand(actions[idxs:idxs], Term[])
        push!(commands, cmd)
    end

    #  commands = enumerate_commands(actions, agents, predicates)
     commands = lift_command.(commands, [state])

    #  print(commands)
    #  println()
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
    # print(prompts)
    utterance ~ gpt3_mixture(prompts, probs)
    return utterance
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