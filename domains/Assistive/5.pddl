(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 door5 - door
            key1 key2 key3 - key
            gem1 gem2 gem3 gem4 - gem
            blue red - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 9 10))
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
         (= (walls) (set-index walls true 1 9))
         (= (walls) (set-index walls true 1 10))
         (= (walls) (set-index walls true 2 1))
         (= (walls) (set-index walls true 2 2))
         (= (walls) (set-index walls true 2 3))
         (= (walls) (set-index walls true 2 4))
         (= (walls) (set-index walls true 2 5))
         (= (walls) (set-index walls true 2 10))
         (= (xloc gem1) 1)
         (= (yloc gem1) 3)
         (= (walls) (set-index walls true 3 2))
         (= (xloc gem2) 3)
         (= (yloc gem2) 3)
         (= (walls) (set-index walls true 3 4))
         (= (walls) (set-index walls true 3 5))
         (= (walls) (set-index walls true 3 6))
         (= (walls) (set-index walls true 3 7))
         (= (walls) (set-index walls true 3 8))
         (= (walls) (set-index walls true 3 10))
         (= (walls) (set-index walls true 4 2))
         (= (walls) (set-index walls true 4 4))
         (= (walls) (set-index walls true 4 5))
         (= (walls) (set-index walls true 4 6))
         (= (walls) (set-index walls true 4 7))
         (= (walls) (set-index walls true 4 8))
         (= (xloc key2) 9)
         (= (yloc key2) 4)
         (iscolor key2 blue)
         (= (walls) (set-index walls true 4 10))
         (= (xloc door1) 1)
         (= (yloc door1) 5)
         (iscolor door1 blue)
         (locked door1)
         (= (walls) (set-index walls true 5 2))
         (= (xloc door2) 3)
         (= (yloc door2) 5)
         (iscolor door2 red)
         (locked door2)
         (= (walls) (set-index walls true 5 4))
         (= (walls) (set-index walls true 5 5))
         (= (walls) (set-index walls true 5 6))
         (= (walls) (set-index walls true 5 7))
         (= (walls) (set-index walls true 5 8))
         (= (walls) (set-index walls true 5 10))
         (= (walls) (set-index walls true 6 4))
         (= (walls) (set-index walls true 6 5))
         (= (walls) (set-index walls true 6 6))
         (= (walls) (set-index walls true 6 7))
         (= (walls) (set-index walls true 6 8))
         (= (xloc key3) 9)
         (= (yloc key3) 6)
         (iscolor key3 red)
         (= (walls) (set-index walls true 6 10))
         (= (walls) (set-index walls true 7 1))
         (= (walls) (set-index walls true 7 2))
         (= (walls) (set-index walls true 7 10))
         (= (walls) (set-index walls true 8 1))
         (= (walls) (set-index walls true 8 2))
         (= (walls) (set-index walls true 8 3))
         (= (walls) (set-index walls true 8 4))
         (= (walls) (set-index walls true 8 6))
         (= (walls) (set-index walls true 8 7))
         (= (walls) (set-index walls true 8 8))
         (= (walls) (set-index walls true 8 9))
         (= (walls) (set-index walls true 8 10))
         (= (xloc gem3) 1)
         (= (yloc gem3) 9)
         (= (xloc door3) 3)
         (= (yloc door3) 9)
         (iscolor door3 red)
         (locked door3)
         (= (xloc door4) 7)
         (= (yloc door4) 9)
         (iscolor door4 blue)
         (locked door4)
         (= (xloc door5) 9)
         (= (yloc door5) 9)
         (iscolor door5 red)
         (locked door5)
         (= (xloc gem4) 10)
         (= (yloc gem4) 9)
         (= (xloc human) 5)
         (= (yloc human) 7)
         (= (xloc robot) 9)
         (= (yloc robot) 2)
         (active human)
         (next-turn human robot)
         (next-turn robot human)
         (forbidden robot gem1)
         (forbidden robot gem2)
         (forbidden robot gem3)
         (forbidden robot gem4))
  (:goal (has human gem4))
)