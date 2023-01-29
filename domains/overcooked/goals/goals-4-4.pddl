; An oven-baked veggie pizza made of mushroom, onion, olives, mozarella cheese, tomato sauce and pizza dough, served on a plate.
        (exists (?egg - food ?flour - food ?tomato - food ?cheese - food ?onion - food ?mushroom - food ?olive - food ?plate - receptacle)
                (and (food-type egg ?egg)
                     (food-type flour ?flour)
                     (food-type cheese ?cheese)
                     (food-type onion ?onion)
                     (food-type mushroom ?mushroom)
                     (food-type olive ?olive)
                     (food-type tomato ?tomato)
                     (receptacle-type plate ?plate)
                     (prepared slice ?onion)
                     (prepared slice ?mushroom)
                     (prepared slice ?olive)
                     (prepared slice ?tomato)
                     (combined-with mix ?egg ?flour)
                     (cooked-with bake ?egg ?flour)
                     (cooked-with bake ?flour ?cheese)
                     (cooked-with bake ?cheese ?olive)
                     (cooked-with bake ?olive ?mushroom)
                     (cooked-with bake ?mushroom ?onion)
                     (cooked-with bake ?onion ?tomato)
                     (in-receptacle ?cheese ?plate)
                     (in-receptacle ?tomato ?plate)
                     (in-receptacle ?mushroom ?plate)
                     (in-receptacle ?olive ?plate)
                     (in-receptacle ?onion ?plate)
                     (in-receptacle ?egg ?plate)
                     (in-receptacle ?flour ?plate)))
; An oven-baked mushroom pizza made of mushroom, mozarella cheese, tomato sauce and pizza dough, served on a plate.
        (exists (?egg - food ?flour - food ?tomato - food ?cheese - food ?mushroom - food ?plate - receptacle)
            (and (food-type egg ?egg)
                 (food-type flour ?flour)
                 (food-type tomato ?tomato)
                 (food-type cheese ?cheese)
                 (food-type mushroom ?mushroom)
                 (receptacle-type plate ?plate)
                 (prepared slice ?mushroom)
                 (prepared slice ?tomato)
                 (combined-with mix ?egg ?flour)
                 (cooked-with bake ?egg ?flour)
                 (cooked-with bake ?tomato ?flour)
                 (cooked-with bake ?tomato ?cheese)
                 (cooked-with bake ?cheese ?mushroom)
                 (in-receptacle ?tomato ?plate)
                 (in-receptacle ?cheese ?plate)
                 (in-receptacle ?mushroom ?plate)
                 (in-receptacle ?egg ?plate)
                 (in-receptacle ?flour ?plate)))
; An oven-baked veggie pizza made of onion, mozarella cheese, tomato sauce and pizza dough, served on a plate.
        (exists (?egg - food ?flour - food ?tomato - food ?cheese - food ?onion - food ?plate - receptacle)
            (and (food-type egg ?egg)
                 (food-type flour ?flour)
                 (food-type tomato ?tomato)
                 (food-type cheese ?cheese)
                 (food-type onion ?onion)
                 (receptacle-type plate ?plate)
                 (prepared slice ?onion)
                 (prepared slice ?tomato)
                 (combined-with mix ?egg ?flour)
                 (cooked-with bake ?egg ?flour)
                 (cooked-with bake ?flour ?tomato)
                 (cooked-with bake ?tomato ?cheese)
                 (cooked-with bake ?cheese ?onion)
                 (in-receptacle ?tomato ?plate)
                 (in-receptacle ?cheese ?plate)
                 (in-receptacle ?onion ?plate)
                 (in-receptacle ?egg ?plate)
                 (in-receptacle ?flour ?plate)))
; An oven-baked olive pizza made of olives, mozarella cheese, tomato sauce and pizza dough, served on a plate.
        (exists (?egg - food ?flour - food ?tomato - food ?cheese - food ?olive - food ?plate - receptacle)
            (and (food-type egg ?egg)
                 (food-type flour ?flour)
                 (food-type tomato ?tomato)
                 (food-type cheese ?cheese)
                 (food-type olive ?olive)
                 (receptacle-type plate ?plate)
                 (prepared slice ?olive)
                 (prepared slice ?tomato)
                 (combined-with mix ?egg ?flour)
                 (cooked-with bake ?egg ?flour)
                 (cooked-with bake ?flour ?tomato)
                 (cooked-with bake ?tomato ?cheese)
                 (cooked-with bake ?cheese ?olive)
                 (in-receptacle ?tomato ?plate)
                 (in-receptacle ?cheese ?plate)
                 (in-receptacle ?olive ?plate)
                 (in-receptacle ?egg ?plate)
                 (in-receptacle ?flour ?plate)))
; An oven-baked veggie calzone made of mushroom, onion, olives, mozarella cheese and pizza dough, served on a plate.
        (exists (?egg - food ?flour - food ?cheese - food ?onion - food ?mushroom - food ?olive - food ?plate - receptacle)
                (and (food-type egg ?egg)
                     (food-type flour ?flour)
                     (food-type cheese ?cheese)
                     (food-type onion ?onion)
                     (food-type mushroom ?mushroom)
                     (food-type olive ?olive)
                     (receptacle-type plate ?plate)
                     (prepared slice ?onion)
                     (prepared slice ?mushroom)
                     (prepared slice ?olive)
                     (combined-with mix ?egg ?flour)
                     (cooked-with bake ?egg ?flour)
                     (cooked-with bake ?flour ?cheese)
                     (cooked-with bake ?cheese ?olive)
                     (cooked-with bake ?olive ?mushroom)
                     (cooked-with bake ?mushroom ?onion)
                     (in-receptacle ?cheese ?plate)
                     (in-receptacle ?mushroom ?plate)
                     (in-receptacle ?olive ?plate)
                     (in-receptacle ?onion ?plate)
                     (in-receptacle ?egg ?plate)
                     (in-receptacle ?flour ?plate)))