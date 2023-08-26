using Gen, GenGPT3
using PDDL, SymbolicPlanners

include("utils.jl")

# Define GPT-3 generative function
gpt3 = GPT3GF(model="curie", stop="\n")

# Example translations from salient actions to instructions/requests
# utterance_examples = """
# Input: (unlockr robot key2 door1) where (iscolor door1 blue)
# Output: Can you unlock the blue door?
# Input: (handover robot human key2) (pickuph human key1) where (iscolor key1 red) (iscolor key2 blue)
# Output: I will get the red key, can you pick up the blue one?
# Input: (unlockr robot key3 door2) (unlockr robot key2 door3) where (iscolor door2 green) (iscolor door3 yellow)
# Output: Help me unlock the green and the yellow doors.
# Input: (pickupr robot key3) where (iscolor key3 yellow)
# Output: Please pick up the yellow key.
# Input: (unlockr robot key1 door1) where (iscolor door1 red)
# Output: Can you unlock the red door for me?
# Input: (pickuph human key3) (unlockr robot key1 door1) where (iscolor key3 blue) (iscolor door1 red)
# Output: I will get the blue key, can you unlock the red door for me?
# Input: (pickuph human key3) (handover robot human key1) where (iscolor key3 blue) (iscolor key1 green)
# Output: Can you pick up the green key while I get the blue one?
# Input: (handover robot human key1) (handover robot human key2) where (iscolor key1 green) (iscolor key2 red)
# Output: Can you pass me the green and the red key?
# """
utterance_examples = """
Input: (unlockr robot key2 door1) where (iscolor door1 blue)
Output: Can you unlock the blue door?
Input: (handover robot human key2) (pickuph human key1) where (iscolor key1 red) (iscolor key2 blue)
Output: I will get the red key, can you pick up the blue one?
Input: (unlockr robot key3 door2) (unlockr robot key2 door3) where (iscolor door2 green) (iscolor door3 yellow)
Output: Help me unlock the green and the yellow doors.
Input: (pickupr robot key3) where (iscolor key3 yellow)
Output: Please pick up the yellow key.
Input: (unlockr robot key1 door1) where (iscolor door1 red)
Output: Can you unlock the red door for me?
Input: (pickuph human key3) (unlockr robot key1 door1) where (iscolor key3 blue) (iscolor door1 red)
Output: I will get the blue key, can you unlock the red door for me?
Input: (pickuph human key3) (handover robot human key1) where (iscolor key3 blue) (iscolor key1 green)
Output: Can you pick up the green key while I get the blue one?
Input: (handover robot human key1) (handover robot human key2) where (iscolor key1 green) (iscolor key2 red)
Output: Can you pass me the green and the red key?
"""


literal_prompt = """
Input: (exist ?k1)(and (pickupr robot ?k1)(iscolor ?k1 blue))
Output: Can you get the blue key?
Input: (exist ?k1)(and (pickupr robot ?k1)(iscolor ?k1 blue))
Output: I will get the red key, can you get the blue key?
Input: (exist ?d1)(and (unlock robot ?d1)(iscolor ?d1 blue))
Output: Can you open the blue door?
Input: (exist ?d1)(and (unlocked ?d1)(iscolor ?d1 blue))
Output: I will find a red key, can you unlock the blue door?
Input: (exist ?k1 ?k2)(and (has robot ?k1)(iscolor ?k1 red)(has robot ?k2)(iscolor ?k2 blue))
Output: Can you pass me the red and blue key?
Input: (exist ?d1 ?d2)(and (unlocked ?d1)(unlocked ?d2)(iscolor ?d1 blue)(iscolor ?d2 blue))
Output: Can you get the blue doors?
Input: (exist ?d1 ?d2)(and (unlocked ?d1)(unlocked ?d2)(iscolor ?d1 red)(iscolor ?d2 blue))
Output: Can you get the red and blue doors?
"""


literal_prompt_VH = """
Input: (and (has robot cutleryknife1)(has robot cutleryknife2))
Output: Can you get two knives?
Input: (and (has robot cutleryfork1)(has robot cutleryfork2)(has robot cutleryfork2))
Output: Can you get two knives?
Input: (exist ?k1)(and (has robot ?k1)(iscolor ?k1 blue))
Output: I will get the red key, can you get the blue key?
Input: (exist ?d1)(and (unlocked ?d1)(iscolor ?d1 blue))
Output: Can you open the blue door?
Input: (exist ?d1)(and (unlocked ?d1)(iscolor ?d1 blue))
Output: I will find a red key, can you unlock the blue door?
Input: (exist ?k1 ?k2)(and (has robot ?k1)(iscolor ?k1 red)(has robot ?k2)(iscolor ?k2 blue))
Output: Can you pass me the red and blue key?
Input: (exist ?d1 ?d2)(and (unlocked ?d1)(unlocked ?d2)(iscolor ?d1 blue)(iscolor ?d2 blue))
Output: Can you get the blue doors?
Input: (exist ?d1 ?d2)(and (unlocked ?d1)(unlocked ?d2)(iscolor ?d1 red)(iscolor ?d2 blue))
Output: Can you get the red and blue doors?
"""

"Extract salient actions (with predicate modifiers) from a plan."
function extract_salient_actions(state::State, plan::AbstractVector{<:Term})
    actions = Term[]
    predicates = Term[]
    for act in plan # Extract manually-defined salient actions
        if act.name == :handover # Check for handover actions
            item = act.args[3]
            item_color = get_obj_color(state, item)
            color_pred = Compound(:iscolor, Term[item, item_color])
            push!(predicates, color_pred)
            push!(actions, act)
        elseif act.name == :unlockr# Check for robot unlocking actions
            door = act.args[3]
            door_color = get_obj_color(state, door)
            color_pred = Compound(:iscolor, Term[door, door_color])
            push!(predicates, color_pred)
            push!(actions, act)
        end
        if act.name == :pickuph # Check for handover actions
            item = act.args[2]
            print(item)
            # if !(item in ["gem1", "gem2","gem3", "gem4"])
            item_color = get_obj_color(state, item)
            color_pred = Compound(:iscolor, Term[item, item_color])
            if string(item_color)!="none"
            push!(predicates, color_pred)
            push!(actions, act)
            # end
            end
        end
    end
    return actions, predicates
end

function extract_goals()

end

"Construct utterance prompt from salient actions and predicates."
function construct_utterance_prompt(
    actions::Vector{Term}, predicates::Vector{Term},
)
    if isempty(actions) return "\n" end # Empty prompt if nothing to communicate
    action_str = join(write_pddl.(actions), " ")
    predicate_str = join(write_pddl.(predicates), " ")
    prompt = utterance_examples * "Input: $action_str where $predicate_str\n"
    prompt *= "Output:"
    return prompt
end

"Utterance model for human instructions using an LLM string likelihood."
@gen function utterance_model(t, agent_state, env_state, act,
                              domain, planner)
    # Extract environment state, plann state and goal specification
    state = env_state
    sol = agent_state.plan_state.sol
    spec = convert(Specification, agent_state.goal_state)
    # Rollout planning solution to get future plan
    future_plan = rollout_sol(domain, planner, state, sol, spec)
    # Extract salient actions and predicates from plan
    actions, predicates = extract_salient_actions(state, future_plan)
    # end
    # Decide whether utterance should be communicated
    p_utterance = isempty(actions) ? 0.05 : 0.95
    sample_utterance ~ bernoulli(p_utterance)
    # Generate utterance from GPT-3
    if sample_utterance
        prompt = construct_utterance_prompt(actions, predicates)
        utterance ~ gpt3(prompt)
        # print(utterance)
        return strip(utterance)
    else
        return ""
    end
end
