;; ASCII ;;
; W: wall, D: door, k: key, g: gem, G: goal-gem, s: start, .: empty
; WW.W.W.WW
; WW.WGW.WW
; WW.WDW.WW
; WW.....WW
; sWgWWW.D.
; .WWWkWWW.
; .........
; WWWW.WWWW
; WWWk.gWWW
(define (problem doors-keys-gems-6)
  (:domain doors-keys-gems)
  (:objects door1 door2 - door red yellow - color key1 key2 - key gem1 gem2 gem3 - gem human robot - agent)
  (:init (locked door1)
         (locked door2)
         (= (walls)
            (transpose (bit-mat
               (bit-vec 1 1 0 1 0 1 0 1 1)
               (bit-vec 1 1 0 1 0 1 0 1 1)
               (bit-vec 1 1 0 1 0 1 0 1 1)
               (bit-vec 1 1 0 0 0 0 0 1 1)
               (bit-vec 0 1 0 1 1 1 0 0 0)
               (bit-vec 0 1 1 1 0 1 1 1 0)
               (bit-vec 0 0 0 0 0 0 0 0 0)
               (bit-vec 1 1 1 1 0 1 1 1 1)
               (bit-vec 1 1 1 0 0 0 1 1 1))))
         (iscolor door1 red) 
         (iscolor key1 red) 
         (iscolor door2 yellow) 
         (iscolor key2 yellow) 
         (= (xloc key1) 4)
         (= (xloc gem3) 5)
         (= (xloc key2) 5)
         (= (xloc door1) 5)
         (= (xloc gem2) 3)
         (= (xloc door2) 8)
         (= (xloc gem1) 6)
         (= (yloc key1) 9)
         (= (yloc gem3) 2)
         (= (yloc key2) 6)
         (= (yloc door1) 3)
         (= (yloc gem2) 5)
         (= (yloc door2) 5)
         (= (yloc gem1) 9)
         (= (xloc human) 1)
         (= (yloc human) 5)
         (= (xloc robot) 5)
         (= (yloc robot) 9))
  (:goal (has human gem3))
)
