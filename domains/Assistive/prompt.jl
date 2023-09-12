using Gen, GenGPT3

gpt3 = GPT3GenerativeFunction(model = "text-davinci-003", max_tokens=64)
ENV["OPENAI_API_KEY"] = "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"

utterance_example = 
"""
A human and robot are collaborating to pick up keys and unlock doors.
Your task is to translate possible subgoals for robot to natural-language commands so the human can assign the subgoal to the robot.

Input: (exist (?d1 - door)(and (unlocked-by robot ?d1)(iscolor ?d1 red)))
Output: Can you unlock the red door?
Input: (exist (?d1 - door)(and (unlocked-by robot ?d1)))
Output: Can you unlock that door?
Input: (exist (?k1 - key)(and (has robot ?k1)(iscolor ?k1 blue)))
Output: I need a blue key.
Input: (exist (?k1 ?k2 - key)(and (has robot ?k1)(has robot ?k2)(iscolor ?k1 red)(iscolor ?k2 red)))
Output: Could you help me find 2 red keys?

"""


goal_set = generate_goal()
goal_prob_total=Dict()


for scenario_id in collect(keys(utterance_literal_dict))

    utterance = utterance_literal_dict[scenario_id]
    goal_prob = []
    for g in goalset
        prompt = utterance_example * "Input: $g"
        prompt *= "\n Output:"
        trace, weight = generate(gpt3, (prompt,), choicemap(:output => utterance))
        push!(goal_prob, weight)

    end
    goal_prob_total[scenario_id] = goal_prob
    print(scenario_id)
    sleep(5)

end

using HDF5, JLD

save("/Users/lance/Documents/GitHub/assistive-agent/goalprob.jld", "prob", goal_prob_total)
save("/Users/lance/Documents/GitHub/Plinf.jl/domains/assistive-agent/goalprob.jld", "top5", goal_top5)


goal_top5 = Dict()
for scenario_id in collect(keys(utterance_literal_dict))
    
    idxs = partialsortperm(goal_prob_total[scenario_id], 1:5, rev=true)
    goal_top5[scenario_id]=goalset[idxs]

end

costs = (
    pickup=1.0, handover=1.0, unlockh=1.0, unlock=1.0, 
    up=1.0, down=1.0, left=1.0, right=1.0, noop=0.1
)

domain = load_domain(joinpath(@__DIR__, "domain_1.pddl"))
problem = load_problem(joinpath(@__DIR__, "1r.pddl"))

state = initstate(domain, problem)

# Compile and cache domain for faster performance
domain, state = PDDL.compiled(domain, state)
domain = CachedDomain(domain)

heuristic = GoalCountHeuristic()
planner = AStarPlanner(heuristic, save_search=true,max_nodes = 200000)
goal =  "(exist ?k1 - key) (and (has robot ?k1)(iscolor ?k1 red))"
spec = MinActionCosts(pddl"(exist ?k - key) (and (has robot ?k)(iscolor ?k red))", costs)
spec = MinActionCosts(pddl"(has robot gem1)", costs)
spec = MinActionCosts(pddl"(exists (?k - key) (and (has robot ?k) (iscolor ?k blue)))", costs)

sol = planner(domain, state, spec)



for scenario_id in collect(keys(utterance_literal_dict))
    domain = load_domain(joinpath(@__DIR__, "domain.pddl"))
    problem = load_problem(joinpath(@__DIR__, "$scenario_id.pddl"))

    state = initstate(domain, problem)

    # Compile and cache domain for faster performance
    domain, state = PDDL.compiled(domain, state)
    domain = CachedDomain(domain)

    heuristic = GoalManhattan()
    planner = RTHS(heuristic=heuristic, n_iters=1, max_nodes=2^32) 
    spec = MinActionCosts(goal, costs)

    sol = astar(domain, state, spec)

    for goal in goal_top5[scenario_id]

    end

end