(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 - door
            key1 key2 key3 key4 - key
            gem1 gem2 gem3 gem4 - gem
            red blue - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 9 10))
         (= (walls) (set-index walls true 1 1))
         (= (walls) (set-index walls true 1 2))
         (= (xloc gem1) 3)
         (= (yloc gem1) 1)
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
         (= (walls) (set-index walls true 2 4))
         (= (walls) (set-index walls true 2 5))
         (= (walls) (set-index walls true 2 7))
         (= (walls) (set-index walls true 2 8))
         (= (walls) (set-index walls true 2 9))
         (= (walls) (set-index walls true 2 10))
         (= (xloc key2) 1)
         (= (yloc key2) 3)
         (iscolor key2 red)
         (= (xloc key3) 10)
         (= (yloc key3) 3)
         (iscolor key3 blue)
         (= (walls) (set-index walls true 4 2))
         (= (walls) (set-index walls true 4 3))
         (= (walls) (set-index walls true 4 4))
         (= (walls) (set-index walls true 4 5))
         (= (walls) (set-index walls true 4 6))
         (= (walls) (set-index walls true 4 7))
         (= (walls) (set-index walls true 4 8))
         (= (xloc key4) 9)
         (= (yloc key4) 4)
         (iscolor key4 red)
         (= (walls) (set-index walls true 4 10))
         (= (walls) (set-index walls true 5 2))
         (= (walls) (set-index walls true 5 3))
         (= (walls) (set-index walls true 5 4))
         (= (walls) (set-index walls true 5 5))
         (= (walls) (set-index walls true 5 6))
         (= (walls) (set-index walls true 5 7))
         (= (walls) (set-index walls true 5 8))
         (= (walls) (set-index walls true 5 10))
         (= (xloc door1) 1)
         (= (yloc door1) 7)
         (iscolor door1 red)
         (locked door1)
         (= (walls) (set-index walls true 7 2))
         (= (walls) (set-index walls true 7 3))
         (= (xloc door2) 4)
         (= (yloc door2) 7)
         (iscolor door2 blue)
         (locked door2)
         (= (walls) (set-index walls true 7 5))
         (= (walls) (set-index walls true 7 6))
         (= (walls) (set-index walls true 7 8))
         (= (walls) (set-index walls true 7 9))
         (= (xloc door3) 10)
         (= (yloc door3) 7)
         (iscolor door3 red)
         (locked door3)
         (= (walls) (set-index walls true 8 2))
         (= (walls) (set-index walls true 8 3))
         (= (walls) (set-index walls true 8 5))
         (= (walls) (set-index walls true 8 6))
         (= (walls) (set-index walls true 8 8))
         (= (walls) (set-index walls true 8 9))
         (= (xloc gem2) 1)
         (= (yloc gem2) 9)
         (= (walls) (set-index walls true 9 2))
         (= (walls) (set-index walls true 9 3))
         (= (xloc gem3) 4)
         (= (yloc gem3) 9)
         (= (walls) (set-index walls true 9 5))
         (= (walls) (set-index walls true 9 6))
         (= (walls) (set-index walls true 9 8))
         (= (walls) (set-index walls true 9 9))
         (= (xloc gem4) 10)
         (= (yloc gem4) 9)
         (= (xloc human) 7)
         (= (yloc human) 9)
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