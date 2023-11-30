(define (problem virtual-home)
  (:domain virtual-home)
  (:objects 
            cutleryfork1 cutleryfork2 cutleryfork3 cutleryfork4
            cutleryknife1 cutleryknife2 cutleryknife3 cutleryknife4
            plate1 plate2 plate3 plate4
            bowl1 bowl2 bowl3 bowl4  - item
            table1 - table
            robot - robot
            human - human
            cabinet1 cabinet2 cabinet3 cabinet4 cabinet5 - cabinet)
  (:init (active human)
         (next-turn human robot)
         (next-turn robot human)
         (at robot table1)
         (at human table1)
         (in bowl1 cabinet1)
         (in bowl2 cabinet1)
         (in bowl3 cabinet1)
         (in bowl4 cabinet1)
         (in plate1 cabinet2)
         (in plate2 cabinet2)
         (in plate3 cabinet2)
         (in plate4 cabinet2)
         (in cutleryfork1 cabinet4)
         (in cutleryfork2 cabinet4)
         (in cutleryfork3 cabinet4)
         (in cutleryfork4 cabinet4)
         (in cutleryknife1 cabinet4)
         (in cutleryknife2 cabinet4)
         (in cutleryknife3 cabinet4)
         (in cutleryknife4 cabinet4)
        )
  (:goal (has human plate1))
)