(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 - door
            key1 key2 - key
            gem1 gem2 gem3 gem4 - gem
            red yellow blue green - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 8 8))
         (= (walls) (set-index walls true 1 2))
         (= (xloc gem1) 3)
         (= (yloc gem1) 1)
         (= (walls) (set-index walls true 1 4))
         (= (walls) (set-index walls true 1 5))
         (= (walls) (set-index walls true 1 6))
         (= (walls) (set-index walls true 1 7))
         (= (walls) (set-index walls true 1 8))
         (= (walls) (set-index walls true 2 2))
         (= (xloc door1) 3)
         (= (yloc door1) 2)
         (iscolor door1 red)
         (locked door1)
         (= (walls) (set-index walls true 2 4))
         (= (walls) (set-index walls true 2 5))
         (= (walls) (set-index walls true 2 6))
         (= (walls) (set-index walls true 2 7))
         (= (xloc gem2) 8)
         (= (yloc gem2) 2)
         (= (xloc key1) 1)
         (= (yloc key1) 3)
         (iscolor key1 red)
         (= (xloc door2) 5)
         (= (yloc door2) 3)
         (iscolor door2 blue)
         (locked door2)
         (= (xloc door3) 7)
         (= (yloc door3) 3)
         (iscolor door3 red)
         (locked door3)
         (= (walls) (set-index walls true 4 1))
         (= (walls) (set-index walls true 4 2))
         (= (walls) (set-index walls true 4 4))
         (= (walls) (set-index walls true 4 5))
         (= (walls) (set-index walls true 4 7))
         (= (xloc gem3) 8)
         (= (yloc gem3) 4)
         (= (walls) (set-index walls true 5 1))
         (= (walls) (set-index walls true 5 2))
         (= (xloc door4) 3)
         (= (yloc door4) 5)
         (iscolor door4 blue)
         (locked door4)
         (= (walls) (set-index walls true 5 4))
         (= (walls) (set-index walls true 5 5))
         (= (walls) (set-index walls true 5 7))
         (= (walls) (set-index walls true 5 8))
         (= (walls) (set-index walls true 6 1))
         (= (walls) (set-index walls true 6 2))
         (= (walls) (set-index walls true 6 4))
         (= (walls) (set-index walls true 6 5))
         (= (walls) (set-index walls true 6 7))
         (= (walls) (set-index walls true 6 8))
         (= (xloc gem4) 1)
         (= (yloc gem4) 7)
         (= (xloc key2) 8)
         (= (yloc key2) 7)
         (iscolor key2 blue)
         (= (walls) (set-index walls true 8 1))
         (= (walls) (set-index walls true 8 2))
         (= (walls) (set-index walls true 8 3))
         (= (walls) (set-index walls true 8 4))
         (= (walls) (set-index walls true 8 5))
         (= (walls) (set-index walls true 8 7))
         (= (walls) (set-index walls true 8 8))
         (= (xloc human) 1)
         (= (yloc human) 1)
         (= (xloc robot) 6)
         (= (yloc robot) 7)
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
  (:goal (has human gem4))
)