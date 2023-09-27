(define (problem virtual-home)
  (:domain virtual-home)
  (:objects fridge1 - fridge
            onion1 tomato1 potato1 beef1 carrot1 wine1 juice1 cupcake1 cuttingboard1 chefknife1 
            cutleryfork1 cutleryfork2 cutleryfork3 cutleryfork4
            cutleryknife1 cutleryknife2 cutleryknife3 cutleryknife4
            bowl1 bowl2 bowl3 bowl4 plate1 plate2 plate3 plate4 
            wineglass1 wineglass2 wineglass3 wineglass4
            waterglass1 waterglass2 waterglass3 waterglass4 - item
            table1 table2 - table
            robot human - agent
            cabinet1 cabinet2 cabinet3 cabinet4 cabinet5 cabinet6 cabinet7 - cabinet)
  (:init (= (walls) (new-bit-matrix false 8 16))
         (= (agentcode human) 0)
         (= (agentcode robot) 1)
         (= (turn) 0)
         (= (xloc fridge1) 1)
         (= (yloc fridge1) 1)
         (in tomato1 fridge1)
         (= (xloc tomato1) 1)
         (= (yloc tomato1) 1)
         (in cucumber1 fridge1)
         (= (xloc cucumber1) 1)
         (= (yloc cucumber1) 1)
         (in onion1 fridge1)
         (= (xloc onion1) 1)
         (= (yloc onion1) 1)
         (in potato1 fridge1)
         (= (xloc potato1) 1)
         (= (yloc potato1) 1)
         (in carrot1 fridge1)
         (= (xloc carrot1) 1)
         (= (yloc carrot1) 1)
         (in juice1 fridge1)
         (= (xloc juice1) 1)
         (= (yloc juice1) 1)
         (in beef1 fridge1)
         (= (xloc beef1) 1)
         (= (yloc beef1) 1)
         (in wine1 fridge1)
         (= (xloc wine1) 1)
         (= (yloc wine1) 1)
         (= (xloc cabinet1) 2)
         (= (yloc cabinet1) 1)
         (in bowl1 cabinet1)
         (= (xloc bowl1) 2)
         (= (yloc bowl1) 1)
         (in bowl2 cabinet1)
         (= (xloc bowl2) 2)
         (= (yloc bowl2) 1)
         (in bowl3 cabinet1)
         (= (xloc bowl3) 2)
         (= (yloc bowl3) 1)
         (in bowl4 cabinet1)
         (= (xloc bowl4) 2)
         (= (yloc bowl4) 1)
         (= (xloc cabinet2) 3)
         (= (yloc cabinet2) 1)
         (in plate1 cabinet2)
         (= (xloc plate1) 3)
         (= (yloc plate1) 1)
         (in plate2 cabinet2)
         (= (xloc plate2) 3)
         (= (yloc plate2) 1)
         (in plate3 cabinet2)
         (= (xloc plate3) 3)
         (= (yloc plate3) 1)
         (in plate4 cabinet2)
         (= (xloc plate4) 3)
         (= (yloc plate4) 1)
         (= (xloc cabinet3) 4)
         (= (yloc cabinet3) 1)
         (in waterglass1 cabinet3)
         (= (xloc waterglass1) 4)
         (= (yloc waterglass1) 1)
         (in waterglass2 cabinet3)
         (= (xloc waterglass2) 4)
         (= (yloc waterglass2) 1)
         (in waterglass3 cabinet3)
         (= (xloc waterglass3) 4)
         (= (yloc waterglass3) 1)
         (in waterglass4 cabinet3)
         (= (xloc waterglass4) 4)
         (= (yloc waterglass4) 1)
         (in wineglass1 cabinet3)
         (= (xloc wineglass1) 4)
         (= (yloc wineglass1) 1)
         (in wineglass2 cabinet3)
         (= (xloc wineglass2) 4)
         (= (yloc wineglass2) 1)
         (in wineglass3 cabinet3)
         (= (xloc wineglass3) 4)
         (= (yloc wineglass3) 1)
         (in wineglass4 cabinet3)
         (= (xloc wineglass4) 4)
         (= (yloc wineglass4) 1)
         (= (xloc cabinet4) 5)
         (= (yloc cabinet4) 1)
         (= (xloc cabinet5) 6)
         (= (yloc cabinet5) 1)
         (= (xloc cabinet6) 7)
         (= (yloc cabinet6) 1)
         (in cutleryfork1 cabinet6)
         (= (xloc cutleryfork1) 7)
         (= (yloc cutleryfork1) 1)
         (in cutleryfork2 cabinet6)
         (= (xloc cutleryfork2) 7)
         (= (yloc cutleryfork2) 1)
         (in cutleryfork3 cabinet6)
         (= (xloc cutleryfork3) 7)
         (= (yloc cutleryfork3) 1)
         (in cutleryfork4 cabinet6)
         (= (xloc cutleryfork4) 7)
         (= (yloc cutleryfork4) 1)
         (in cutleryknife1 cabinet6)
         (= (xloc cutleryknife1) 7)
         (= (yloc cutleryknife1) 1)
         (in cutleryknife2 cabinet6)
         (= (xloc cutleryknife2) 7)
         (= (yloc cutleryknife2) 1)
         (in cutleryknife3 cabinet6)
         (= (xloc cutleryknife3) 7)
         (= (yloc cutleryknife3) 1)
         (in cutleryknife4 cabinet6)
         (= (xloc cutleryknife4) 7)
         (= (yloc cutleryknife4) 1)
         (= (xloc cabinet7) 8)
         (= (yloc cabinet7) 1)
         (in cuttingboard1 cabinet7)
         (= (xloc cuttingboard1) 8)
         (= (yloc cuttingboard1) 1)
         (in chefknife1 cabinet7)
         (= (xloc chefknife1) 8)
         (= (yloc chefknife1) 1)
         (= (walls) (set-index walls true 1 9))
         (= (walls) (set-index walls true 1 10))
         (= (walls) (set-index walls true 1 11))
         (= (walls) (set-index walls true 1 12))
         (= (walls) (set-index walls true 1 13))
         (= (walls) (set-index walls true 1 14))
         (= (walls) (set-index walls true 1 15))
         (= (walls) (set-index walls true 1 16))
         (= (walls) (set-index walls true 2 9))
         (= (walls) (set-index walls true 2 10))
         (= (walls) (set-index walls true 2 11))
         (= (walls) (set-index walls true 2 12))
         (= (walls) (set-index walls true 2 13))
         (= (walls) (set-index walls true 2 14))
         (= (walls) (set-index walls true 2 15))
         (= (walls) (set-index walls true 2 16))
         (= (walls) (set-index walls true 3 9))
         (= (walls) (set-index walls true 3 10))
         (= (walls) (set-index walls true 3 11))
         (= (walls) (set-index walls true 3 12))
         (= (walls) (set-index walls true 3 13))
         (= (walls) (set-index walls true 3 14))
         (= (walls) (set-index walls true 3 15))
         (= (walls) (set-index walls true 3 16))
         (= (xloc table1) 4)
         (= (yloc table1) 4)
         (= (walls) (set-index walls true 4 9))
         (= (xloc sofa1) 14)
         (= (yloc sofa1) 4)
         (= (walls) (set-index walls true 5 9))
         (= (xloc table2) 14)
         (= (yloc table2) 5)
         (= (walls) (set-index walls true 7 9))
         (= (walls) (set-index walls true 8 1))
         (= (walls) (set-index walls true 8 2))
         (= (walls) (set-index walls true 8 3))
         (= (walls) (set-index walls true 8 4))
         (= (walls) (set-index walls true 8 5))
         (= (walls) (set-index walls true 8 6))
         (= (walls) (set-index walls true 8 7))
         (= (walls) (set-index walls true 8 8))
         (= (walls) (set-index walls true 8 9))
         (= (xloc human) 7)
         (= (yloc human) 4)
         (= (xloc robot) 2)
         (= (yloc robot) 5))
  (:goal (exist ?o - onion ?b - beef ?c - carrot ?p - potato ?w - wine)(and (on ?o table1) (on ?c table1) (on ?p table1) (on ?w table1)))
)