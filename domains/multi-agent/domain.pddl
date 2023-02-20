(define (domain doors-keys-gems)
    (:requirements :fluents :adl :typing)
    (:types key gem - item door - object)
    (:predicates (has ?a ?i - item) (offgrid ?i - item) (locked ?d - door))
    (:functions (xpos ?a - agent) (ypos ?a - agent) - integer
                (xloc ?o - object) (yloc ?o - object) - integer
                (walls) - bit-matrix)
    (:action pickup
     :parameters (?a - agent ?i - item)
     :precondition (and (not (has ?a ?i)) (= (xpos ?a) (xloc ?i)) (= (ypos ?a) (yloc ?i)))
     :effect (and (?a has ?i) (offgrid ?i)
                  (assign (xloc ?i) -1) (assign (yloc ?i) -1))
    )
    (:action unlock
     :parameters (?a - agent ?k - key ?d - door)
     :precondition (and (has ?a ?k) (locked ?d)
                        (or (and (= (xpos ?a) (xloc ?d)) (= (- (ypos ?a) 1) (yloc ?d)))
                            (and (= (xpos ?a) (xloc ?d)) (= (+ (ypos ?a) 1) (yloc ?d)))
                            (and (= (- (xpos ?a) 1) (xloc ?d)) (= (ypos ?a) (yloc ?d)))
                            (and (= (+ (xpos ?a) 1) (xloc ?d)) (= (ypos ?a) (yloc ?d)))))
     :effect (and (not (has ?a ?k)) (not (locked ?d)))
    )
    (:action up
     :parameters (?a - agent)
     :precondition
        (and (> (ypos ?a) 1)
            (= (get-index walls (- (ypos ?a) 1) (xpos ?a)) false)
            (not (exists (?d - door)
                (and (locked ?d) (= (xpos ?a) (xloc ?d)) (= (- (ypos ?a) 1) (yloc ?d))))))
     :effect (decrease (ypos ?a) 1)
    )
    (:action down
     :parameters (?a - agent)
     :precondition
        (and (< (ypos ?a) (height walls))
            (= (get-index walls (+ (ypos ?a) 1) (xpos ?a)) false)
            (not (exists (?d - door)
                (and (locked ?d) (= (xpos ?a) (xloc ?d)) (= (+ (ypos ?a) 1) (yloc ?d))))))
     :effect (increase (ypos ?a) 1)
    )
    (:action left
     :parameters (?a - agent)
     :precondition
        (and (> (xpos ?a) 1)
            (= (get-index walls (ypos ?a) (- (xpos ?a) 1)) false) ##
            (not (exists (?d - door)
                (and (locked ?d) (= (ypos ?a) (yloc ?d)) (= (- (xpos ?a) 1) (xloc ?d))))))
     :effect (decrease (xpos ?a) 1)
    )
    (:action right
     :parameters (?a - agent)
     :precondition
        (and (< (xpos ?a) (width walls))
            (= (get-index walls (ypos ?a) (+ (xpos ?a) 1)) false)
            (not (exists (?d - door)
                (and (locked ?d) (= (ypos ?a) (yloc ?d)) (= (+ (xpos ?a) 1) (xloc ?d))))))
     :effect (increase (xpos ?a) 1)
    )
    (:action handover
     :parameters (?a - agent ?b - agent ?o - object)
     :precondition
     (and   (has (?a ?o)
            (or (and (= (xpos ?a) (xpos ?b)) (= (- (ypos ?a) 1) (ypos ?b)))
                (and (= (xpos ?a) (xpos ?b)) (= (+ (ypos ?a) 1) (ypos ?b)))
                (and (= (- (xpos ?a) 1) (xpos ?b)) (= (ypos ?a) (ypos ?b)))
                (and (= (+ (xpos ?a) 1) (xpos ?b)) (= (ypos ?a) (ypos ?b))))
     :effect (and (not (has ?a ?o)) (has ?b ?o))
    )
)
