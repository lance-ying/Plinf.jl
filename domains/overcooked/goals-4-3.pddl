; Goal 1: Pepperoni, beef, chicken pizza
        (exists (?egg - food ?flour - food ?tomato - food ?cheese - food ?sausage - food ?beef - food ?chicken - food ?plate - receptacle)
                (and (food-type egg ?egg)
                     (food-type flour ?flour)
                     (food-type tomato ?tomato)
                     (food-type cheese ?cheese)
                     (food-type sausage ?sausage)
                     (food-type beef ?beef)
                     (food-type chicken ?chicken)
                     (receptacle-type plate ?plate)
                     (prepared slice ?sausage)
                     (prepared chop ?beef)
                     (prepared chop ?chicken)
                     (combined-with mix ?egg ?flour)
                     (cooked-with bake ?egg ?flour)
                     (cooked-with bake ?flour ?tomato)
                     (cooked-with bake ?tomato ?cheese)
                     (cooked-with bake ?cheese ?sausage)
                     (cooked-with bake ?sausage ?beef)
                     (cooked-with bake ?beef ?chicken)
                     (in-receptacle ?tomato ?plate)
                     (in-receptacle ?cheese ?plate)
                     (in-receptacle ?beef ?plate)
                     (in-receptacle ?chicken ?plate)
                     (in-receptacle ?sausage ?plate)
                     (in-receptacle ?egg ?plate)
                     (in-receptacle ?flour ?plate)))
; Goal 2: Beef pizza
        (exists (?egg - food ?flour - food ?tomato - food ?cheese - food ?beef - food ?plate - receptacle)
            (and (food-type egg ?egg)
                 (food-type flour ?flour)
                 (food-type tomato ?tomato)
                 (food-type cheese ?cheese)
                 (food-type beef ?beef)
                 (receptacle-type plate ?plate)
                 (prepared slice ?tomato)
                 (combined-with mix ?egg ?flour)
                 (cooked-with bake ?egg ?flour)
                 (cooked-with bake ?tomato ?flour)
                 (cooked-with bake ?tomato ?cheese)
                 (cooked-with bake ?cheese ?beef)
                 (in-receptacle ?tomato ?plate)
                 (in-receptacle ?cheese ?plate)
                 (in-receptacle ?beef ?plate)
                 (in-receptacle ?egg ?plate)
                 (in-receptacle ?flour ?plate)))
; Goal 3: Beef calzone
        (exists (?egg - food ?flour - food  ?cheese - food ?beef - food ?plate - receptacle)
            (and (food-type egg ?egg)
                 (food-type flour ?flour)
                 (food-type cheese ?cheese)
                 (food-type beef ?beef)
                 (receptacle-type plate ?plate)
                 (combined-with mix ?egg ?flour)
                 (cooked-with bake ?egg ?flour)
                 (cooked-with bake ?cheese ?flour)
                 (cooked-with bake ?cheese ?beef)
                 (in-receptacle ?cheese ?plate)
                 (in-receptacle ?beef ?plate)
                 (in-receptacle ?egg ?plate)
                 (in-receptacle ?flour ?plate)))
; Goal 4: Pepperoni and beef pizza
        (exists (?egg - food ?flour - food ?tomato - food ?cheese - food ?beef - food ?sausage - food  ?plate - receptacle)
            (and (food-type egg ?egg)
                 (food-type flour ?flour)
                 (food-type tomato ?tomato)
                 (food-type cheese ?cheese)
                 (food-type beef ?beef)
                 (food-type sausage ?sausage)
                 (receptacle-type plate ?plate)
                 (prepared slice ?tomato)
                 (prepared slice ?sausage)
                 (combined-with mix ?egg ?flour)
                 (cooked-with bake ?egg ?flour)
                 (cooked-with bake ?tomato ?flour)
                 (cooked-with bake ?tomato ?cheese)
                 (cooked-with bake ?cheese ?beef)
                 (cooked-with bake ?beef ?sausage)
                 (in-receptacle ?tomato ?plate)
                 (in-receptacle ?cheese ?plate)
                 (in-receptacle ?beef ?plate)
                 (in-receptacle ?egg ?plate)
                 (in-receptacle ?sausage ?plate)
                 (in-receptacle ?flour ?plate)))
; Goal 5: Cheese pizza
        (exists (?egg - food ?flour - food ?tomato - food ?cheese - food ?plate - receptacle)
            (and (food-type egg ?egg)
                 (food-type flour ?flour)
                 (food-type tomato ?tomato)
                 (food-type cheese ?cheese)
                 (receptacle-type plate ?plate)
                 (prepared slice ?tomato)
                 (combined-with mix ?egg ?flour)
                 (cooked-with bake ?egg ?flour)
                 (cooked-with bake ?tomato ?flour)
                 (cooked-with bake ?tomato ?cheese)
                 (in-receptacle ?tomato ?plate)
                 (in-receptacle ?cheese ?plate)
                 (in-receptacle ?egg ?plate)
                 (in-receptacle ?flour ?plate)))