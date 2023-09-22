(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 door5 - door
            key1 key2 key3 - key
            gem1 gem2 gem3 gem4 - gem
            red blue yellow - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 8 12))
         (= (agentcode human) 0)
         (= (agentcode robot) 1)
         (= (turn) 0)
         (= (xloc key1) 1)
         (= (yloc key1) 1)
         (iscolor key1 red)
         (= (walls) (set-index walls true 1 7))
         (= (walls) (set-index walls true 1 8))
         (= (walls) (set-index walls true 1 9))
         (= (walls) (set-index walls true 1 10))
         (= (walls) (set-index walls true 1 11))
         (= (xloc gem1) 12)
         (= (yloc gem1) 1)
         (= (xloc key2) 1)
         (= (yloc key2) 2)
         (iscolor key2 blue)
         (= (walls) (set-index walls true 2 3))
         (= (walls) (set-index walls true 2 4))
         (= (walls) (set-index walls true 2 5))
         (= (walls) (set-index walls true 2 7))
         (= (walls) (set-index walls true 2 8))
         (= (walls) (set-index walls true 2 9))
         (= (walls) (set-index walls true 2 10))
         (= (walls) (set-index walls true 2 11))
         (= (xloc key3) 1)
         (= (yloc key3) 3)
         (iscolor key3 yellow)
         (= (walls) (set-index walls true 3 3))
         (= (walls) (set-index walls true 3 4))
         (= (walls) (set-index walls true 3 5))
         (= (walls) (set-index walls true 3 7))
         (= (walls) (set-index walls true 3 8))
         (= (walls) (set-index walls true 3 9))
         (= (walls) (set-index walls true 3 10))
         (= (walls) (set-index walls true 3 11))
         (= (xloc door1) 12)
         (= (yloc door1) 3)
         (iscolor door1 red)
         (locked door1)
         (= (walls) (set-index walls true 4 1))
         (= (walls) (set-index walls true 4 2))
         (= (walls) (set-index walls true 4 3))
         (= (walls) (set-index walls true 4 4))
         (= (xloc door2) 10)
         (= (yloc door2) 4)
         (iscolor door2 blue)
         (locked door2)
         (= (xloc gem2) 1)
         (= (yloc gem2) 5)
         (= (xloc door3) 2)
         (= (yloc door3) 5)
         (iscolor door3 yellow)
         (locked door3)
         (= (walls) (set-index walls true 5 6))
         (= (walls) (set-index walls true 5 7))
         (= (xloc gem3) 8)
         (= (yloc gem3) 5)
         (= (walls) (set-index walls true 5 9))
         (= (walls) (set-index walls true 5 10))
         (= (walls) (set-index walls true 5 11))
         (= (walls) (set-index walls true 5 12))
         (= (walls) (set-index walls true 6 1))
         (= (walls) (set-index walls true 6 2))
         (= (walls) (set-index walls true 6 3))
         (= (walls) (set-index walls true 6 4))
         (= (xloc door4) 10)
         (= (yloc door4) 6)
         (iscolor door4 red)
         (locked door4)
         (= (walls) (set-index walls true 7 1))
         (= (walls) (set-index walls true 7 2))
         (= (walls) (set-index walls true 7 3))
         (= (walls) (set-index walls true 7 4))
         (= (walls) (set-index walls true 7 6))
         (= (walls) (set-index walls true 7 7))
         (= (walls) (set-index walls true 7 8))
         (= (walls) (set-index walls true 7 9))
         (= (walls) (set-index walls true 7 10))
         (= (walls) (set-index walls true 7 11))
         (= (xloc door5) 12)
         (= (yloc door5) 7)
         (iscolor door5 blue)
         (locked door5)
         (= (walls) (set-index walls true 8 1))
         (= (walls) (set-index walls true 8 2))
         (= (walls) (set-index walls true 8 3))
         (= (walls) (set-index walls true 8 4))
         (= (walls) (set-index walls true 8 6))
         (= (walls) (set-index walls true 8 7))
         (= (walls) (set-index walls true 8 8))
         (= (walls) (set-index walls true 8 9))
         (= (walls) (set-index walls true 8 10))
         (= (walls) (set-index walls true 8 11))
         (= (xloc gem4) 12)
         (= (yloc gem4) 8)
         (= (xloc human) 5)
         (= (yloc human) 8)
         (= (xloc robot) 4)
         (= (yloc robot) 1))
  (:goal (has human gem4))
)