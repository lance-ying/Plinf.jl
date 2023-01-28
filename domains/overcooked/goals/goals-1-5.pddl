; A fresh Cobb salad with chopped lettuce, boiled egg, sliced tomato, sliced cheese, crumbled bacon, sliced avocado, and salad dressing.
        (exists (?lettuce - food ?tomato - food ?cheese - food ?bacon - food ?avocado - food ?egg - food ?salad-dressing - food ?plate - receptacle)
                (and (food-type lettuce ?lettuce)
                     (food-type tomato ?tomato) 
                     (food-type cheese ?cheese)
                     (food-type bacon ?bacon)
                     (food-type egg ?egg)
                     (food-type avocado ?avocado)
                     (food-type salad-dressing ?salad-dressing)
                     (receptacle-type plate ?plate)
                     (prepared chop ?lettuce)
                     (prepared slice ?tomato)
                     (prepared slice ?cheese)
                     (prepared crumble ?bacon)
                     (prepared slice ?avocado)
                     (cooked boil ?egg)
                     (cooked grill ?bacon)
                     (in-receptacle ?salad-dressing ?plate)
                     (in-receptacle ?lettuce ?plate)
                     (in-receptacle ?tomato ?plate)
                     (in-receptacle ?cheese ?plate)
                     (in-receptacle ?egg ?plate)
                     (in-receptacle ?avocado ?plate)
                     (in-receptacle ?bacon ?plate)))
; A sliced avocado.
        (exists (?avocado - food ?plate - receptacle)
                (and (food-type avocado ?avocado)
                     (receptacle-type plate ?plate)
                     (prepared slice ?avocado)
                     (in-receptacle ?avocado ?plate)))
; A salad with sliced lettuce, sliced tomato, sliced cucumber, sliced onion, and salad dressing.
        (exists (?lettuce - food ?tomato - food ?cucumber - food ?onion - food ?salad-dressing - food ?plate - receptacle)
                (and (food-type lettuce ?lettuce)
                     (food-type tomato ?tomato)
                     (food-type cucumber ?cucumber)
                     (food-type onion ?onion)
                     (food-type salad-dressing ?salad-dressing)
                     (receptacle-type plate ?plate)
                     (prepared slice ?lettuce)
                     (prepared slice ?tomato)
                     (prepared slice ?cucumber)
                     (prepared slice ?onion)
                     (in-receptacle ?lettuce ?plate)
                     (in-receptacle ?cucumber ?plate)
                     (in-receptacle ?onion ?plate)
                     (in-receptacle ?tomato ?plate)
                     (in-receptacle ?salad-dressing ?plate)))
; Greek salad made of chopped tomato, olives, onion, cucumber, and crumbled feta cheese.
        (exists (?onion - food ?tomato - food ?cucumber - food ?olive - food ?feta-cheese - food ?salad-dressing - food ?knife - tool ?glove - tool ?plate - receptacle)
                (and (food-type olive ?olive)
                     (food-type tomato ?tomato)
                     (food-type cucumber ?cucumber)
                     (food-type onion ?onion)
                     (food-type feta-cheese ?feta-cheese)
                     (food-type salad-dressing ?salad-dressing)
                     (receptacle-type plate ?plate)
                     (prepared chop ?olive)
                     (prepared chop ?tomato)
                     (prepared chop ?cucumber)
                     (prepared chop ?onion)
                     (prepared crumble ?feta-cheese)
                     (in-receptacle ?salad-dressing ?plate)
                     (in-receptacle ?olive ?plate)
                     (in-receptacle ?feta-cheese ?plate)
                     (in-receptacle ?cucumber ?plate)
                     (in-receptacle ?onion ?plate)
                     (in-receptacle ?tomato ?plate)))
; A fresh Cobb salad with grilled chicken, chopped lettuce, boiled egg, sliced tomato, sliced cheese, crumbled bacon, sliced avocado, and salad dressing.
        (exists (?chicken - food ?lettuce - food ?tomato - food ?cheese - food ?bacon - food ?avocado - food ?egg - food ?salad-dressing - food ?plate - receptacle)
                (and (food-type lettuce ?lettuce)
                     (food-type tomato ?tomato) 
                     (food-type cheese ?cheese)
                     (food-type bacon ?bacon)
                     (food-type egg ?egg)
                     (food-type avocado ?avocado)
                     (food-type salad-dressing ?salad-dressing)
                     (food-type chicken ?chicken)
                     (receptacle-type plate ?plate)
                     (cooked boil ?egg)
                     (cooked grill ?chicken)
                     (prepared chop ?lettuce)
                     (prepared slice ?tomato)
                     (prepared slice ?cheese)
                     (prepared crumble ?bacon)
                     (prepared slice ?avocado)
                     (in-receptacle ?salad-dressing ?plate)
                     (in-receptacle ?chicken ?plate)
                     (in-receptacle ?lettuce ?plate)
                     (in-receptacle ?tomato ?plate)
                     (in-receptacle ?cheese ?plate)
                     (in-receptacle ?egg ?plate)
                     (in-receptacle ?avocado ?plate)
                     (in-receptacle ?bacon ?plate)))