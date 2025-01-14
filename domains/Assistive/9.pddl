(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 door5 - door
            key1 key2 key3 - key
            gem1 gem2 gem3 gem4 - gem
            blue red - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 9 13))
         (= (agentcode human) 0)
         (= (agentcode robot) 1)
         (= (turn) 0)
         (= (walls) (set-index walls true 1 1))
         (= (walls) (set-index walls true 1 2))
         (= (walls) (set-index walls true 1 3))
         (= (xloc key1) 8)
         (= (yloc key1) 1)
         (iscolor key1 red)
         (= (walls) (set-index walls true 1 12))
         (= (walls) (set-index walls true 1 13))
         (= (walls) (set-index walls true 2 1))
         (= (walls) (set-index walls true 2 2))
         (= (walls) (set-index walls true 2 3))
         (= (walls) (set-index walls true 2 5))
         (= (walls) (set-index walls true 2 6))
         (= (walls) (set-index walls true 2 7))
         (= (walls) (set-index walls true 2 8))
         (= (walls) (set-index walls true 2 9))
         (= (walls) (set-index walls true 2 10))
         (= (walls) (set-index walls true 2 12))
         (= (walls) (set-index walls true 2 13))
         (= (walls) (set-index walls true 3 1))
         (= (walls) (set-index walls true 3 2))
         (= (walls) (set-index walls true 3 3))
         (= (walls) (set-index walls true 3 5))
         (= (walls) (set-index walls true 3 6))
         (= (walls) (set-index walls true 3 7))
         (= (walls) (set-index walls true 3 8))
         (= (walls) (set-index walls true 3 9))
         (= (walls) (set-index walls true 3 10))
         (= (walls) (set-index walls true 3 12))
         (= (walls) (set-index walls true 3 13))
         (= (walls) (set-index walls true 4 1))
         (= (walls) (set-index walls true 4 2))
         (= (walls) (set-index walls true 4 3))
         (= (walls) (set-index walls true 4 5))
         (= (walls) (set-index walls true 4 6))
         (= (walls) (set-index walls true 4 7))
         (= (xloc key2) 8)
         (= (yloc key2) 4)
         (iscolor key2 red)
         (= (walls) (set-index walls true 4 9))
         (= (walls) (set-index walls true 4 10))
         (= (walls) (set-index walls true 4 12))
         (= (walls) (set-index walls true 4 13))
         (= (walls) (set-index walls true 5 1))
         (= (walls) (set-index walls true 5 2))
         (= (walls) (set-index walls true 5 3))
         (= (walls) (set-index walls true 5 5))
         (= (walls) (set-index walls true 5 6))
         (= (walls) (set-index walls true 5 7))
         (= (xloc door1) 8)
         (= (yloc door1) 5)
         (iscolor door1 blue)
         (locked door1)
         (= (walls) (set-index walls true 5 9))
         (= (walls) (set-index walls true 5 10))
         (= (walls) (set-index walls true 5 12))
         (= (walls) (set-index walls true 5 13))
         (= (xloc gem1) 1)
         (= (yloc gem1) 6)
         (= (xloc door2) 2)
         (= (yloc door2) 6)
         (iscolor door2 red)
         (locked door2)
         (= (xloc door3) 3)
         (= (yloc door3) 6)
         (iscolor door3 blue)
         (locked door3)
         (= (xloc door4) 12)
         (= (yloc door4) 6)
         (iscolor door4 blue)
         (locked door4)
         (= (xloc gem2) 13)
         (= (yloc gem2) 6)
         (= (walls) (set-index walls true 7 1))
         (= (walls) (set-index walls true 7 2))
         (= (walls) (set-index walls true 7 3))
         (= (walls) (set-index walls true 7 5))
         (= (walls) (set-index walls true 7 6))
         (= (walls) (set-index walls true 7 8))
         (= (walls) (set-index walls true 7 9))
         (= (walls) (set-index walls true 7 10))
         (= (xloc door5) 11)
         (= (yloc door5) 7)
         (iscolor door5 red)
         (locked door5)
         (= (walls) (set-index walls true 7 12))
         (= (walls) (set-index walls true 7 13))
         (= (walls) (set-index walls true 8 1))
         (= (walls) (set-index walls true 8 2))
         (= (walls) (set-index walls true 8 3))
         (= (walls) (set-index walls true 8 5))
         (= (walls) (set-index walls true 8 6))
         (= (walls) (set-index walls true 8 8))
         (= (walls) (set-index walls true 8 9))
         (= (walls) (set-index walls true 8 10))
         (= (walls) (set-index walls true 8 12))
         (= (walls) (set-index walls true 8 13))
         (= (walls) (set-index walls true 9 1))
         (= (walls) (set-index walls true 9 2))
         (= (walls) (set-index walls true 9 3))
         (= (xloc gem3) 4)
         (= (yloc gem3) 9)
         (= (walls) (set-index walls true 9 5))
         (= (walls) (set-index walls true 9 6))
         (= (xloc key3) 7)
         (= (yloc key3) 9)
         (iscolor key3 blue)
         (= (walls) (set-index walls true 9 8))
         (= (walls) (set-index walls true 9 9))
         (= (walls) (set-index walls true 9 10))
         (= (xloc gem4) 11)
         (= (yloc gem4) 9)
         (= (walls) (set-index walls true 9 12))
         (= (walls) (set-index walls true 9 13))
         (= (xloc human) 4)
         (= (yloc human) 6)
         (= (xloc robot) 8)
         (= (yloc robot) 6))
  (:goal (has human gem4))
)