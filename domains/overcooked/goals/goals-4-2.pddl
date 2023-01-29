; A pepperoni sausage pizza made of mozarella cheese, tomato sauce, sliced pepperoni, and pizza dough, all baked in an oven.
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
; A cheese pizza made of mozarella cheese, tomato, and pizza dough, all baked in an oven.
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
; A chicken pizza made of mozarella cheese, tomato, sliced chicken, and pizza dough, all baked in an oven.
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
; Breadsticks made of dough baked in an oven.
        (exists (?egg - food ?flour - food ?plate - receptacle)
            (and (food-type egg ?egg)
                 (food-type flour ?flour)
                 (receptacle-type plate ?plate)
                 (combined-with mix ?egg ?flour)
                 (cooked-with bake ?egg ?flour)
                 (in-receptacle ?egg ?plate)
                 (in-receptacle ?flour ?plate)))
; Cheesesticks made of cheese and dough baked in an oven.
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