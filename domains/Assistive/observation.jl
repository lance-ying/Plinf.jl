
action_dict = Dict(
    
"1.1"=>@pddl("(left human)",  "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)","(left human)"),
"2.1"=>@pddl("(up human)",  "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)"),
"2.2"=>@pddl("(up human)",  "(noop robot)", "(up human)", "(noop robot)", "(up human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)", "(left human)", "(noop robot)"),
"3.1"=>@pddl("(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)"),
"3.2"=>@pddl("(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)","(up human)","(noop robot)"),
"3.3"=>@pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)"),
"4.1"=>@pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)", "(noop robot)","(right human)",  "(noop robot)"),
"4.2"=>@pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)", "(noop robot)","(right human)",  "(noop robot)"),
"5.1"=>@pddl("(down human)",  "(noop robot)", "(down human)",  "(noop robot)"),
"6.1"=>@pddl("(left human)",  "(noop robot)", "(left human)"),
"6.2"=>@pddl("(left human)",  "(noop robot)", "(left human)"),
"7.1"=>@pddl("(right human)",  "(noop robot)", "(right human)","(noop robot)","(right human)",  "(noop robot)"),
"8.1"=>@pddl("(right human)","(noop robot)","(right human)","(noop robot)"),
"8.2"=>@pddl("(down human)","(noop robot)","(down human)","(noop robot)"),
"9.1"=>@pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)", "(noop robot)","(down human)",  "(noop robot)"),
"10.1"=>@pddl("(noop human)",  "(noop robot)"),
"10.2"=>@pddl("(noop human)",  "(noop robot)"),
"11.1"=>@pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(up human)", "(noop robot)","(up human)",  "(noop robot)","(right human)",  "(noop robot)","(right human)",  "(noop robot)"),
"11.2"=>@pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)","(right human)",  "(noop robot)","(right human)",  "(noop robot)"),
"12.1"=>@pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(right human)",  "(noop robot)", "(right human)",  "(noop robot)"),
"12.2"=>@pddl("(up human)",  "(noop robot)", "(up human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)"),
"13.1"=>@pddl("(down human)",  "(noop robot)", "(down human)",  "(noop robot)","(pickuph human key3)",  "(noop robot)", "(up human)",  "(noop robot)",  "(right human)",  "(noop robot)"),
"13.2"=>@pddl("(down human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)", "(left human)",  "(noop robot)","(pickuph human key2)",  "(noop robot)", "(right human)",  "(noop robot)",  "(right human)",  "(noop robot)"),
"14.1"=>@pddl("(noop human)",  "(noop robot)"),
"15.1"=>@pddl("(noop human)",  "(noop robot)"),
"16.1"=>@pddl("(noop human)",  "(noop robot)"),
"17.1"=>@pddl("(down human)",  "(noop robot)", "(down human)",  "(noop robot)","(right human)",  "(noop robot)"),
"18.1"=>@pddl("(left human)",  "(noop robot)", "(up human)",  "(noop robot)"),
"19.1"=>@pddl("(right human)",  "(noop robot)", "(right human)",  "(noop robot)"),
"20.1"=>@pddl("(down human)" , "(noop robot)","(down human)" ,"(noop robot)", "(left human)" , "(noop robot)","(pickuph human key1)" , "(noop robot)","(right human)" ,"(noop robot)", "(right human)" ))


utterance_dict = Dict(
    "1.1"=>"Can you pass me the red key?",
    "2.1"=>"Can you pass me the red key?",
    "2.2"=>"Can you hand me that key?",
    "3.1"=>"Can you pass me the red keys?",
    "3.2"=>"Give me a red key for this door.",
    "3.3"=>"I need a key for this yellow door.",
    "4.1"=>"Can you pass me the red keys?",
    "4.2"=>"Can I have the blue keys?",
    "5.1"=>"Can you pass me the blue key?",
    "6.1"=>"I'm going for the red key, can you get the yellow key?",
    "6.2"=>"On my way to pick up the blue key, can you find a yellow key?",
    "7.1"=>"I'm picking up the yellow key. Can you get a red key?",
    "8.1"=>"I'll get the blue key. Can you pick up a red key?",
    "8.2"=>"I will pick up the red key. Can you get a blue one?",
    "9.1"=>"Can you go get the red key?",
    "10.1"=>"I will pick up this red key. Can you find a yellow one?",
    "10.2"=>"I will pick up the blue key. Can you get the yellow key?",
    "11.1"=>"Can you get the key for this door?",
    "11.2"=>"Can you get me a key for this door?",
    "12.1"=>"Can you come and unlock this door?",
    "12.2"=>"Can you go and unlock that door?",
    "13.1"=>"Can you open the blue door?",
    "13.2"=>"Can you help me unlock the blue door there?",
    "14.1"=>"I'm picking up the red key. Can you get the blue door?",
    "15.1"=>"Can you open the red door there?",
    "16.1"=>"Can you get the blue door there? I'll pick up the key for the red door.",
    "17.1"=>"Can you come and get this red door?",
    "18.1"=>"Can you unlock this red door?",
    "19.1"=>"Can you unlock this blue door?",
    "20.1"=>"Can you come and get this blue door?"

)

utterance_literal_dict = Dict(
    "1.1"=>"Can you pass me the red key?",
    "2.1"=>"Can you pass me the red key?",
    "2.2"=>"Can you hand me that key?",
    "3.1"=>"Can you pass me a red key for this door?",
    "3.2"=>"Can you pass me the red keys?",
    "3.3"=>"I need a key for this red door.",
    "4.1"=>"Can you pass me the red keys?",
    "4.2"=>"Can I have the blue keys?",
    "5.1"=>"Can you pass me the blue key?",
    "6.1"=>"Can you get the yellow key?",
    "6.2"=>"Can you find a yellow key?",
    "7.1"=>"Can you get a red key?",
    "8.1"=>"Can you pick up a red key?",
    "8.2"=>"Can you get a blue one?",
    "9.1"=>"Can you go get the red key?",
    "10.1"=>"Can you find a yellow one?",
    "10.2"=>"Can you get the yellow key?",
    "11.1"=>"Can you get the key for this door?",
    "11.2"=>"Can you get me a key for this door?",
    "12.1"=>"Can you come and unlock this door?",
    "12.2"=>"Can you go and unlock that door?",
    "13.1"=>"Can you open the blue door?",
    "13.2"=>"Can you help me unlock the blue door there?",
    "14.1"=>"Can you get the blue door?",
    "15.1"=>"Can you open the red door?",
    "16.1"=>"Can you get the blue door there?",
    "17.1"=>"Can you come and get this red door?",
    "18.1"=>"Can you unlock this red door?",
    "19.1"=>"Can you unlock this blue door?",
    "20.1"=>"Can you come and get this blue door?"

)

problem_dict=Dict(
    "1"=>["1.1"],
    "2"=>["2.1","2.2"],
    "3"=>["3.1","3.2","3.3"],
    "4"=>["4.1","4.2"],
    "5"=>["5.1"],
    "6"=>["6.1"],
    "7"=>["7.1"],
    "8"=>["8.1","8.2"],
    "9"=>["9.1"],
    "10"=>["10.1","10.2"],
    "11"=>["11.1","11.2"],
    "12"=>["12.1","12.2"],
    "13"=>["13.1","13.2"],
    "14"=>["14.1"],
    "15"=>["15.1"],
    "16"=>["16.1"],
    "17"=>["17.1"],
    "18"=>["18.1"],
    "19"=>["19.1"],
    "20"=>["20.1"]
)

function generate_goal()
    goalset = []
    color = ["red","blue","yellow"]
    for c in color
        for i in 1:3
            if i == 1
                goal = "(exist (?k1 - key) (and (has robot ?k1)(iscolor ?k1 $c)))"
            end
            if i == 2
                goal = "(exist (?k1 ?k2 - key) (and (has robot ?k1)(has robot ?k2)(iscolor ?k1 $c)(iscolor ?k2 $c)))"
            end
            if i == 3
                goal = "(exist (?k1 ?k2 ?k3 - key) (and (has robot ?k1)(has robot ?k2)(has robot ?k3)(iscolor ?k1 $c)(iscolor ?k2 $c)(iscolor ?k3 $c)))"
            end
            push!(goalset, goal)
        end
    end

    for pair in [ ["red","blue"], ["blue","yellow"], ["red","yellow"]]
        goal = "(exist (?k1 ?k2 - key) (and (has robot ?k1)(iscolor ?k1 $(pair[1]))(has robot ?k2)(iscolor ?k2 $(pair[2]))))"
        push!(goalset, goal)
    end

    for pair in [ ["red","blue"], ["blue","yellow"], ["red","yellow"]]
        goal = "(exist (?k1 ?k2 ?k3 - key) (and (has robot ?k1)(iscolor ?k1 $(pair[1]))(has robot ?k2)(iscolor ?k2 $(pair[1]))(has robot ?k3)(iscolor ?k3 $(pair[2]))))"
        push!(goalset, goal)
    end

    for pair in [ ["red","blue"], ["blue","yellow"], ["red","yellow"]]
        goal = "(exist (?k1 ?k2 ?k3 - key) (and (has robot ?k1)(iscolor ?k1 $(pair[1]))(has robot ?k2)(iscolor ?k2 $(pair[2]))(has robot ?k3)(iscolor ?k3 $(pair[2]))))"
        push!(goalset, goal)
    end

    goal = "(exist (?k1 ?k2 ?k3 - key) (and (has robot ?k1)(iscolor ?k1 red)(has robot ?k2)(iscolor ?k2 blue)(has robot ?k3)(iscolor ?k3 yellow)))"
    push!(goalset, goal)

    for c in color
        for i in 1:3
            if i == 1
                goal = "(exist (?d1 - door) (and (robot_unlock ?d1)(iscolor ?d1 $c)))"
            end
            if i == 2
                goal = "(exist (?d1 ?d2 - door) (and (robot_unlock ?d1)(robot_unlock ?d2)(iscolor ?d1 $c)(iscolor ?d2 $c)))"
            end
            if i == 3
                goal = "(exist (?d1 ?d2 ?d3 - door) (and (robot_unlock ?d1)(robot_unlock ?d2)(robot_unlock ?d3)(iscolor ?d1 $c)(iscolor ?d2 $c)(iscolor ?d3 $c)))"
            end
            push!(goalset, goal)
        end
    end

    for pair in [ ["red","blue"], ["blue","yellow"], ["red","yellow"]]
        goal = "(exist (?d1 ?d2 - door) (and (robot_unlock ?d1)(iscolor ?d1 $(pair[1]))(robot_unlock ?d2)(iscolor ?d2 $(pair[2]))))"
        push!(goalset, goal)
    end

    for pair in [ ["red","blue"], ["blue","yellow"], ["red","yellow"]]
        goal = "(exist (?d1 ?d2 ?d3 - door) (and (robot_unlock ?d1)(iscolor ?d1 $(pair[1]))(robot_unlock ?d2)(iscolor ?d2 $(pair[1]))(robot_unlock ?d3)(iscolor ?d3 $(pair[2]))))"
        push!(goalset, goal)
    end

    for pair in [ ["red","blue"], ["blue","yellow"], ["red","yellow"]]
        goal = "(exist (?d1 ?d2 ?d3 - door) (and (robot_unlock ?d1)(iscolor ?d1 $(pair[1]))(robot_unlock ?d2)(iscolor ?d2 $(pair[2]))(robot_unlock ?d3)(iscolor ?d3 $(pair[2]))))"
        push!(goalset, goal)
    end

    goal = "(exist (?d1 ?d1 ?d3 - door) (and (robot_unlock ?d1)(iscolor ?d1 red)(robot_unlock ?d2)(iscolor ?d2 blue)(robot_unlock ?d3)(iscolor ?d3 yellow)))"
    push!(goalset, goal)

    return goalset
end


for pid in sort(collect(keys(action_dict)))
    println(pid, " length ",length(action_dict[pid]))
end