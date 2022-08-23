; Salad bar with tomato and lettuce salad as goal
(define (problem overcooked-problem-1-2)
	(:domain overcooked)
	(:objects
		tomato lettuce cucumber - ftype ; Food types
		chopping-board plate - rtype ; Receptacle types
		knife - ttype ; Tool types
		slice - prepare-method ; Preparation methods
		tomato1 lettuce1 cucumber1 - food ; Food objects
		board1 plate1 - receptacle ; Receptacle objects
		knife1 - tool ; Tool objects
		start-loc food-loc chop-loc plate-loc - location ; Locations
	)
	(:init
		; Type declarations
		(food-type tomato tomato1)
		(food-type lettuce lettuce1)
		(food-type cucumber cucumber1)
		(receptacle-type chopping-board board1)
		(receptacle-type plate plate1)
		(tool-type knife knife1)
		; Method declarations
		(has-prepare-method slice chopping-board knife)
		; Initial agent state
		(handempty)
		(agent-at-loc start-loc)
		; Initial food locations
		(object-at-loc tomato1 food-loc)
		(object-at-loc lettuce1 food-loc)
		(object-at-loc cucumber1 food-loc)
		; Initial receptacle and tool locations
		(object-at-loc board1 chop-loc)
		(object-at-loc knife1 chop-loc)
		(object-at-loc plate1 plate-loc)
	)
	(:goal
		(exists (?lettuce - food ?tomato - food ?plate - receptacle)
		        (and (food-type lettuce ?lettuce)
								 (food-type tomato ?tomato)
								 (receptacle-type plate ?plate)
		             (prepared slice ?lettuce)
								 (prepared slice ?tomato)
		             (in-receptacle ?lettuce ?plate)
								 (in-receptacle ?tomato ?plate)))
	)
)