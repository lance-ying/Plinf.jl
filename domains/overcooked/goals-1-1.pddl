; Sliced lettuce
        (exists (?lettuce - food ?plate - receptacle)
                (and (food-type lettuce ?lettuce)
                     (receptacle-type plate ?plate)
                     (prepared slice ?lettuce)
                     (in-receptacle ?lettuce ?plate)))
; Sliced cucumber
        (exists (?cucumber - food ?plate - receptacle)
                (and (food-type cucumber ?cucumber)
                     (receptacle-type plate ?plate)
                     (prepared slice ?cucumber)
                     (in-receptacle ?cucumber ?plate)))
; Raw lettuce
        (exists (?lettuce - food ?plate - receptacle)
                (and (food-type lettuce ?lettuce)
                     (receptacle-type plate ?plate)
                     (in-receptacle ?lettuce ?plate)))
; Sliced lettuce and sliced cucumber
        (exists (?lettuce - food ?cucumber - food ?plate - receptacle)
                (and (food-type lettuce ?lettuce)
                     (food-type cucumber ?cucumber)
                     (receptacle-type plate ?plate)
                     (prepared slice ?lettuce)
                     (prepared slice ?cucumber)
                     (in-receptacle ?cucumber ?plate)
                     (in-receptacle ?lettuce ?plate)))
; Raw lettuce and sliced cucumber
        (exists (?lettuce - food ?cucumber - food ?plate - receptacle)
                (and (food-type lettuce ?lettuce)
                     (food-type cucumber ?cucumber)
                     (receptacle-type plate ?plate)
                     (prepared slice ?cucumber)
                     (in-receptacle ?cucumber ?plate)
                     (in-receptacle ?lettuce ?plate)))