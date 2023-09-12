(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 - door
            key1 key2 - key
            gem1 gem2 gem3 gem4 - gem
            blue red - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 8 8))
         (= (walls) (set-index walls true 1 1))
         (= (walls) (set-index walls true 1 2))
         (= (walls) (set-index walls true 1 3))
         (= (walls) (set-index walls true 1 4))
         (= (walls) (set-index walls true 1 5))
         (= (xloc key1) 6)
         (= (yloc key1) 1)
         (iscolor key1 red)
         (= (walls) (set-index walls true 1 7))
         (= (walls) (set-index walls true 1 8))
         (= (walls) (set-index walls true 2 1))
         (= (xloc gem1) 2)
         (= (yloc gem1) 2)
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
         (= (xloc key2) 8)
         (= (yloc key2) 3)
         (iscolor key2 blue)
         (= (walls) (set-index walls true 4 1))
         (= (walls) (set-index walls true 4 3))
         (= (walls) (set-index walls true 4 4))
         (= (walls) (set-index walls true 4 5))
         (= (walls) (set-index walls true 4 7))
         (= (walls) (set-index walls true 4 8))
         (= (walls) (set-index walls true 5 1))
         (= (xloc door2) 2)
         (= (yloc door2) 5)
         (iscolor door2 red)
         (locked door2)
         (= (walls) (set-index walls true 5 3))
         (= (walls) (set-index walls true 5 4))
         (= (walls) (set-index walls true 5 5))
         (= (xloc door3) 6)
         (= (yloc door3) 5)
         (iscolor door3 blue)
         (locked door3)
         (= (walls) (set-index walls true 5 7))
         (= (walls) (set-index walls true 5 8))
         (= (xloc gem2) 1)
         (= (yloc gem2) 6)
         (= (walls) (set-index walls true 6 3))
         (= (walls) (set-index walls true 6 4))
         (= (walls) (set-index walls true 6 5))
         (= (walls) (set-index walls true 6 7))
         (= (walls) (set-index walls true 6 8))
         (= (walls) (set-index walls true 7 1))
         (= (xloc door4) 7)
         (= (yloc door4) 7)
         (iscolor door4 red)
         (locked door4)
         (= (xloc gem3) 8)
         (= (yloc gem3) 7)
         (= (walls) (set-index walls true 8 1))
         (= (walls) (set-index walls true 8 2))
         (= (xloc gem4) 3)
         (= (yloc gem4) 8)
         (= (walls) (set-index walls true 8 4))
         (= (walls) (set-index walls true 8 5))
         (= (walls) (set-index walls true 8 6))
         (= (walls) (set-index walls true 8 7))
         (= (walls) (set-index walls true 8 8))
         (= (xloc human) 3)
         (= (yloc human) 7)
         (= (xloc robot) 6)
         (= (yloc robot) 3)
         (active human)
         (next-turn human robot)
         (next-turn robot human)
         (forbidden robot gem1)
         (forbidden robot gem2)
         (forbidden robot gem3)
         (forbidden robot gem4))
  (:goal (has human gem4))
)