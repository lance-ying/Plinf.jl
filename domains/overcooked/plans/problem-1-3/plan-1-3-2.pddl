(move start-loc food-loc)
(pick-up cucumber1 food-loc)
(move food-loc chop-loc)
(place-in cucumber1 board1 chop-loc)
(move chop-loc food-loc)
(pick-up tomato1 food-loc)
(move food-loc chop-loc)
(place-in tomato1 board1 chop-loc)
(pick-up knife1 chop-loc)
(prepare slice board1 knife1 cucumber1 chop-loc)
(prepare slice board1 knife1 tomato1 chop-loc)
; (prepared slice tomato1) (prepared slice cucumber1)
(put-down knife1 chop-loc)
(pick-up board1 chop-loc)
(move chop-loc plate-loc)
(transfer board1 plate1 plate-loc)
; (in-receptacle tomato1 plate1) (in-receptacle cucumber1 plate1)
