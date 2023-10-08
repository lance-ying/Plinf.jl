(define (problem virtual-home)
  (:domain virtual-home)
  (:objects fridge1 - fridge
            onion1 tomato1 potato1 potato1 carrot1 chicken1 salmon1 cucumber1 cuttingboard1 chefknife1 
            cutleryknife1 cutleryknife2 - item
            table1- table
            robot - robot
            human - human
            cabinet1 cabinet2 cabinet3 cabinet4 cabinet5 - cabinet)
  (:init (active human)
         (next-turn human robot)
         (next-turn robot human)
         (at robot table1)
         (at human table1)
         (in onion1 fridge1)
         (in potato1 fridge1)
         (in carrot1 fridge1)
         (in tomato1 fridge1)
         (in cucumber1 fridge1)
         (in potato1 fridge1)
         (in chicken1 fridge1)
         (in salmon1 fridge1)
         (in cutleryknife1 cabinet4)
         (in cutleryknife2 cabinet4)
         (in cuttingboard1 cabinet5 )
         (in chefknife1 cabinet5 )
        )
  (:goal (has human wine1))
)