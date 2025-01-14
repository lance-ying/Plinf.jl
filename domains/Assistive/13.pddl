(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 - door
            key1 key2 key3 - key
            gem1 gem2 gem3 gem4 - gem
            red blue yellow - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 7 11))
         (= (agentcode human) 0)
         (= (agentcode robot) 1)
         (= (turn) 0)
         (= (xloc gem1) 1)
         (= (yloc gem1) 1)
         (= (walls) (set-index walls true 1 2))
         (= (walls) (set-index walls true 1 3))
         (= (walls) (set-index walls true 1 4))
         (= (xloc gem2) 5)
         (= (yloc gem2) 1)
         (= (walls) (set-index walls true 1 6))
         (= (walls) (set-index walls true 1 7))
         (= (walls) (set-index walls true 1 8))
         (= (xloc key1) 9)
         (= (yloc key1) 1)
         (iscolor key1 blue)
         (= (walls) (set-index walls true 1 10))
         (= (walls) (set-index walls true 1 11))
         (= (walls) (set-index walls true 2 2))
         (= (walls) (set-index walls true 2 3))
         (= (walls) (set-index walls true 2 4))
         (= (walls) (set-index walls true 2 6))
         (= (walls) (set-index walls true 2 7))
         (= (walls) (set-index walls true 2 8))
         (= (walls) (set-index walls true 2 10))
         (= (walls) (set-index walls true 2 11))
         (= (xloc door1) 1)
         (= (yloc door1) 3)
         (iscolor door1 red)
         (locked door1)
         (= (xloc door2) 5)
         (= (yloc door2) 3)
         (iscolor door2 blue)
         (locked door2)
         (= (walls) (set-index walls true 3 10))
         (= (walls) (set-index walls true 3 11))
         (= (walls) (set-index walls true 4 1))
         (= (walls) (set-index walls true 4 2))
         (= (walls) (set-index walls true 4 3))
         (= (walls) (set-index walls true 4 4))
         (= (walls) (set-index walls true 4 6))
         (= (walls) (set-index walls true 4 7))
         (= (walls) (set-index walls true 4 8))
         (= (xloc door3) 10)
         (= (yloc door3) 4)
         (iscolor door3 yellow)
         (locked door3)
         (= (xloc gem3) 11)
         (= (yloc gem3) 4)
         (= (walls) (set-index walls true 5 1))
         (= (walls) (set-index walls true 5 2))
         (= (walls) (set-index walls true 5 3))
         (= (walls) (set-index walls true 5 4))
         (= (walls) (set-index walls true 5 6))
         (= (walls) (set-index walls true 5 7))
         (= (walls) (set-index walls true 5 8))
         (= (xloc door4) 9)
         (= (yloc door4) 5)
         (iscolor door4 blue)
         (locked door4)
         (= (walls) (set-index walls true 5 10))
         (= (walls) (set-index walls true 5 11))
         (= (xloc key2) 1)
         (= (yloc key2) 6)
         (iscolor key2 red)
         (= (xloc gem4) 11)
         (= (yloc gem4) 6)
         (= (walls) (set-index walls true 7 1))
         (= (walls) (set-index walls true 7 2))
         (= (walls) (set-index walls true 7 3))
         (= (walls) (set-index walls true 7 4))
         (= (xloc key3) 5)
         (= (yloc key3) 7)
         (iscolor key3 yellow)
         (= (walls) (set-index walls true 7 6))
         (= (walls) (set-index walls true 7 7))
         (= (walls) (set-index walls true 7 8))
         (= (walls) (set-index walls true 7 9))
         (= (walls) (set-index walls true 7 10))
         (= (walls) (set-index walls true 7 11))
         (= (xloc human) 5)
         (= (yloc human) 5)
         (= (xloc robot) 9)
         (= (yloc robot) 3))
  (:goal (has human gem4))
)