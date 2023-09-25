(define (domain doors-keys-gems)
    (:requirements :fluents :adl :typing)
    (:types 
        key gem - item
        robot human - agent
        item door agent - physical
        physical color - object
    )
    (:predicates
        (has ?a - agent ?i - item) 
        (forbidden ?a - agent ?i - item)
        (iscolor ?o - physical ?c - color)
        (offgrid ?i - item)
        (locked ?d - door)
        (unlocked-by ?a - agent ?d - door)
        (active ?a - agent)
        (next-turn ?a - agent ?b - agent)
    )
    (:functions
        (xloc ?o - physical) (yloc ?o - physical) - integer
        (walls)- bit-matrix
    )
    (:action pickup
     :parameters (?a - agent ?i - item)
     :precondition
        (and (active ?a) (not (forbidden ?a ?i)) (not (has ?a ?i))
            (= (xloc ?a) (xloc ?i)) (= (yloc ?a) (yloc ?i)))
     :effect 
        (and (has ?a ?i) (offgrid ?i)
            (assign (xloc ?i) -1) (assign (yloc ?i) -1)
            (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a)))
    )
    (:action unlock
     :parameters (?a - agent ?k - key ?d - door)
     :precondition
        (and (active ?a) (has ?a ?k) (locked ?d)
            (exists (?c - color) (and (iscolor ?k ?c) (iscolor ?d ?c)))
                (or (and (= (xloc ?a) (xloc ?d)) (= (- (yloc ?a) 1) (yloc ?d)))
                    (and (= (xloc ?a) (xloc ?d)) (= (+ (yloc ?a) 1) (yloc ?d)))
                    (and (= (- (xloc ?a) 1) (xloc ?d)) (= (yloc ?a) (yloc ?d)))
                    (and (= (+ (xloc ?a) 1) (xloc ?d)) (= (yloc ?a) (yloc ?d)))))
     :effect
        (and (not (has ?a ?k)) (not (locked ?d)) (unlocked-by ?a ?d)
            (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a)))
    )
    (:action up
     :parameters (?a - agent)
     :precondition
        (and (active ?a) (> (yloc ?a) 1)
            (= (get-index walls (- (yloc ?a) 1) (xloc ?a)) false)
            (not (exists (?d - door)
                (and (locked ?d) (= (xloc ?a) (xloc ?d)) (= (- (yloc ?a) 1) (yloc ?d))))))
     :effect
        (and (decrease (yloc ?a) 1)
            (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a)))
    )
    (:action down
     :parameters (?a - agent)
     :precondition
        (and (active ?a) (< (yloc ?a) (height walls))
            (= (get-index walls (+ (yloc ?a) 1) (xloc ?a)) false)
            (not (exists (?d - door)
                (and (locked ?d) (= (xloc ?a) (xloc ?d)) (= (+ (yloc ?a) 1) (yloc ?d))))))
     :effect
        (and (increase (yloc ?a) 1)
            (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a)))
    )
    (:action left
     :parameters (?a - agent)
     :precondition
        (and (active ?a) (> (xloc ?a) 1)
            (= (get-index walls (yloc ?a) (- (xloc ?a) 1)) false)
            (not (exists (?d - door)
                (and (locked ?d) (= (yloc ?a) (yloc ?d)) (= (- (xloc ?a) 1) (xloc ?d))))))
     :effect
        (and (decrease (xloc ?a) 1)
            (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a)))
    )
    (:action right
     :parameters (?a - agent)
     :precondition
        (and (active ?a) (< (xloc ?a) (width walls))
            (= (get-index walls (yloc ?a) (+ (xloc ?a) 1)) false)
            (not (exists (?d - door)
                (and (locked ?d) (= (yloc ?a) (yloc ?d)) (= (+ (xloc ?a) 1) (xloc ?d))))))
     :effect
        (and (increase (xloc ?a) 1)
            (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a)))
    )
    (:action handover
     :parameters (?a - agent ?b - agent ?i - item)
     :precondition
        (and (active ?a) (has ?a ?i)
            (or (and (= (xloc ?a) (xloc ?b)) (= (- (yloc ?a) 1) (yloc ?b)))
                (and (= (xloc ?a) (xloc ?b)) (= (+ (yloc ?a) 1) (yloc ?b)))
                (and (= (- (xloc ?a) 1) (xloc ?b)) (= (yloc ?a) (yloc ?b)))
                (and (= (+ (xloc ?a) 1) (xloc ?b)) (= (yloc ?a) (yloc ?b)))))
     :effect
        (and (not (has ?a ?i)) (has ?b ?i)
            (forall (?c - agent) (when (next-turn ?a ?c) (active ?c)))
            (not (active ?a)))
    )
    (:action noop
     :parameters (?a - agent)
     :precondition (active ?a)
     :effect (and (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
                  (not (active ?a)))
    )
)
