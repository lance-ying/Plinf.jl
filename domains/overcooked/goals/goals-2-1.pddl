; A fresh piece of sashimi made of sliced raw tuna, served on a plate.
        (exists (?tuna - food ?plate - receptacle)
                (and (food-type tuna ?tuna)
                     (receptacle-type plate ?plate)
                     (prepared slice ?tuna)
                     (in-receptacle ?tuna ?plate)))
; A fresh piece of sashimi made of sliced raw salmon, served on a plate.
        (exists (?salmon - food ?plate - receptacle)
                (and (food-type salmon ?salmon)
                     (receptacle-type plate ?plate)
                     (prepared slice ?salmon)
                     (in-receptacle ?salmon ?plate)))
; Grilled tuna, served on a plate.
        (exists (?tuna - food ?plate - receptacle)
                (and (food-type tuna ?tuna)
                     (receptacle-type plate ?plate)
                     (cooked grill ?tuna)
                     (in-receptacle ?tuna ?plate)))
; Grilled salmon, served on a plate.
        (exists (?salmon - food ?plate - receptacle)
                (and (food-type tuna ?salmon)
                     (receptacle-type plate ?plate)
                     (cooked grill ?salmon)
                     (in-receptacle ?salmon ?plate)))
; Two fresh pieces of sashimi made of sliced raw tuna and salmon, served on a plate.
        (exists (?salmon - food ?tuna - food ?plate - receptacle)
                (and (food-type salmon ?salmon)
                     (food-type tuna ?tuna)
                     (receptacle-type plate ?plate)
                     (prepared slice ?salmon)
                     (prepared slice ?tuna)
                     (in-receptacle ?tuna ?plate)
                     (in-receptacle ?salmon ?plate)))