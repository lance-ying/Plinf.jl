; Pizzeria with pepperoni pizza as a goal
(define (problem overcooked-problem-4)
	(:domain overcooked)
	(:objects
		dough tomato cheese sausage chicken beef - ftype ; Food types
		chopping-board tray plate - rtype ; Receptacle types
		knife - ttype ; Tool types
		oven - atype ; Appliance types
		slice chop - prepare-method ; Preparation methods
		bake - cook-method ; Cooking methods
		dough1 tomato1 cheese1 sausage1 chicken1 beef1 - food ; Food objects
		board1 tray1 plate1 - receptacle ; Receptacle objects
		knife1 - tool ; Tool objects
		oven1 - appliance ; Appliance objects
		start-loc food-loc chop-loc oven-loc tray-loc plate-loc - location ; Locations
	)
	(:init
		; Type declarations
		(food-type dough dough1)
		(food-type tomato tomato1)
		(food-type cheese cheese1)
		(food-type chicken chicken1)
		(food-type sausage sausage1)
		(food-type beef beef1)
		(receptacle-type chopping-board board1)
		(receptacle-type plate plate1)
		(receptacle-type tray tray1)
		(tool-type knife knife1)
		(appliance-type oven oven1)
		; Method declarations
		(has-prepare-method slice chopping-board knife)
		(has-prepare-method chop chopping-board knife)
		(has-cook-method bake tray oven)
		; Initial agent state
		(handempty)
		(agent-at-loc start-loc)
		; Initial food locations
		(object-at-loc dough1 food-loc)
		(object-at-loc tomato1 food-loc)
		(object-at-loc cheese1 food-loc)
		(object-at-loc sausage1 food-loc)
		(object-at-loc chicken1 food-loc)
		(object-at-loc beef1 food-loc)
		; Receptacle, tool, and appliance locations
		(object-at-loc board1 chop-loc)
		(object-at-loc knife1 chop-loc)
		(object-at-loc oven1 oven-loc)
		(object-at-loc plate1 plate-loc)
		(object-at-loc tray1 tray-loc)
	
	)
	(:goal
	(exists (?dough - food ?tomato - food ?cheese - food ?sausage - food ?beef - food ?chicken - food ?plate - receptacle)
        (and (food-type dough ?dough)
             (food-type tomato ?tomato)
             (food-type cheese ?cheese)
             (food-type sausage ?sausage)
			 (food-type beef ?beef)
             (food-type chicken ?chicken)
			 (receptacle-type plate ?plate)
			 (prepared slice ?sausage)
			 (prepared chop ?beef)
			 (prepared chop ?chicken)
             (cooked-with bake ?tomato ?dough)
             (cooked-with bake ?dough ?cheese)
             (cooked-with bake ?cheese ?sausage)
			 (cooked-with bake ?sausage ?beef)
             (cooked-with bake ?beef ?chicken)
             (in-receptacle ?tomato ?plate)
             (in-receptacle ?cheese ?plate)
			 (in-receptacle ?beef ?plate)
             (in-receptacle ?chicken ?plate)
             (in-receptacle ?sausage ?plate)
             (in-receptacle ?dough ?plate)))
	)
)
