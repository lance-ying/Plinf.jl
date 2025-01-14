(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 door5 - door
            key1 key2 - key
            gem1 gem2 gem3 gem4 - gem
            red yellow - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 9 9))
         (= (agentcode human) 0)
         (= (agentcode robot) 1)
         (= (turn) 0)
         (= (xloc key1) 1)
         (= (yloc key1) 1)
         (iscolor key1 red)
         (= (walls) (set-index walls true 1 6))
         (= (walls) (set-index walls true 1 7))
         (= (walls) (set-index walls true 1 8))
         (= (xloc gem1) 9)
         (= (yloc gem1) 1)
         (= (xloc key2) 1)
         (= (yloc key2) 2)
         (iscolor key2 yellow)
         (= (walls) (set-index walls true 2 3))
         (= (walls) (set-index walls true 2 4))
         (= (walls) (set-index walls true 2 6))
         (= (walls) (set-index walls true 2 7))
         (= (walls) (set-index walls true 2 8))
         (= (xloc door1) 9)
         (= (yloc door1) 2)
         (iscolor door1 red)
         (locked door1)
         (= (walls) (set-index walls true 3 1))
         (= (walls) (set-index walls true 3 2))
         (= (walls) (set-index walls true 3 3))
         (= (walls) (set-index walls true 3 4))
         (= (walls) (set-index walls true 3 6))
         (= (walls) (set-index walls true 3 7))
         (= (walls) (set-index walls true 3 8))
         (= (walls) (set-index walls true 4 1))
         (= (walls) (set-index walls true 4 2))
         (= (walls) (set-index walls true 4 3))
         (= (walls) (set-index walls true 4 4))
         (= (walls) (set-index walls true 4 6))
         (= (walls) (set-index walls true 4 7))
         (= (walls) (set-index walls true 4 8))
         (= (walls) (set-index walls true 6 2))
         (= (walls) (set-index walls true 6 3))
         (= (walls) (set-index walls true 6 4))
         (= (walls) (set-index walls true 6 6))
         (= (walls) (set-index walls true 6 7))
         (= (walls) (set-index walls true 6 8))
         (= (walls) (set-index walls true 7 2))
         (= (walls) (set-index walls true 7 3))
         (= (walls) (set-index walls true 7 4))
         (= (xloc door2) 5)
         (= (yloc door2) 7)
         (iscolor door2 yellow)
         (locked door2)
         (= (walls) (set-index walls true 7 6))
         (= (walls) (set-index walls true 7 7))
         (= (walls) (set-index walls true 7 8))
         (= (xloc door3) 1)
         (= (yloc door3) 8)
         (iscolor door3 yellow)
         (locked door3)
         (= (walls) (set-index walls true 8 2))
         (= (walls) (set-index walls true 8 3))
         (= (walls) (set-index walls true 8 4))
         (= (xloc door4) 5)
         (= (yloc door4) 8)
         (iscolor door4 red)
         (locked door4)
         (= (walls) (set-index walls true 8 6))
         (= (walls) (set-index walls true 8 7))
         (= (walls) (set-index walls true 8 8))
         (= (xloc door5) 9)
         (= (yloc door5) 8)
         (iscolor door5 red)
         (locked door5)
         (= (xloc gem2) 1)
         (= (yloc gem2) 9)
         (= (walls) (set-index walls true 9 2))
         (= (walls) (set-index walls true 9 3))
         (= (walls) (set-index walls true 9 4))
         (= (xloc gem3) 5)
         (= (yloc gem3) 9)
         (= (walls) (set-index walls true 9 6))
         (= (walls) (set-index walls true 9 7))
         (= (walls) (set-index walls true 9 8))
         (= (xloc gem4) 9)
         (= (yloc gem4) 9)
         (= (xloc human) 5)
         (= (yloc human) 5)
         (= (xloc robot) 5)
         (= (yloc robot) 3))
  (:goal (has human gem3))
)