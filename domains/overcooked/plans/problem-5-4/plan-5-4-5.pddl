(move start-loc blend-loc)
(pick-up blender-jug1 blend-loc)
(move blend-loc food-loc)
(put-down blender-jug1 food-loc)
(pick-up strawberry1 food-loc)
(place-in strawberry1 blender-jug1 food-loc)
(pick-up ice1 food-loc)
(place-in ice1 blender-jug1 food-loc)
(pick-up apple1 food-loc)
(place-in apple1 blender-jug1 food-loc)
(pick-up watermelon1 food-loc)
(place-in watermelon1 blender-jug1 food-loc)
(pick-up blender-jug1 food-loc)
(move food-loc blend-loc)
(put-down blender-jug1 blend-loc)
(combine blend blender-jug1 blender1 blend-loc)
; (combined-with blend strawberry1 watermelon1) (combined-with blend watermelon1 apple1) (combined-with blend apple1 ice1)
(pick-up blender-jug1 blend-loc)
(move blend-loc glass-loc)
(transfer blender-jug1 glass1 glass-loc)
; (in-receptacle apple1 glass1) (in-receptacle watermelon1 glass1) (in-receptacle strawberry1 glass1) (in-receptacle ice1 glass1)
