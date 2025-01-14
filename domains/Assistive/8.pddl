(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 - door
            key1 key2 key3 key4 - key
            gem1 gem2 gem3 gem4 - gem
            blue red - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 10 11))
         (= (agentcode human) 0)
         (= (agentcode robot) 1)
         (= (turn) 0)
         (= (xloc key1) 1)
         (= (yloc key1) 1)
         (iscolor key1 blue)
         (= (xloc key2) 3)
         (= (yloc key2) 1)
         (iscolor key2 red)
         (= (walls) (set-index walls true 1 4))
         (= (walls) (set-index walls true 1 5))
         (= (walls) (set-index walls true 1 6))
         (= (walls) (set-index walls true 1 7))
         (= (walls) (set-index walls true 1 8))
         (= (walls) (set-index walls true 1 9))
         (= (xloc gem1) 10)
         (= (yloc gem1) 1)
         (= (walls) (set-index walls true 1 11))
         (= (walls) (set-index walls true 2 1))
         (= (walls) (set-index walls true 2 2))
         (= (walls) (set-index walls true 2 4))
         (= (walls) (set-index walls true 2 5))
         (= (walls) (set-index walls true 2 6))
         (= (walls) (set-index walls true 2 7))
         (= (walls) (set-index walls true 2 8))
         (= (walls) (set-index walls true 2 9))
         (= (xloc door1) 10)
         (= (yloc door1) 2)
         (iscolor door1 blue)
         (locked door1)
         (= (walls) (set-index walls true 2 11))
         (= (xloc gem2) 1)
         (= (yloc gem2) 3)
         (= (walls) (set-index walls true 3 11))
         (= (walls) (set-index walls true 4 1))
         (= (walls) (set-index walls true 4 2))
         (= (walls) (set-index walls true 4 3))
         (= (walls) (set-index walls true 4 5))
         (= (walls) (set-index walls true 4 6))
         (= (walls) (set-index walls true 4 7))
         (= (walls) (set-index walls true 4 8))
         (= (walls) (set-index walls true 4 9))
         (= (xloc key3) 10)
         (= (yloc key3) 4)
         (iscolor key3 blue)
         (= (walls) (set-index walls true 4 11))
         (= (walls) (set-index walls true 5 1))
         (= (walls) (set-index walls true 5 2))
         (= (walls) (set-index walls true 5 3))
         (= (walls) (set-index walls true 5 5))
         (= (walls) (set-index walls true 5 6))
         (= (walls) (set-index walls true 5 7))
         (= (walls) (set-index walls true 5 8))
         (= (walls) (set-index walls true 5 9))
         (= (walls) (set-index walls true 5 11))
         (= (walls) (set-index walls true 6 1))
         (= (walls) (set-index walls true 6 2))
         (= (walls) (set-index walls true 6 3))
         (= (walls) (set-index walls true 6 5))
         (= (walls) (set-index walls true 6 6))
         (= (walls) (set-index walls true 6 7))
         (= (walls) (set-index walls true 6 8))
         (= (walls) (set-index walls true 6 9))
         (= (walls) (set-index walls true 6 11))
         (= (walls) (set-index walls true 7 1))
         (= (walls) (set-index walls true 7 2))
         (= (walls) (set-index walls true 7 3))
         (= (walls) (set-index walls true 7 5))
         (= (walls) (set-index walls true 7 6))
         (= (walls) (set-index walls true 7 7))
         (= (walls) (set-index walls true 7 8))
         (= (walls) (set-index walls true 7 9))
         (= (walls) (set-index walls true 7 11))
         (= (xloc gem3) 1)
         (= (yloc gem3) 8)
         (= (xloc door2) 2)
         (= (yloc door2) 8)
         (iscolor door2 red)
         (locked door2)
         (= (xloc key4) 5)
         (= (yloc key4) 8)
         (iscolor key4 red)
         (= (xloc door3) 11)
         (= (yloc door3) 8)
         (iscolor door3 blue)
         (locked door3)
         (= (walls) (set-index walls true 9 1))
         (= (walls) (set-index walls true 9 2))
         (= (walls) (set-index walls true 9 3))
         (= (walls) (set-index walls true 9 4))
         (= (walls) (set-index walls true 9 5))
         (= (walls) (set-index walls true 9 6))
         (= (walls) (set-index walls true 9 7))
         (= (walls) (set-index walls true 9 8))
         (= (walls) (set-index walls true 9 9))
         (= (walls) (set-index walls true 9 10))
         (= (xloc door4) 11)
         (= (yloc door4) 9)
         (iscolor door4 red)
         (locked door4)
         (= (walls) (set-index walls true 10 1))
         (= (walls) (set-index walls true 10 2))
         (= (walls) (set-index walls true 10 3))
         (= (walls) (set-index walls true 10 4))
         (= (walls) (set-index walls true 10 5))
         (= (walls) (set-index walls true 10 6))
         (= (walls) (set-index walls true 10 7))
         (= (walls) (set-index walls true 10 8))
         (= (walls) (set-index walls true 10 9))
         (= (walls) (set-index walls true 10 10))
         (= (xloc gem4) 11)
         (= (yloc gem4) 10)
         (= (xloc human) 4)
         (= (yloc human) 3)
         (= (xloc robot) 4)
         (= (yloc robot) 4))
  (:goal (has human gem4))
)