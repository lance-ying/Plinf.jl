(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 - door
            key1 key2 key3 - key
            gem1 gem2 gem3 gem4 - gem
            red blue - color
            human robot - agent)
  (:init (= (walls) (new-bit-matrix false 8 8))
         (= (agentcode human) 0)
         (= (agentcode robot) 1)
         (= (turn) 0)
         (= (xloc gem1) 3)
         (= (yloc gem1) 1)
         (= (walls) (set-index walls true 1 4))
         (= (walls) (set-index walls true 1 5))
         (= (walls) (set-index walls true 1 6))
         (= (walls) (set-index walls true 1 7))
         (= (walls) (set-index walls true 1 8))
         (= (walls) (set-index walls true 2 3))
         (= (walls) (set-index walls true 2 4))
         (= (walls) (set-index walls true 2 5))
         (= (xloc key1) 6)
         (= (yloc key1) 2)
         (iscolor key1 red)
         (= (xloc key2) 8)
         (= (yloc key2) 2)
         (iscolor key2 red)
         (= (walls) (set-index walls true 3 2))
         (= (walls) (set-index walls true 3 3))
         (= (walls) (set-index walls true 3 4))
         (= (walls) (set-index walls true 3 5))
         (= (xloc key3) 6)
         (= (yloc key3) 3)
         (iscolor key3 blue)
         (= (xloc gem2) 2)
         (= (yloc gem2) 4)
         (= (walls) (set-index walls true 4 3))
         (= (walls) (set-index walls true 4 4))
         (= (walls) (set-index walls true 4 5))
         (= (walls) (set-index walls true 4 6))
         (= (walls) (set-index walls true 4 8))
         (= (xloc door1) 1)
         (= (yloc door1) 5)
         (iscolor door1 red)
         (locked door1)
         (= (walls) (set-index walls true 5 2))
         (= (walls) (set-index walls true 5 3))
         (= (walls) (set-index walls true 5 4))
         (= (walls) (set-index walls true 5 5))
         (= (walls) (set-index walls true 5 6))
         (= (xloc door2) 7)
         (= (yloc door2) 5)
         (iscolor door2 red)
         (locked door2)
         (= (walls) (set-index walls true 5 8))
         (= (walls) (set-index walls true 7 1))
         (= (walls) (set-index walls true 7 2))
         (= (walls) (set-index walls true 7 3))
         (= (walls) (set-index walls true 7 5))
         (= (walls) (set-index walls true 7 6))
         (= (walls) (set-index walls true 7 7))
         (= (walls) (set-index walls true 7 8))
         (= (xloc gem3) 1)
         (= (yloc gem3) 8)
         (= (xloc door3) 2)
         (= (yloc door3) 8)
         (iscolor door3 blue)
         (locked door3)
         (= (xloc gem4) 8)
         (= (yloc gem4) 8)
         (= (xloc human) 4)
         (= (yloc human) 6)
         (= (xloc robot) 7)
         (= (yloc robot) 4))
  (:goal (has human gem1))
)