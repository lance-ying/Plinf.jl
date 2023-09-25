(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 door5 door6 door7 - door
            key1 key2 key3 key4 - key
            gem1 gem2 gem3 gem4 - gem
            yellow red blue - color
            robot - robot
            human - human)
  (:init (= (walls) (new-bit-matrix false 10 11))
         (= (xloc key1) 1)
         (= (yloc key1) 1)
         (iscolor key1 red)
         (= (xloc key2) 11)
         (= (yloc key2) 1)
         (iscolor key2 blue)
         (= (walls) (set-index walls true 2 1))
         (= (walls) (set-index walls true 2 2))
         (= (walls) (set-index walls true 2 3))
         (= (walls) (set-index walls true 2 4))
         (= (walls) (set-index walls true 2 5))
         (= (walls) (set-index walls true 2 7))
         (= (walls) (set-index walls true 2 8))
         (= (walls) (set-index walls true 2 9))
         (= (walls) (set-index walls true 2 10))
         (= (walls) (set-index walls true 2 11))
         (= (walls) (set-index walls true 3 1))
         (= (walls) (set-index walls true 3 2))
         (= (walls) (set-index walls true 3 3))
         (= (walls) (set-index walls true 3 4))
         (= (walls) (set-index walls true 3 5))
         (= (walls) (set-index walls true 3 7))
         (= (walls) (set-index walls true 3 8))
         (= (walls) (set-index walls true 3 9))
         (= (walls) (set-index walls true 3 10))
         (= (walls) (set-index walls true 3 11))
         (= (walls) (set-index walls true 4 1))
         (= (walls) (set-index walls true 4 2))
         (= (walls) (set-index walls true 4 10))
         (= (walls) (set-index walls true 4 11))
         (= (walls) (set-index walls true 5 4))
         (= (walls) (set-index walls true 5 5))
         (= (xloc door1) 6)
         (= (yloc door1) 5)
         (iscolor door1 yellow)
         (locked door1)
         (= (walls) (set-index walls true 5 7))
         (= (walls) (set-index walls true 5 8))
         (= (walls) (set-index walls true 6 2))
         (= (xloc door2) 3)
         (= (yloc door2) 6)
         (iscolor door2 yellow)
         (locked door2)
         (= (walls) (set-index walls true 6 4))
         (= (walls) (set-index walls true 6 5))
         (= (walls) (set-index walls true 6 7))
         (= (walls) (set-index walls true 6 8))
         (= (xloc door3) 9)
         (= (yloc door3) 6)
         (iscolor door3 yellow)
         (locked door3)
         (= (walls) (set-index walls true 6 10))
         (= (walls) (set-index walls true 7 2))
         (= (xloc door4) 3)
         (= (yloc door4) 7)
         (iscolor door4 red)
         (locked door4)
         (= (walls) (set-index walls true 7 4))
         (= (xloc door5) 5)
         (= (yloc door5) 7)
         (iscolor door5 blue)
         (locked door5)
         (= (xloc door6) 7)
         (= (yloc door6) 7)
         (iscolor door6 blue)
         (locked door6)
         (= (walls) (set-index walls true 7 8))
         (= (xloc door7) 9)
         (= (yloc door7) 7)
         (iscolor door7 blue)
         (locked door7)
         (= (walls) (set-index walls true 7 10))
         (= (walls) (set-index walls true 8 2))
         (= (xloc gem1) 3)
         (= (yloc gem1) 8)
         (= (walls) (set-index walls true 8 4))
         (= (xloc gem2) 5)
         (= (yloc gem2) 8)
         (= (walls) (set-index walls true 8 6))
         (= (xloc gem3) 7)
         (= (yloc gem3) 8)
         (= (walls) (set-index walls true 8 8))
         (= (xloc gem4) 9)
         (= (yloc gem4) 8)
         (= (walls) (set-index walls true 8 10))
         (= (walls) (set-index walls true 9 2))
         (= (walls) (set-index walls true 9 3))
         (= (walls) (set-index walls true 9 4))
         (= (walls) (set-index walls true 9 5))
         (= (walls) (set-index walls true 9 6))
         (= (walls) (set-index walls true 9 7))
         (= (walls) (set-index walls true 9 8))
         (= (walls) (set-index walls true 9 9))
         (= (walls) (set-index walls true 9 10))
         (= (xloc key3) 1)
         (= (yloc key3) 10)
         (iscolor key3 yellow)
         (= (xloc key4) 11)
         (= (yloc key4) 10)
         (iscolor key4 yellow)
         (= (xloc human) 6)
         (= (yloc human) 4)
         (= (xloc robot) 6)
         (= (yloc robot) 10)
         (active human)
         (next-turn human robot)
         (next-turn robot human)
         (forbidden robot gem1)
         (forbidden robot gem2)
         (forbidden robot gem3)
         (forbidden robot gem4))
  (:goal (has human gem4))
)