(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 door5 - door
            key1 key2 key3 - key
            gem1 gem2 gem3 gem4 - gem
            blue red yellow - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 7 10))
         (= (agentcode human) 0)
         (= (agentcode robot) 1)
         (= (turn) 0)
         (= (walls) (set-index walls true 1 1))
         (= (walls) (set-index walls true 1 2))
         (= (walls) (set-index walls true 1 3))
         (= (walls) (set-index walls true 1 4))
         (= (xloc key1) 5)
         (= (yloc key1) 1)
         (iscolor key1 yellow)
         (= (xloc key2) 6)
         (= (yloc key2) 1)
         (iscolor key2 red)
         (= (walls) (set-index walls true 1 7))
         (= (walls) (set-index walls true 1 8))
         (= (walls) (set-index walls true 1 9))
         (= (walls) (set-index walls true 1 10))
         (= (walls) (set-index walls true 2 1))
         (= (xloc door1) 4)
         (= (yloc door1) 2)
         (iscolor door1 blue)
         (locked door1)
         (= (xloc key3) 7)
         (= (yloc key3) 2)
         (iscolor key3 blue)
         (= (walls) (set-index walls true 2 8))
         (= (walls) (set-index walls true 2 9))
         (= (walls) (set-index walls true 2 10))
         (= (xloc gem1) 1)
         (= (yloc gem1) 3)
         (= (xloc door2) 2)
         (= (yloc door2) 3)
         (iscolor door2 red)
         (locked door2)
         (= (walls) (set-index walls true 3 3))
         (= (walls) (set-index walls true 3 4))
         (= (walls) (set-index walls true 3 5))
         (= (walls) (set-index walls true 3 7))
         (= (walls) (set-index walls true 3 8))
         (= (walls) (set-index walls true 3 9))
         (= (walls) (set-index walls true 3 10))
         (= (walls) (set-index walls true 4 1))
         (= (walls) (set-index walls true 4 3))
         (= (walls) (set-index walls true 4 4))
         (= (walls) (set-index walls true 4 5))
         (= (walls) (set-index walls true 4 7))
         (= (xloc door3) 9)
         (= (yloc door3) 4)
         (iscolor door3 red)
         (locked door3)
         (= (xloc gem2) 10)
         (= (yloc gem2) 4)
         (= (walls) (set-index walls true 5 1))
         (= (walls) (set-index walls true 5 3))
         (= (walls) (set-index walls true 5 4))
         (= (walls) (set-index walls true 5 5))
         (= (walls) (set-index walls true 5 7))
         (= (xloc door4) 8)
         (= (yloc door4) 5)
         (iscolor door4 blue)
         (locked door4)
         (= (walls) (set-index walls true 5 9))
         (= (walls) (set-index walls true 5 10))
         (= (xloc gem3) 1)
         (= (yloc gem3) 6)
         (= (xloc door5) 9)
         (= (yloc door5) 6)
         (iscolor door5 yellow)
         (locked door5)
         (= (xloc gem4) 10)
         (= (yloc gem4) 6)
         (= (walls) (set-index walls true 7 1))
         (= (walls) (set-index walls true 7 2))
         (= (walls) (set-index walls true 7 3))
         (= (walls) (set-index walls true 7 4))
         (= (walls) (set-index walls true 7 5))
         (= (walls) (set-index walls true 7 6))
         (= (walls) (set-index walls true 7 7))
         (= (walls) (set-index walls true 7 8))
         (= (walls) (set-index walls true 7 9))
         (= (walls) (set-index walls true 7 10))
         (= (xloc human) 3)
         (= (yloc human) 6)
         (= (xloc robot) 6)
         (= (yloc robot) 3))
  (:goal (has human gem4))
)