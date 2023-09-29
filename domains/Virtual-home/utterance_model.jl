using PDDL, SymbolicPlanners
using Gen, GenGPT3
using IterTools
using Random

include("utils.jl")

# Example translations from salient actions to instructions/requests
utterance_examples = [
    # Single assistant actions (no predicates)
    ("(takeout you plate1)",
     "Can you get a plate?"),
    ("(takeout you cheese1)",
     "Can you go get the cheese?"),
    ("(takeout you cutleryfork1)",
     "We need a fork."),
    # Multiple assistant actions (distinct)
    ("(takeout you cutleryfork1) (takeout you cutleryknife1)",
     "Can you get me a fork and knife?"),
    ("(takeout you carrot1) (takeout you onion1)",
     "Hand me the veggies."),
    ("(takeout you juice1) (takeout you waterglass1)",
     "Give me juice and a glass."),
    # Multiple assistant actions (combined)
    ("(takeout you cutleryfork1) (takeout you cutleryfork2)",
     "Go get two forks"),
    ("(takeout you plate1) (takeout you plate2) (takeout you plate3) (takeout you bowl1) (takeout you bowl2) (takeout you bowl3)",
     "Can you go find three plates and bowls?"),
    ("(takeout you waterglass1) (takeout you waterglass2) (takeout you waterglass3)",
     "Could you get the waterglasses?"),
    # Joint actions
    ("(takeout me plate1)(takeout me plate2) (takeout you bowl1)(takeout you bowl2)",
     "I will find two plates. Can you get the bowls?"),
    ("(takeout me cutleryfork1) (takeout me cutleryfork2) (takeout me cutleryknife1) (takeout me cutleryknife2)",
     "We need some cutlery for 2 people. I'm picking up forks, can you get knives?"),
    ("(takeout me chefknife1) (takeout you carrot)",
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

function Base.show(io::IO, ::MIME"text/plain", command::ActionCommand)
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

"Extract salient actions (with predicate modifiers) from a plan."
function extract_salient_actions(
    domain::Domain, state::State, plan::AbstractVector{<:Term};
    salient_actions = [
        (:takeout, 1, 2),
    ],
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
        args = map(act.args) do arg
            if arg == speaker
                pddl"(me)"
            elseif arg == listener
                pddl"(you)"
            else
                arg
            end
        end
        return Compound(act.name, args)
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

# Define GPT-3 mixture generative function
gpt3_mixture = GPT3Mixture(model="curie", stop="\n", max_tokens=64)

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
    commands = enumerate_commands(actions, agents, predicates)
    # Construct prompts for each action command
    if isempty(commands)
        prompts = ["\n"]
    else
        prompts = map(commands) do command
            construct_utterance_prompt(command, examples)
        end
    end
    # Sample utterance from GPT-3 mixture over prompts
    utterance ~ gpt3_mixture(prompts)
    return utterance
end
