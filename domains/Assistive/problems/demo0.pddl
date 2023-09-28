(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 - door
            key1 key2 key3 - key
            gem1 gem2 gem3 gem4 - gem
            red - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 8 8))
         (= (xloc gem1) 1)
         (= (yloc gem1) 1)
         (= (walls) (set-index walls true 1 2))
         (= (walls) (set-index walls true 1 3))
         (= (walls) (set-index walls true 1 4))
         (= (walls) (set-index walls true 1 5))
         (= (walls) (set-index walls true 1 6))
         (= (walls) (set-index walls true 1 7))
         (= (walls) (set-index walls true 1 8))
         (= (xloc door1) 1)
         (= (yloc door1) 2)
         (iscolor door1 red)
         (locked door1)
         (= (xloc door2) 6)
         (= (yloc door2) 2)
         (iscolor door2 red)
         (locked door2)
         (= (xloc gem2) 8)
         (= (yloc gem2) 2)
         (= (walls) (set-index walls true 3 1))
         (= (walls) (set-index walls true 3 3))
         (= (walls) (set-index walls true 3 4))
         (= (walls) (set-index walls true 3 6))
         (= (walls) (set-index walls true 3 7))
         (= (walls) (set-index walls true 3 8))
         (= (walls) (set-index walls true 4 1))
         (= (walls) (set-index walls true 4 3))
         (= (walls) (set-index walls true 4 4))
         (= (walls) (set-index walls true 4 6))
         (= (walls) (set-index walls true 4 7))
         (= (walls) (set-index walls true 4 8))
         (= (walls) (set-index walls true 5 1))
         (= (xloc key1) 2)
         (= (yloc key1) 5)
         (iscolor key1 red)
         (= (walls) (set-index walls true 5 3))
         (= (walls) (set-index walls true 5 4))
         (= (xloc key2) 5)
         (= (yloc key2) 5)
         (iscolor key2 red)
         (= (walls) (set-index walls true 5 6))
         (= (walls) (set-index walls true 5 7))
         (= (walls) (set-index walls true 5 8))
         (= (xloc gem3) 1)
         (= (yloc gem3) 6)
         (= (xloc gem4) 8)
         (= (yloc gem4) 6)
         (= (walls) (set-index walls true 7 1))
         (= (walls) (set-index walls true 7 2))
         (= (walls) (set-index walls true 7 3))
         (= (walls) (set-index walls true 7 5))
         (= (walls) (set-index walls true 7 6))
         (= (walls) (set-index walls true 7 7))
         (= (walls) (set-index walls true 7 8))
         (= (walls) (set-index walls true 8 1))
         (= (walls) (set-index walls true 8 2))
         (= (walls) (set-index walls true 8 3))
         (= (xloc key3) 4)
         (= (yloc key3) 8)
         (iscolor key3 red)
         (= (walls) (set-index walls true 8 5))
         (= (walls) (set-index walls true 8 6))
         (= (walls) (set-index walls true 8 7))
         (= (walls) (set-index walls true 8 8))
         (= (xloc human) 2)
         (= (yloc human) 2)
         (= (xloc robot) 4)
         (= (yloc robot) 6)
         (iscolor gem1 red)
         (iscolor gem2 yellow)
         (iscolor gem3 blue)
         (iscolor gem4 green)
         (active human)
         (next-turn human robot)
         (next-turn robot human)
         (forbidden robot gem1)
         (forbidden robot gem2)
         (forbidden robot gem3)
         (forbidden robot gem4))
  (:goal (has human gem2))
)