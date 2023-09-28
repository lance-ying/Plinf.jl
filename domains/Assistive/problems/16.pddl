(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 - door
            key1 key2 - key
            gem1 gem2 gem3 gem4 - gem
            blue red - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 7 8))
         (= (walls) (set-index walls true 1 1))
         (= (xloc gem1) 2)
         (= (yloc gem1) 1)
         (= (walls) (set-index walls true 1 3))
         (= (walls) (set-index walls true 1 4))
         (= (walls) (set-index walls true 1 5))
         (= (xloc key1) 6)
         (= (yloc key1) 1)
         (iscolor key1 blue)
         (= (walls) (set-index walls true 1 7))
         (= (walls) (set-index walls true 1 8))
         (= (walls) (set-index walls true 2 1))
         (= (walls) (set-index walls true 2 3))
         (= (walls) (set-index walls true 2 4))
         (= (walls) (set-index walls true 2 5))
         (= (walls) (set-index walls true 2 7))
         (= (walls) (set-index walls true 2 8))
         (= (walls) (set-index walls true 3 1))
         (= (xloc door1) 2)
         (= (yloc door1) 3)
         (iscolor door1 blue)
         (locked door1)
         (= (xloc gem2) 4)
         (= (yloc gem2) 3)
         (= (walls) (set-index walls true 3 7))
         (= (xloc gem3) 8)
         (= (yloc gem3) 3)
         (= (walls) (set-index walls true 4 1))
         (= (walls) (set-index walls true 4 3))
         (= (walls) (set-index walls true 4 4))
         (= (walls) (set-index walls true 4 5))
         (= (walls) (set-index walls true 4 7))
         (= (walls) (set-index walls true 5 1))
         (= (walls) (set-index walls true 5 3))
         (= (walls) (set-index walls true 5 4))
         (= (walls) (set-index walls true 5 5))
         (= (xloc door2) 6)
         (= (yloc door2) 5)
         (iscolor door2 blue)
         (locked door2)
         (= (walls) (set-index walls true 6 1))
         (= (walls) (set-index walls true 6 3))
         (= (walls) (set-index walls true 6 4))
         (= (walls) (set-index walls true 6 5))
         (= (walls) (set-index walls true 6 7))
         (= (xloc key2) 1)
         (= (yloc key2) 7)
         (iscolor key2 red)
         (= (xloc door3) 6)
         (= (yloc door3) 7)
         (iscolor door3 red)
         (locked door3)
         (= (walls) (set-index walls true 7 7))
         (= (xloc gem4) 8)
         (= (yloc gem4) 7)
         (= (xloc human) 2)
         (= (yloc human) 5)
         (= (xloc robot) 6)
         (= (yloc robot) 3)
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