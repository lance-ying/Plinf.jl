goal_name = ["veggie_salad","chicken_salad","chicken_stew","salmon_stew","potato_stew","set_table1", "set_table2","set_table3","set_table4","set_table1b","set_table2b","set_table3b","set_table4b","plate1","plate2","plate3","plate4","wine1","wine2","wine3","wine4","wine1p","wine2p","wine3p","wine4p","juice1","juice2","juice3","juice4","juice1p","juice2p","juice3p","juice4p"]

goals_copy = @pddl("(and (delivered onion1) (delivered cucumber1) (delivered tomato1) (delivered chefknife1)(not (delivered wine1))(not (delivered salmon1))(not (delivered potato1)))",
"(and (delivered onion1) (delivered cucumber1) (delivered chicken1) (delivered chefknife1)(not (delivered tomato1))(not (delivered wine1))(not (delivered salmon1))(not (delivered potato1)))",
"(and (delivered onion1) (delivered carrot1) (delivered chicken1) (delivered wine1)(not (delivered tomato1))(not (delivered salmon1))(not (delivered potato1)))",
"(and (delivered onion1) (delivered carrot1) (delivered salmon1) (delivered wine1)(not (delivered tomato1))(not (delivered chicken1))(not (delivered potato1)))",
"(and (delivered onion1) (delivered carrot1) (delivered potato1) (delivered wine1)(not (delivered tomato1))(not (delivered salmon1)))(not (delivered chicken1))",
"(and (delivered cutleryfork1)(not(delivered cutleryfork2))(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (delivered cutleryknife1)(not(delivered cutleryknife2))(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(not(delivered plate2))(not(delivered plate3))(not(delivered plate4))(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (delivered cutleryfork1)(delivered cutleryfork2)(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (delivered cutleryknife1)(delivered cutleryknife2)(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(delivered plate2)(not(delivered plate3))(not(delivered plate4))(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(not(delivered cutleryfork4)) (delivered cutleryknife1)(delivered cutleryknife2)(delivered cutleryknife3)(not(delivered cutleryknife4)) (delivered plate1)(delivered plate2)(delivered plate3)(not(delivered plate4))(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(delivered cutleryfork4) (delivered cutleryknife1)(delivered cutleryknife2)(delivered cutleryknife3)(delivered cutleryknife4) (delivered plate1)(delivered plate2)(delivered plate3)(delivered plate4)(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (delivered cutleryfork1)(not(delivered cutleryfork2))(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (delivered cutleryknife1)(not(delivered cutleryknife2))(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(not(delivered plate2))(not(delivered plate3))(not(delivered plate4))(delivered bowl1)(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (delivered cutleryfork1)(delivered cutleryfork2)(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (delivered cutleryknife1)(delivered cutleryknife2)(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(delivered plate2)(not(delivered plate3))(not(delivered plate4))(delivered bowl1)(delivered bowl2)(not(delivered bowl3))(not(delivered bowl4)))",
"(and (delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(not(delivered cutleryfork4)) (delivered cutleryknife1)(delivered cutleryknife2)(delivered cutleryknife3)(not(delivered cutleryknife4)) (delivered plate1)(delivered plate2)(delivered plate3)(not(delivered plate4))(delivered bowl1)(delivered bowl2)(delivered bowl3)(not(delivered bowl4)))",
"(and (delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(delivered cutleryfork4) (delivered cutleryknife1)(delivered cutleryknife2)(delivered cutleryknife3)(delivered cutleryknife4) (delivered plate1)(delivered plate2)(delivered plate3)(delivered plate4)(delivered bowl1)(delivered bowl2)(delivered bowl3)(delivered bowl4))",
"(and (delivered wineglass1)(delivered wine1))",
"(and (not (delivered cutleryfork1))(not(delivered cutleryfork2))(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (not (delivered cutleryknife1))(not(delivered cutleryknife2))(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(not(delivered plate2))(not(delivered plate3))(not(delivered plate4))(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (not (delivered cutleryfork1))(not(delivered cutleryfork2))(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (not (delivered cutleryknife1))(not(delivered cutleryknife2))(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(delivered plate2)(not(delivered plate3))(not(delivered plate4))(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (not (delivered cutleryfork1))(not(delivered cutleryfork2))(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (not (delivered cutleryknife1))(not(delivered cutleryknife2))(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(delivered plate2)(delivered plate3)(not(delivered plate4))(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (not (delivered cutleryfork1))(not(delivered cutleryfork2))(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (not (delivered cutleryknife1))(not(delivered cutleryknife2))(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(delivered plate2)(delivered plate3)(delivered plate4)(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (delivered wineglass1)(delivered wineglass2) (delivered wine1))",
"(and (delivered wineglass1)(delivered wineglass2)(delivered wineglass3) (delivered wine1))",
"(and (delivered wineglass1)(delivered wineglass2)(delivered wineglass3)(delivered wineglass4) (delivered wine1))",
"(and (delivered wineglass1) (delivered cutleryfork1)(delivered wine1)(delivered cheese1))",
"(and (delivered wineglass1)(delivered wineglass2) (delivered cutleryfork1)(delivered cutleryfork2)(delivered wine1)(delivered cheese1))",
"(and (delivered wineglass1)(delivered wineglass2)(delivered wineglass3) (delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(delivered wine1)(delivered cheese1))",
"(and (delivered wineglass1)(delivered wineglass2)(delivered wineglass3)(delivered wineglass4) (delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(delivered cutleryfork4)(delivered wine1)(delivered cheese1))",
"(and (delivered waterglass1)(delivered juice1))",
"(and (delivered waterglass1)(delivered waterglass2)(delivered juice1))",
"(and (delivered waterglass1)(delivered waterglass2)(delivered waterglass3)(delivered juice1))",
"(and (delivered waterglass1)(delivered waterglass2)(delivered waterglass3)(delivered waterglass4)(delivered juice1))",
"(and (delivered waterglass1)(delivered cutleryfork1)(delivered cupcake1)(delivered juice1))",
"(and (delivered waterglass1)(delivered waterglass2)(delivered cutleryfork1)(delivered cutleryfork2)(delivered cupcake1)(delivered cupcake2)(delivered juice1))",
"(and (delivered waterglass1)(delivered waterglass2)(delivered waterglass3)(delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(delivered cupcake1)(delivered cupcake2)(delivered cupcake3)(delivered juice1))",
"(and (delivered waterglass1)(delivered waterglass2)(delivered waterglass3)(delivered waterglass4)(delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(delivered cutleryfork4)(delivered cupcake1)(delivered cupcake2)(delivered cupcake3)(delivered cupcake4)(delivered juice1))",
)


goals = [@pddl("(and (delivered onion1) (delivered cucumber1) (delivered tomato1) (delivered chefknife1)(not (delivered wine1))(not (delivered salmon1))(not (delivered potato1)))",
"(and (delivered onion1) (delivered cucumber1) (delivered chicken1) (delivered chefknife1)(not (delivered tomato1))(not (delivered wine1))(not (delivered salmon1))(not (delivered potato1)))",
"(and (delivered onion1) (delivered carrot1) (delivered chicken1) (delivered wine1)(not (delivered tomato1))(not (delivered salmon1))(not (delivered potato1)))",
"(and (delivered onion1) (delivered carrot1) (delivered salmon1) (delivered wine1)(not (delivered tomato1))(not (delivered chicken1))(not (delivered potato1)))",
"(and (delivered onion1) (delivered carrot1) (delivered potato1) (delivered wine1)(not (delivered tomato1))(not (delivered salmon1)))(not (delivered chicken1))"),


@pddl("(and (delivered cutleryfork1)(not(delivered cutleryfork2))(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (delivered cutleryknife1)(not(delivered cutleryknife2))(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(not(delivered plate2))(not(delivered plate3))(not(delivered plate4))(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (delivered cutleryfork1)(delivered cutleryfork2)(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (delivered cutleryknife1)(delivered cutleryknife2)(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(delivered plate2)(not(delivered plate3))(not(delivered plate4))(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(not(delivered cutleryfork4)) (delivered cutleryknife1)(delivered cutleryknife2)(delivered cutleryknife3)(not(delivered cutleryknife4)) (delivered plate1)(delivered plate2)(delivered plate3)(not(delivered plate4))(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(delivered cutleryfork4) (delivered cutleryknife1)(delivered cutleryknife2)(delivered cutleryknife3)(delivered cutleryknife4) (delivered plate1)(delivered plate2)(delivered plate3)(delivered plate4)(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (delivered cutleryfork1)(not(delivered cutleryfork2))(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (delivered cutleryknife1)(not(delivered cutleryknife2))(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(not(delivered plate2))(not(delivered plate3))(not(delivered plate4))(delivered bowl1)(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (delivered cutleryfork1)(delivered cutleryfork2)(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (delivered cutleryknife1)(delivered cutleryknife2)(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(delivered plate2)(not(delivered plate3))(not(delivered plate4))(delivered bowl1)(delivered bowl2)(not(delivered bowl3))(not(delivered bowl4)))",
"(and (delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(not(delivered cutleryfork4)) (delivered cutleryknife1)(delivered cutleryknife2)(delivered cutleryknife3)(not(delivered cutleryknife4)) (delivered plate1)(delivered plate2)(delivered plate3)(not(delivered plate4))(delivered bowl1)(delivered bowl2)(delivered bowl3)(not(delivered bowl4)))",
"(and (delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(delivered cutleryfork4) (delivered cutleryknife1)(delivered cutleryknife2)(delivered cutleryknife3)(delivered cutleryknife4) (delivered plate1)(delivered plate2)(delivered plate3)(delivered plate4)(delivered bowl1)(delivered bowl2)(delivered bowl3)(delivered bowl4))",
"(and (not (delivered cutleryfork1))(not(delivered cutleryfork2))(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (not (delivered cutleryknife1))(not(delivered cutleryknife2))(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(not(delivered plate2))(not(delivered plate3))(not(delivered plate4))(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (not (delivered cutleryfork1))(not(delivered cutleryfork2))(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (not (delivered cutleryknife1))(not(delivered cutleryknife2))(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(delivered plate2)(not(delivered plate3))(not(delivered plate4))(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (not (delivered cutleryfork1))(not(delivered cutleryfork2))(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (not (delivered cutleryknife1))(not(delivered cutleryknife2))(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(delivered plate2)(delivered plate3)(not(delivered plate4))(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))",
"(and (not (delivered cutleryfork1))(not(delivered cutleryfork2))(not(delivered cutleryfork3))(not(delivered cutleryfork4)) (not (delivered cutleryknife1))(not(delivered cutleryknife2))(not(delivered cutleryknife3))(not(delivered cutleryknife4)) (delivered plate1)(delivered plate2)(delivered plate3)(delivered plate4)(not(delivered bowl1))(not(delivered bowl2))(not(delivered bowl3))(not(delivered bowl4)))"),

@pddl("(and (delivered wineglass1)(delivered wine1))",
"(and (delivered wineglass1)(delivered wineglass2) (delivered wine1))",
"(and (delivered wineglass1)(delivered wineglass2)(delivered wineglass3) (delivered wine1))",
"(and (delivered wineglass1)(delivered wineglass2)(delivered wineglass3)(delivered wineglass4) (delivered wine1))",
"(and (delivered wineglass1) (delivered cutleryfork1)(delivered wine1)(delivered cheese1))",
"(and (delivered wineglass1)(delivered wineglass2) (delivered cutleryfork1)(delivered cutleryfork2)(delivered wine1)(delivered cheese1))",
"(and (delivered wineglass1)(delivered wineglass2)(delivered wineglass3) (delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(delivered wine1)(delivered cheese1))",
"(and (delivered wineglass1)(delivered wineglass2)(delivered wineglass3)(delivered wineglass4) (delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(delivered cutleryfork4)(delivered wine1)(delivered cheese1))",
"(and (delivered waterglass1)(delivered juice1))",
"(and (delivered waterglass1)(delivered waterglass2)(delivered juice1))",
"(and (delivered waterglass1)(delivered waterglass2)(delivered waterglass3)(delivered juice1))",
"(and (delivered waterglass1)(delivered waterglass2)(delivered waterglass3)(delivered waterglass4)(delivered juice1))",
"(and (delivered waterglass1)(delivered cutleryfork1)(delivered cupcake1)(delivered juice1))",
"(and (delivered waterglass1)(delivered waterglass2)(delivered cutleryfork1)(delivered cutleryfork2)(delivered cupcake1)(delivered cupcake2)(delivered juice1))",
"(and (delivered waterglass1)(delivered waterglass2)(delivered waterglass3)(delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(delivered cupcake1)(delivered cupcake2)(delivered cupcake3)(delivered juice1))",
"(and (delivered waterglass1)(delivered waterglass2)(delivered waterglass3)(delivered waterglass4)(delivered cutleryfork1)(delivered cutleryfork2)(delivered cutleryfork3)(delivered cutleryfork4)(delivered cupcake1)(delivered cupcake2)(delivered cupcake3)(delivered cupcake4)(delivered juice1))",
)]


goal_dict = Dict()

for i in 1:33
    goal_dict[goal_name[i]]=goals_copy[i]
end


pid_dict = Dict(
"1.1"=>"chicken_stew",
"1.2"=>"veggie_salad",
"1.3"=>"chicken_salad",
"1.4"=>"chicken_stew",
"1.5"=>"salmon_stew",
"1.6"=>"chicken_stew",
"1.7"=>"salmon_stew",

"2.1"=>"set_table2b",
"2.2"=>"set_table2",
"2.3"=>"set_table2b",
"2.4"=>"set_table1b", 
"2.5"=>"set_table2b",
"2.6"=>"set_table2b",
"2.7"=>"set_table2b",
"2.8"=>"set_table2b",
"2.9"=>"set_table2",
"2.10"=>"set_table2",

"3.1"=>"wine3",
"3.2"=>"juice3",
"3.3"=>"wine2p",
"3.4"=>"juice3",
"3.5"=>"wine2p",


)

# action_dict = Dict("3.1"=>@pddl("(move human table1 fridge1)","(noop robot)","(grab human wine1 fridge1)","(noop robot)","(move human fridge1 cabinet3)","(noop robot)", "(grab human wineglass1 cabinet3)"),
# "2.1"=>@pddl("(move human table1 cabinet2)","(noop robot)","(grab human plate1 cabinet2)","(noop robot)", "(grab human plate2 cabinet2)"),
# "2.2"=>@pddl("(move human table1 cabinet2)","(noop robot)","(grab human plate1 cabinet2)","(noop robot)", "(grab human plate2 cabinet2)","(noop robot)", "(grab human plate3 cabinet2)"),
# "2.3"=>@pddl("(move human table1 cabinet2)","(noop robot)","(grab human plate1 cabinet2)","(noop robot)", "(grab human plate2 cabinet2)","(noop robot)","(move human cabinet2 cabinet1)","(noop robot)", "(grab human bowl1 cabinet1)","(noop robot)","(grab human bowl2 cabinet1)","(noop robot)"),
# "1.1"=>@pddl("(move human table1 fridge1)","(noop robot)","(grab human potato1 fridge1)","(noop robot)", "(grab human wine1 fridge1)"),
# "3.2"=>@pddl("(move human table1 fridge1)","(noop robot)","(grab human juice1 fridge1)","(noop robot)"),
# "2.4"=>@pddl("(move human table1 cabinet2)","(noop robot)","(grab human plate1 cabinet2)","(noop robot)", "(grab human plate2 cabinet2)","(noop robot)","(move human cabinet2 cabinet4)","(noop robot)", "(grab human cutleryfork1 cabinet4)","(noop robot)","(grab human cutleryfork2 cabinet4)","(noop robot)"),
# "3.3"=>@pddl("(move human table1 cabinet2)","(noop robot)","(grab human plate1 cabinet2)","(noop robot)","(move human cabinet2 fridge1)","(noop robot)", "(grab human wine1 fridge1)","(noop robot)", "(grab human cheese1 fridge1)"),
# "3.4"=>@pddl("(move human table1 cabinet4)","(noop robot)","(grab human cutleryfork1 cabinet4)","(noop robot)", "(grab human cutleryfork2 cabinet4)","(noop robot)", "(grab human cutleryfork3 cabinet4)","(noop robot)","(move human cabinet4 fridge1)","(noop robot)", "(grab human juice1 fridge1)"),
# "2.5"=>@pddl("(move human table1 cabinet4)","(noop robot)","(grab human cutleryfork1 cabinet4)","(noop robot)", "(grab human cutleryfork2 cabinet4)","(noop robot)", "(grab human cutleryfork3 cabinet4)","(noop robot)","(grab human cutleryknife1 cabinet4)","(noop robot)", "(grab human cutleryknife2 cabinet4)","(noop robot)", "(grab human cutleryknife3 cabinet4)" ),
# "2.6"=>@pddl("(move human table1 cabinet4)","(noop robot)","(grab human cutleryfork1 cabinet4)","(noop robot)", "(grab human cutleryfork2 cabinet4)","(noop robot)", "(grab human cutleryknife1 cabinet4)"),
# "1.2"=>@pddl("(move human table1 fridge1)","(noop robot)","(grab human tomato1 fridge1)","(noop robot)","(grab human cucumber1 fridge1)","(grab human onion1 fridge1)"),
# "1.3"=>@pddl("(move human table1 fridge1)","(noop robot)","(grab human chicken1 fridge1)","(noop robot)","(grab human cucumber1 fridge1)"),
# "3.5"=>@pddl("(move human table1 cabinet3)","(noop robot)","(grab human wineglass1 cabinet3)","(noop robot)","(grab human wineglass2 cabinet3)","(noop robot)","(grab human wineglass3 cabinet3)"),
# "3.6"=>@pddl("(move human table1 fridge1)","(noop robot)","(grab human juice1 fridge1)","(noop robot)","(grab human waterglass1 cabinet3)","(noop robot)"),
# "2.7"=>@pddl("(noop human)"),
# "3.7"=>@pddl("(noop human)"),
# "2.8"=>@pddl("(noop human)"),
# "3.8"=>@pddl("(noop human)"),
# "1.4"=>@pddl("(noop human)")
# )

# utterance_dict=Dict(
#     "3.1"=>"Can you get 2 more glasses?",
#     "2.1"=>"Can you fetch some forks and knives?",
#     "2.2"=>"I've got the plates, can you get the forks and knives?",
#     "2.3"=>"We need some cutleries.",
#     "1.1"=>"Can you get the carrot and onion for the stew?",
#     "3.2"=>"Can you get 3 glasses?",
#     "2.4"=>"Can you get the bowls?",
#     "3.3"=>"Can you find 3 forks and some glasses?",
#     "3.4"=>"Can you get the glasses and some cupcakes for afternoon tea?",
#     "2.5"=>"Can you bring the plates?",
#     "2.6"=>"Could you fetch one more knife and some plates?",
#     "1.2"=>"I need a knife, can you get it?",
#     "1.3"=>"Could you hand me a knife?",
#     "3.5"=>"Can you get the bottle from fridge?",
#     "3.6"=>"We need 3 more glasses, could you get them from the cabinet?",
#     "2.7"=>"I'll grab 2 plates for dinner, can you help me find the forks and knives?",
#     "3.7"=>"I'll get the wine, can you bring me 2 glasses? ",
#     "2.8"=>"We have 3 people for dinner. I'll get the forks and knives, can you get some plates?",
#     "3.8"=>"I will get wine, can you find glasses for 3 people?",
#     "1.4"=>"I will get the vegetables from the fridge, can you get a knife?"
# )

# utterance_dict_literal=Dict(
#     1=>"Can you get 2 more glasses?",
#     2=>"Can you get more plates and some forks and knives? We have 4 people.",
#     3=>"Can you get the forks and knives?",
#     4=>"We need some cutlery.",
#     5=>"Can you get the carrot and onion for the stew?",
#     6=>"Can you get 3 glasses?",
#     7=>"Can you get the bowls?",
#     8=>"Can you help me find the forks and knives?",
#     9=>"Can you bring me 2 glasses? ",
#     10=>"Can you find 3 forks and some glasses?",
#     11=>"Can you get a knife?",
#     12=>"Can you get the glasses and some cupcakes for afternoon tea?",
#     13=>"Can you bring the plates?",
#     14=>"Could you fetch the rest of the knives and some plates?",
#     15=>"I need a knife, can you get it?",
#     16=>"Could you hand me a knife?",
#     17=>"We have 3 people for dinner. Can you get some plates?",
#     18=>"Can you get wine and glasses for 3 people?",
#     19=>"Can you get the bottle from fridge?",
#     20=>"We need 3 more glasses, could you get them from the cabinets?"
# )

