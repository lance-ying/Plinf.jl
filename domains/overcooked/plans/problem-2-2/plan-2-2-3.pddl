(move start-loc food-loc)
(pick-up tuna1 food-loc)
(move food-loc chop-loc)
(place-in tuna1 board1 chop-loc)
(move chop-loc food-loc)
(pick-up salmon1 food-loc)
(move food-loc chop-loc)
(place-in salmon1 board1 chop-loc)
(pick-up knife1 chop-loc)
(prepare slice board1 knife1 salmon1 chop-loc)
(prepare slice board1 knife1 tuna1 chop-loc)
; (prepared slice salmon1) (prepared slice tuna1)
(put-down knife1 chop-loc)
(pick-up board1 chop-loc)
(move chop-loc plate-loc)
(transfer board1 plate1 plate-loc)
; (in-receptacle salmon1 plate1) (in-receptacle tuna1 plate1)
(move plate-loc food-loc)
(put-down board1 food-loc)
(pick-up rice1 food-loc)
(move food-loc stove-loc)
(place-in rice1 pot1 stove-loc)
(pick-up pot1 stove-loc)
(put-down pot1 stove-loc)
(cook boil pot1 stove1 stove-loc)
; (cooked boil rice1)
(pick-up pot1 stove-loc)
(move stove-loc plate-loc)
(transfer pot1 plate1 plate-loc)
; (in-receptacle rice1 plate1)
