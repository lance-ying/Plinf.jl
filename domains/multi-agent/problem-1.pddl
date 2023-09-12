(define (problem doors-keys-gems-problem)
  (:domain doors-keys-gems)
  (:objects door1 door2 door3 door4 - door
            key1 key2 key3 key4 key5 - key
            gem1 gem2 gem3 gem4 gem5 gem6 gem7 gem8 gem9 - gem)
  (:init (= (walls) (new-bit-matrix false 67 11))
         (= (walls) (set-index walls true 2 3))
         (= (xloc door1) 12)
         (= (yloc door1) 2)
         (locked door1)
         (= (xloc key1) 21)
         (= (yloc key1) 2)
         (= (xloc key2) 24)
         (= (yloc key2) 2)
         (= (xloc gem1) 29)
         (= (yloc gem1) 2)
         (= (xloc gem2) 32)
         (= (yloc gem2) 2)
         (= (xloc gem3) 37)
         (= (yloc gem3) 2)
         (= (xloc gem4) 40)
         (= (yloc gem4) 2)
         (= (xloc gem5) 45)
         (= (yloc gem5) 2)
         (= (walls) (set-index walls true 3 3))
         (= (walls) (set-index walls true 3 4))
         (= (xloc gem6) 5)
         (= (yloc gem6) 3)
         (= (walls) (set-index walls true 3 6))
         (= (walls) (set-index walls true 3 7))
         (= (walls) (set-index walls true 3 8))
         (= (xloc gem7) 9)
         (= (yloc gem7) 3)
         (= (walls) (set-index walls true 3 10))
         (= (walls) (set-index walls true 3 11))
         (= (walls) (set-index walls true 4 3))
         (= (walls) (set-index walls true 4 4))
         (= (walls) (set-index walls true 4 6))
         (= (xloc gem8) 7)
         (= (yloc gem8) 4)
         (= (walls) (set-index walls true 4 8))
         (= (walls) (set-index walls true 4 10))
         (= (walls) (set-index walls true 4 11))
         (= (walls) (set-index walls true 5 3))
         (= (walls) (set-index walls true 5 4))
         (= (xloc door2) 5)
         (= (yloc door2) 5)
         (locked door2)
         (= (walls) (set-index walls true 5 6))
         (= (walls) (set-index walls true 5 8))
         (= (xloc door3) 9)
         (= (yloc door3) 5)
         (locked door3)
         (= (walls) (set-index walls true 5 10))
         (= (walls) (set-index walls true 5 11))
         (= (xloc key3) 3)
         (= (yloc key3) 6)
         (= (walls) (set-index walls true 6 10))
         (= (walls) (set-index walls true 6 11))
         (= (walls) (set-index walls true 7 3))
         (= (walls) (set-index walls true 7 4))
         (= (xloc door4) 5)
         (= (yloc door4) 7)
         (locked door4)
         (= (walls) (set-index walls true 7 6))
         (= (walls) (set-index walls true 7 7))
         (= (walls) (set-index walls true 7 8))
         (= (walls) (set-index walls true 7 9))
         (= (walls) (set-index walls true 7 10))
         (= (walls) (set-index walls true 7 11))
         (= (walls) (set-index walls true 8 3))
         (= (walls) (set-index walls true 8 4))
         (= (walls) (set-index walls true 8 6))
         (= (walls) (set-index walls true 8 7))
         (= (walls) (set-index walls true 8 8))
         (= (walls) (set-index walls true 8 9))
         (= (xloc key4) 10)
         (= (yloc key4) 8)
         (= (walls) (set-index walls true 8 11))
         (= (walls) (set-index walls true 10 3))
         (= (walls) (set-index walls true 10 4))
         (= (walls) (set-index walls true 10 5))
         (= (walls) (set-index walls true 10 6))
         (= (walls) (set-index walls true 10 8))
         (= (walls) (set-index walls true 10 9))
         (= (walls) (set-index walls true 10 10))
         (= (walls) (set-index walls true 10 11))
         (= (walls) (set-index walls true 11 3))
         (= (walls) (set-index walls true 11 4))
         (= (xloc key5) 5)
         (= (yloc key5) 11)
         (= (xloc gem9) 10)
         (= (yloc gem9) 11)
         (= (walls) (set-index walls true 11 11))
         (= (xpos) 3)
         (= (ypos) 9))
  (:goal (has gem9))
)