(move start-loc food-loc)
(pick-up crab1 food-loc)
(move food-loc chop-loc)
(place-in crab1 board1 chop-loc)
(pick-up s-knife1 chop-loc)
(prepare slice board1 s-knife1 crab1 chop-loc)
; (prepared slice crab1)
(put-down s-knife1 chop-loc)
(pick-up board1 chop-loc)
(move chop-loc plate-loc)
(transfer board1 plate1 plate-loc)
; (in-receptacle crab1 plate1)
(move plate-loc food-loc)
(put-down board1 food-loc)
(pick-up rice1 food-loc)
(move food-loc stove-loc)
(place-in rice1 pot1 stove-loc)
(cook boil pot1 stove1 stove-loc)
; (cooked boil rice1)
(pick-up pot1 stove-loc)
(move stove-loc plate-loc)
(transfer pot1 plate1 plate-loc)
; (in-receptacle rice1 plate1)
(move plate-loc food-loc)
(put-down pot1 food-loc)
(pick-up nori1 food-loc)
(move food-loc plate-loc)
(place-in nori1 plate1 plate-loc)
; (in-receptacle nori1 plate1)
