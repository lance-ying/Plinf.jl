; Goal 1: Pepperoni pizza
        (exists (?egg - food ?flour - food ?tomato - food ?cheese - food ?sausage - food ?plate - receptacle)
            (and (food-type egg ?egg)
                 (food-type flour ?flour)
                 (food-type tomato ?tomato)
                 (food-type cheese ?cheese)
                 (food-type sausage ?sausage)
                 (receptacle-type plate ?plate)
                 (prepared slice ?tomato)
                 (prepared slice ?sausage)
                 (combined-with mix ?egg ?flour)
                 (cooked-with bake ?egg ?flour)
                 (cooked-with bake ?flour ?tomato)
                 (cooked-with bake ?tomato ?cheese)
                 (cooked-with bake ?cheese ?sausage)
                 (in-receptacle ?tomato ?plate)
                 (in-receptacle ?cheese ?plate)
                 (in-receptacle ?sausage ?plate)
                 (in-receptacle ?egg ?plate)
                 (in-receptacle ?flour ?plate)))
; Goal 2: Cheese pizza
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
; Goal 3: Chicken pizza
        (exists (?egg - food ?flour - food ?tomato - food ?cheese - food ?chicken - food ?plate - receptacle)
            (and (food-type egg ?egg)
                 (food-type flour ?flour)
                 (food-type tomato ?tomato)
                 (food-type cheese ?cheese)
                 (food-type chicken ?chicken)
                 (receptacle-type plate ?plate)
                 (prepared slice ?tomato)
                 (prepared slice ?chicken)
                 (combined-with mix ?egg ?flour)
                 (cooked-with bake ?egg ?flour)
                 (cooked-with bake ?flour ?tomato)
                 (cooked-with bake ?tomato ?cheese)
                 (cooked-with bake ?cheese ?chicken)
                 (in-receptacle ?tomato ?plate)
                 (in-receptacle ?cheese ?plate)
                 (in-receptacle ?chicken ?plate)
                 (in-receptacle ?egg ?plate)
                 (in-receptacle ?flour ?plate)))
; Goal 4: Breadsticks
        (exists (?egg - food ?flour - food ?plate - receptacle)
            (and (food-type egg ?egg)
                 (food-type flour ?flour)
                 (receptacle-type plate ?plate)
                 (combined-with mix ?egg ?flour)
                 (cooked-with bake ?egg ?flour)
                 (in-receptacle ?egg ?plate)
                 (in-receptacle ?flour ?plate)))
; Goal 5 Cheese calzone
        (exists (?egg - food ?flour - food ?cheese - food ?plate - receptacle)
                (and (food-type egg ?egg)
                     (food-type flour ?flour)
                     (food-type cheese ?cheese)
                     (receptacle-type plate ?plate)
                     (combined-with mix ?egg ?flour)
                     (cooked-with bake ?egg ?flour)
                     (cooked-with bake ?flour ?cheese)
                     (in-receptacle ?cheese ?plate)
                     (in-receptacle ?egg ?plate)
                     (in-receptacle ?flour ?plate)))