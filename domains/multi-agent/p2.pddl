(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 door5 - door
            key1 key2 key3 key4 - key
            gem1 gem2 gem3 gem4 - gem
            red yellow blue - color
            human robot - agent)
  (:init (= (walls) (new-bit-matrix false 10 10))
         (= (agentcode human) 0)
         (= (agentcode robot) 1)
         (= (turn) 0)
         (= (walls) (set-index walls true 1 1))
         (= (xloc gem1) 4)
         (= (yloc gem1) 1)
         (= (walls) (set-index walls true 1 5))
         (= (walls) (set-index walls true 1 6))
         (= (xloc gem2) 7)
         (= (yloc gem2) 1)
         (= (walls) (set-index walls true 1 8))
         (= (walls) (set-index walls true 1 9))
         (= (walls) (set-index walls true 1 10))
         (= (walls) (set-index walls true 2 1))
         (= (walls) (set-index walls true 2 3))
         (= (walls) (set-index walls true 2 4))
         (= (walls) (set-index walls true 2 5))
         (= (walls) (set-index walls true 2 6))
         (= (walls) (set-index walls true 2 8))
         (= (walls) (set-index walls true 2 9))
         (= (walls) (set-index walls true 2 10))
         (= (walls) (set-index walls true 3 1))
         (= (xloc door1) 2)
         (= (yloc door1) 3)
         (iscolor door1 red)
         (locked door1)
         (= (walls) (set-index walls true 3 3))
         (= (walls) (set-index walls true 3 4))
         (= (walls) (set-index walls true 3 5))
         (= (walls) (set-index walls true 3 6))
         (= (xloc door2) 7)
         (= (yloc door2) 3)
         (iscolor door2 yellow)
         (locked door2)
         (= (walls) (set-index walls true 3 8))
         (= (walls) (set-index walls true 3 9))
         (= (walls) (set-index walls true 3 10))
         (= (xloc key1) 1)
         (= (yloc key1) 4)
         (iscolor key1 red)
         (= (xloc gem3) 10)
         (= (yloc gem3) 4)
         (= (walls) (set-index walls true 5 1))
         (= (walls) (set-index walls true 5 2))
         (= (xloc door3) 3)
         (= (yloc door3) 5)
         (iscolor door3 red)
         (locked door3)
         (= (walls) (set-index walls true 5 4))
         (= (walls) (set-index walls true 5 5))
         (= (walls) (set-index walls true 5 6))
         (= (walls) (set-index walls true 5 7))
         (= (walls) (set-index walls true 5 8))
         (= (walls) (set-index walls true 5 9))
         (= (walls) (set-index walls true 5 10))
         (= (walls) (set-index walls true 6 1))
         (= (walls) (set-index walls true 6 2))
         (= (walls) (set-index walls true 6 4))
         (= (walls) (set-index walls true 6 5))
         (= (walls) (set-index walls true 6 6))
         (= (xloc key2) 7)
         (= (yloc key2) 6)
         (iscolor key2 red)
         (= (walls) (set-index walls true 6 8))
         (= (walls) (set-index walls true 6 9))
         (= (walls) (set-index walls true 6 10))
         (= (xloc key3) 10)
         (= (yloc key3) 7)
         (iscolor key3 blue)
         (= (walls) (set-index walls true 8 1))
         (= (walls) (set-index walls true 8 2))
         (= (walls) (set-index walls true 8 4))
         (= (walls) (set-index walls true 8 5))
         (= (walls) (set-index walls true 8 6))
         (= (walls) (set-index walls true 8 8))
         (= (walls) (set-index walls true 8 9))
         (= (walls) (set-index walls true 8 10))
         (= (walls) (set-index walls true 9 1))
         (= (walls) (set-index walls true 9 2))
         (= (walls) (set-index walls true 9 4))
         (= (walls) (set-index walls true 9 5))
         (= (walls) (set-index walls true 9 6))
         (= (xloc door4) 7)
         (= (yloc door4) 9)
         (iscolor door4 red)
         (locked door4)
         (= (walls) (set-index walls true 9 8))
         (= (walls) (set-index walls true 9 9))
         (= (walls) (set-index walls true 9 10))
         (= (xloc key4) 1)
         (= (yloc key4) 10)
         (iscolor key4 yellow)
         (= (walls) (set-index walls true 10 4))
         (= (walls) (set-index walls true 10 5))
         (= (walls) (set-index walls true 10 6))
         (= (xloc door5) 8)
         (= (yloc door5) 10)
         (iscolor door5 blue)
         (locked door5)
         (= (xloc gem4) 10)
         (= (yloc gem4) 10)
         (= (xloc human) 1)
         (= (yloc human) 7)
         (= (xloc robot) 8)
         (= (yloc robot) 7))
  (:goal (has human gem4))
)