(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 - door
            key1 key2 key3 key4 key5 key6 - key
            gem1 gem2 gem3 gem4 - gem
            blue red - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 11 9))
         (= (agentcode human) 0)
         (= (agentcode robot) 1)
         (= (turn) 0)
         (= (walls) (set-index walls true 1 1))
         (= (walls) (set-index walls true 1 2))
         (= (xloc key1) 3)
         (= (yloc key1) 1)
         (iscolor key1 blue)
         (= (walls) (set-index walls true 1 4))
         (= (walls) (set-index walls true 1 5))
         (= (walls) (set-index walls true 1 6))
         (= (xloc key2) 7)
         (= (yloc key2) 1)
         (iscolor key2 red)
         (= (walls) (set-index walls true 1 8))
         (= (walls) (set-index walls true 1 9))
         (= (walls) (set-index walls true 2 1))
         (= (xloc key3) 2)
         (= (yloc key3) 2)
         (iscolor key3 red)
         (= (xloc key4) 4)
         (= (yloc key4) 2)
         (iscolor key4 red)
         (= (walls) (set-index walls true 2 5))
         (= (xloc key5) 6)
         (= (yloc key5) 2)
         (iscolor key5 blue)
         (= (xloc key6) 8)
         (= (yloc key6) 2)
         (iscolor key6 blue)
         (= (walls) (set-index walls true 2 9))
         (= (walls) (set-index walls true 3 1))
         (= (walls) (set-index walls true 3 2))
         (= (walls) (set-index walls true 3 4))
         (= (walls) (set-index walls true 3 5))
         (= (walls) (set-index walls true 3 6))
         (= (walls) (set-index walls true 3 8))
         (= (walls) (set-index walls true 3 9))
         (= (walls) (set-index walls true 4 1))
         (= (walls) (set-index walls true 4 2))
         (= (walls) (set-index walls true 4 8))
         (= (walls) (set-index walls true 4 9))
         (= (walls) (set-index walls true 5 1))
         (= (walls) (set-index walls true 5 2))
         (= (walls) (set-index walls true 5 3))
         (= (walls) (set-index walls true 5 4))
         (= (walls) (set-index walls true 5 6))
         (= (walls) (set-index walls true 5 7))
         (= (walls) (set-index walls true 5 8))
         (= (xloc gem1) 9)
         (= (yloc gem1) 5)
         (= (xloc door1) 7)
         (= (yloc door1) 6)
         (iscolor door1 blue)
         (locked door1)
         (= (xloc door2) 8)
         (= (yloc door2) 6)
         (iscolor door2 blue)
         (locked door2)
         (= (walls) (set-index walls true 7 1))
         (= (walls) (set-index walls true 7 2))
         (= (walls) (set-index walls true 7 3))
         (= (walls) (set-index walls true 7 4))
         (= (walls) (set-index walls true 7 6))
         (= (walls) (set-index walls true 7 7))
         (= (walls) (set-index walls true 7 8))
         (= (xloc gem2) 9)
         (= (yloc gem2) 7)
         (= (walls) (set-index walls true 8 1))
         (= (walls) (set-index walls true 8 2))
         (= (walls) (set-index walls true 8 3))
         (= (walls) (set-index walls true 8 4))
         (= (walls) (set-index walls true 8 6))
         (= (walls) (set-index walls true 8 7))
         (= (walls) (set-index walls true 8 8))
         (= (walls) (set-index walls true 8 9))
         (= (walls) (set-index walls true 9 1))
         (= (walls) (set-index walls true 9 2))
         (= (walls) (set-index walls true 9 3))
         (= (walls) (set-index walls true 9 4))
         (= (xloc door3) 5)
         (= (yloc door3) 9)
         (iscolor door3 red)
         (locked door3)
         (= (walls) (set-index walls true 9 6))
         (= (walls) (set-index walls true 9 7))
         (= (walls) (set-index walls true 9 8))
         (= (walls) (set-index walls true 9 9))
         (= (walls) (set-index walls true 10 1))
         (= (walls) (set-index walls true 10 2))
         (= (walls) (set-index walls true 10 3))
         (= (walls) (set-index walls true 10 4))
         (= (xloc door4) 5)
         (= (yloc door4) 10)
         (iscolor door4 red)
         (locked door4)
         (= (walls) (set-index walls true 10 6))
         (= (walls) (set-index walls true 10 7))
         (= (walls) (set-index walls true 10 8))
         (= (walls) (set-index walls true 10 9))
         (= (xloc gem3) 1)
         (= (yloc gem3) 11)
         (= (xloc gem4) 9)
         (= (yloc gem4) 11)
         (= (xloc human) 1)
         (= (yloc human) 6)
         (= (xloc robot) 5)
         (= (yloc robot) 4))
  (:goal (has human gem4))
)