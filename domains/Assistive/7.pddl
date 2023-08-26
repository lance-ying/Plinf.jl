(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 door5 - door
            key1 key2 key3 key4 key5 - key
            gem1 gem2 gem3 gem4 - gem
            red yellow blue - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 11 11))
         (= (agentcode human) 0)
         (= (agentcode robot) 1)
         (= (turn) 0)
         (= (walls) (set-index walls true 1 1))
         (= (xloc gem1) 4)
         (= (yloc gem1) 1)
         (= (walls) (set-index walls true 1 5))
         (= (walls) (set-index walls true 1 6))
         (= (walls) (set-index walls true 1 7))
         (= (xloc gem2) 8)
         (= (yloc gem2) 1)
         (= (walls) (set-index walls true 1 9))
         (= (walls) (set-index walls true 1 10))
         (= (walls) (set-index walls true 1 11))
         (= (walls) (set-index walls true 2 1))
         (= (walls) (set-index walls true 2 3))
         (= (walls) (set-index walls true 2 4))
         (= (walls) (set-index walls true 2 5))
         (= (walls) (set-index walls true 2 6))
         (= (walls) (set-index walls true 2 7))
         (= (walls) (set-index walls true 2 9))
         (= (walls) (set-index walls true 2 10))
         (= (walls) (set-index walls true 2 11))
         (= (walls) (set-index walls true 3 1))
         (= (xloc door1) 2)
         (= (yloc door1) 3)
         (iscolor door1 red)
         (locked door1)
         (= (walls) (set-index walls true 3 3))
         (= (walls) (set-index walls true 3 4))
         (= (walls) (set-index walls true 3 5))
         (= (walls) (set-index walls true 3 6))
         (= (walls) (set-index walls true 3 7))
         (= (xloc door2) 8)
         (= (yloc door2) 3)
         (iscolor door2 yellow)
         (locked door2)
         (= (walls) (set-index walls true 3 9))
         (= (walls) (set-index walls true 3 10))
         (= (walls) (set-index walls true 3 11))
         (= (walls) (set-index walls true 5 1))
         (= (walls) (set-index walls true 5 2))
         (= (walls) (set-index walls true 5 3))
         (= (walls) (set-index walls true 5 4))
         (= (walls) (set-index walls true 5 5))
         (= (walls) (set-index walls true 5 6))
         (= (walls) (set-index walls true 5 7))
         (= (walls) (set-index walls true 5 8))
         (= (xloc door3) 9)
         (= (yloc door3) 5)
         (iscolor door3 red)
         (locked door3)
         (= (walls) (set-index walls true 5 10))
         (= (walls) (set-index walls true 5 11))
         (= (xloc key1) 8)
         (= (yloc key1) 6)
         (iscolor key1 yellow)
         (= (xloc door4) 10)
         (= (yloc door4) 6)
         (iscolor door4 blue)
         (locked door4)
         (= (xloc gem3) 11)
         (= (yloc gem3) 6)
         (= (walls) (set-index walls true 7 1))
         (= (walls) (set-index walls true 7 2))
         (= (walls) (set-index walls true 7 4))
         (= (walls) (set-index walls true 7 5))
         (= (walls) (set-index walls true 7 6))
         (= (walls) (set-index walls true 7 7))
         (= (walls) (set-index walls true 7 8))
         (= (walls) (set-index walls true 7 10))
         (= (walls) (set-index walls true 7 11))
         (= (xloc key2) 1)
         (= (yloc key2) 8)
         (iscolor key2 blue)
         (= (walls) (set-index walls true 8 2))
         (= (walls) (set-index walls true 8 4))
         (= (walls) (set-index walls true 8 5))
         (= (walls) (set-index walls true 8 6))
         (= (walls) (set-index walls true 8 7))
         (= (xloc key3) 8)
         (= (yloc key3) 8)
         (iscolor key3 red)
         (= (walls) (set-index walls true 8 10))
         (= (walls) (set-index walls true 8 11))
         (= (xloc key4) 1)
         (= (yloc key4) 9)
         (iscolor key4 red)
         (= (xloc key5) 9)
         (= (yloc key5) 9)
         (iscolor key5 blue)
         (= (walls) (set-index walls true 9 10))
         (= (walls) (set-index walls true 9 11))
         (= (walls) (set-index walls true 10 1))
         (= (walls) (set-index walls true 10 2))
         (= (xloc door5) 3)
         (= (yloc door5) 10)
         (iscolor door5 red)
         (locked door5)
         (= (walls) (set-index walls true 10 4))
         (= (walls) (set-index walls true 10 5))
         (= (walls) (set-index walls true 10 6))
         (= (walls) (set-index walls true 10 7))
         (= (walls) (set-index walls true 10 8))
         (= (walls) (set-index walls true 10 9))
         (= (walls) (set-index walls true 10 10))
         (= (walls) (set-index walls true 10 11))
         (= (walls) (set-index walls true 11 1))
         (= (walls) (set-index walls true 11 2))
         (= (xloc gem4) 3)
         (= (yloc gem4) 11)
         (= (walls) (set-index walls true 11 4))
         (= (walls) (set-index walls true 11 5))
         (= (walls) (set-index walls true 11 6))
         (= (walls) (set-index walls true 11 7))
         (= (walls) (set-index walls true 11 8))
         (= (walls) (set-index walls true 11 9))
         (= (walls) (set-index walls true 11 10))
         (= (walls) (set-index walls true 11 11))
         (= (xloc human) 1)
         (= (yloc human) 6)
         (= (xloc robot) 5)
         (= (yloc robot) 9))
  (:goal (has human gem4))
)