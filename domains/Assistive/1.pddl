(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 - door
            key1 key2 - key
            gem1 gem2 gem3 gem4 - gem
            red yellow - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 8 8))
         (= (xloc key1) 1)
         (= (yloc key1) 1)
         (iscolor key1 red)
         (= (walls) (set-index walls true 1 6))
         (= (walls) (set-index walls true 1 7))
         (= (xloc gem1) 8)
         (= (yloc gem1) 1)
         (= (xloc key2) 1)
         (= (yloc key2) 2)
         (iscolor key2 yellow)
         (= (walls) (set-index walls true 2 3))
         (= (walls) (set-index walls true 2 4))
         (= (walls) (set-index walls true 2 6))
         (= (walls) (set-index walls true 2 7))
         (= (walls) (set-index walls true 3 1))
         (= (walls) (set-index walls true 3 2))
         (= (walls) (set-index walls true 3 3))
         (= (walls) (set-index walls true 3 4))
         (= (walls) (set-index walls true 3 6))
         (= (walls) (set-index walls true 3 7))
         (= (xloc door1) 2)
         (= (yloc door1) 4)
         (iscolor door1 red)
         (locked door1)
         (= (walls) (set-index walls true 5 2))
         (= (walls) (set-index walls true 5 4))
         (= (walls) (set-index walls true 5 5))
         (= (walls) (set-index walls true 5 6))
         (= (walls) (set-index walls true 5 7))
         (= (walls) (set-index walls true 6 2))
         (= (walls) (set-index walls true 6 4))
         (= (walls) (set-index walls true 6 5))
         (= (walls) (set-index walls true 6 6))
         (= (walls) (set-index walls true 6 7))
         (= (xloc door2) 8)
         (= (yloc door2) 6)
         (iscolor door2 yellow)
         (locked door2)
         (= (xloc door3) 1)
         (= (yloc door3) 7)
         (iscolor door3 yellow)
         (locked door3)
         (= (walls) (set-index walls true 7 2))
         (= (walls) (set-index walls true 7 4))
         (= (walls) (set-index walls true 7 5))
         (= (walls) (set-index walls true 7 6))
         (= (walls) (set-index walls true 7 7))
         (= (xloc gem2) 1)
         (= (yloc gem2) 8)
         (= (walls) (set-index walls true 8 2))
         (= (xloc gem3) 3)
         (= (yloc gem3) 8)
         (= (walls) (set-index walls true 8 4))
         (= (walls) (set-index walls true 8 5))
         (= (walls) (set-index walls true 8 6))
         (= (walls) (set-index walls true 8 7))
         (= (xloc gem4) 8)
         (= (yloc gem4) 8)
         (= (xloc human) 7)
         (= (yloc human) 4)
         (= (xloc robot) 5)
         (= (yloc robot) 1)
         (active human)
         (next-turn human robot)
         (next-turn robot human)
         (forbidden robot gem1)
         (forbidden robot gem2)
         (forbidden robot gem3)
         (forbidden robot gem4))
  (:goal (has human gem4))
)