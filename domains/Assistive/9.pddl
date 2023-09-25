(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 door5 - door
            key1 key2 key3 - key
            gem1 gem2 gem3 gem4 - gem
            red blue - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 9 11))
         (= (xloc gem1) 1)
         (= (yloc gem1) 1)
         (= (xloc door1) 3)
         (= (yloc door1) 1)
         (iscolor door1 red)
         (locked door1)
         (= (xloc key1) 8)
         (= (yloc key1) 1)
         (iscolor key1 red)
         (= (walls) (set-index walls true 2 2))
         (= (walls) (set-index walls true 2 3))
         (= (walls) (set-index walls true 2 5))
         (= (walls) (set-index walls true 2 6))
         (= (walls) (set-index walls true 2 7))
         (= (walls) (set-index walls true 2 8))
         (= (walls) (set-index walls true 2 9))
         (= (walls) (set-index walls true 2 10))
         (= (walls) (set-index walls true 3 2))
         (= (walls) (set-index walls true 3 3))
         (= (walls) (set-index walls true 3 5))
         (= (walls) (set-index walls true 3 6))
         (= (walls) (set-index walls true 3 7))
         (= (walls) (set-index walls true 3 8))
         (= (walls) (set-index walls true 3 9))
         (= (walls) (set-index walls true 3 10))
         (= (walls) (set-index walls true 4 2))
         (= (walls) (set-index walls true 4 3))
         (= (walls) (set-index walls true 4 5))
         (= (walls) (set-index walls true 4 6))
         (= (walls) (set-index walls true 4 7))
         (= (xloc key2) 8)
         (= (yloc key2) 4)
         (iscolor key2 red)
         (= (walls) (set-index walls true 4 9))
         (= (walls) (set-index walls true 4 10))
         (= (walls) (set-index walls true 5 2))
         (= (walls) (set-index walls true 5 3))
         (= (walls) (set-index walls true 5 5))
         (= (walls) (set-index walls true 5 6))
         (= (walls) (set-index walls true 5 7))
         (= (xloc door2) 8)
         (= (yloc door2) 5)
         (iscolor door2 blue)
         (locked door2)
         (= (walls) (set-index walls true 5 9))
         (= (walls) (set-index walls true 5 10))
         (= (walls) (set-index walls true 6 2))
         (= (walls) (set-index walls true 6 3))
         (= (walls) (set-index walls true 7 2))
         (= (walls) (set-index walls true 7 3))
         (= (xloc door3) 4)
         (= (yloc door3) 7)
         (iscolor door3 red)
         (locked door3)
         (= (walls) (set-index walls true 7 5))
         (= (walls) (set-index walls true 7 6))
         (= (walls) (set-index walls true 7 8))
         (= (walls) (set-index walls true 7 9))
         (= (walls) (set-index walls true 7 10))
         (= (xloc door4) 11)
         (= (yloc door4) 7)
         (iscolor door4 red)
         (locked door4)
         (= (walls) (set-index walls true 8 2))
         (= (walls) (set-index walls true 8 3))
         (= (xloc door5) 4)
         (= (yloc door5) 8)
         (iscolor door5 blue)
         (locked door5)
         (= (walls) (set-index walls true 8 5))
         (= (walls) (set-index walls true 8 6))
         (= (walls) (set-index walls true 8 8))
         (= (walls) (set-index walls true 8 9))
         (= (walls) (set-index walls true 8 10))
         (= (xloc gem2) 1)
         (= (yloc gem2) 9)
         (= (xloc gem3) 5)
         (= (yloc gem3) 9)
         (= (walls) (set-index walls true 9 6))
         (= (xloc key3) 7)
         (= (yloc key3) 9)
         (iscolor key3 blue)
         (= (walls) (set-index walls true 9 8))
         (= (walls) (set-index walls true 9 9))
         (= (walls) (set-index walls true 9 10))
         (= (xloc gem4) 11)
         (= (yloc gem4) 9)
         (= (xloc human) 4)
         (= (yloc human) 6)
         (= (xloc robot) 8)
         (= (yloc robot) 6)
         (active human)
         (next-turn human robot)
         (next-turn robot human)
         (forbidden robot gem1)
         (forbidden robot gem2)
         (forbidden robot gem3)
         (forbidden robot gem4))
  (:goal (has human gem4))
)