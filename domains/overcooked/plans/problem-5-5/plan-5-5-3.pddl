(move start-loc food-loc)
(pick-up egg1 food-loc)
(move food-loc mix-loc)
(place-in egg1 mixing-bowl1 mix-loc)
(move mix-loc food-loc)
(pick-up flour1 food-loc)
(move food-loc mix-loc)
(place-in flour1 mixing-bowl1 mix-loc)
(combine mix mixing-bowl1 mixer1 mix-loc)
; (combined-with mix egg1 flour1)
(pick-up mixing-bowl1 mix-loc)
(move mix-loc fryer-loc)
(transfer mixing-bowl1 basket1 fryer-loc)
(move fryer-loc food-loc)
(put-down mixing-bowl1 food-loc)
(pick-up grape1 food-loc)
(move food-loc fryer-loc)
(place-in grape1 basket1 fryer-loc)
(cook deep-fry basket1 fryer1 fryer-loc)
; (cooked-with deep-fry egg1 flour1) (cooked-with deep-fry flour1 grape1)
(pick-up basket1 fryer-loc)
(move fryer-loc plate-loc)
(transfer basket1 plate1 plate-loc)
; (in-receptacle egg1 plate1) (in-receptacle grape1 plate1) (in-receptacle flour1 plate1)
