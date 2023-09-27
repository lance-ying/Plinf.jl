(define (domain virtual-home)
    (:requirements :fluents :adl :typing)
    (:types 
        cutleryknife cutleryfork cutleryspoon bowl chefknife wineglass waterglass plate juice wine cupcake cheese cuttingboard potato beef carrot onion - item
        cabinet fridge - container
        item table container agent - physical
    )
    (:predicates
        (has ?a ?i - item) 
        (offgrid ?i - item)
        (on ?i - item ?t - table)
        (in ?i - item ?c - container)
    )
    (:functions
        (xloc ?o - physical) (yloc ?o - physical) - integer
        (agentcode ?a - agent) - integer
        (turn)- integer
        (walls)- bit-matrix
    )
    (:action pickup
     :parameters (?a - agent ?i - item ?t - table)
     :precondition (and (not (has ?a ?i)) 
                            ; (or (and (= (xloc ?a) (xloc ?t)) (= (- (yloc ?a) 1) (yloc ?t)))
                            ; (and (= (xloc ?a) (xloc ?t)) (= (+ (yloc ?a) 1) (yloc ?t)))
                            ; (and (= (- (xloc ?a) 1) (xloc ?t)) (= (yloc ?a) (yloc ?t)))
                            ; (and (= (+ (xloc ?a) 1) (xloc ?t)) (= (yloc ?a) (yloc ?t))))
                            (on ?i ?t)
                            ; (= (xloc ?i) (xloc ?t)) (= (yloc ?i) (yloc ?t))(= turn (agentcode ?a))
                            )
     :effect (and (has ?a ?i) (offgrid ?i) (not (on ?i ?t))
                  (assign (xloc ?i) -1) (assign (yloc ?i) -1) (assign turn (- 1 turn)))
    )
    ; (:action pickup
    ;  :parameters (?a - agent ?i - item)
    ;  :precondition (and (not (has ?a ?i)) 
    ;                         ; (or (and (= (xloc ?a) (xloc ?t)) (= (- (yloc ?a) 1) (yloc ?t)))
    ;                         ; (and (= (xloc ?a) (xloc ?t)) (= (+ (yloc ?a) 1) (yloc ?t)))
    ;                         ; (and (= (- (xloc ?a) 1) (xloc ?t)) (= (yloc ?a) (yloc ?t)))
    ;                         ; (and (= (+ (xloc ?a) 1) (xloc ?t)) (= (yloc ?a) (yloc ?t))))
    ;                         ; (on ?i ?t)
    ;                         (= (xloc ?i) (xloc ?a)) (= (yloc ?i) (yloc ?a))(= turn (agentcode ?a)))
    ;  :effect (and (has ?a ?i) (offgrid ?i)
    ;               (assign (xloc ?i) -1) (assign (yloc ?i) -1) (assign turn (- 1 turn)))
    ; )
    (:action takeout
     :parameters (?a - agent ?i - item ?c - container)
     :precondition (and (not (has ?a ?i)) 
                            ; (or (and (= (xloc ?a) (xloc ?c)) (= (- (yloc ?a) 1) (yloc ?c)))
                            ; (and (= (xloc ?a) (xloc ?c)) (= (+ (yloc ?a) 1) (yloc ?c)))
                            ; (and (= (- (xloc ?a) 1) (xloc ?c)) (= (yloc ?a) (yloc ?c)))
                            ; (and (= (+ (xloc ?a) 1) (xloc ?c)) (= (yloc ?a) (yloc ?c))))
                            ; (= (xloc ?i) (xloc ?c)) (= (yloc ?i) (yloc ?t))
                            (in ?i ?c)
                            (= turn (agentcode ?a)))
     :effect (and (has ?a ?i) (offgrid ?i)(not (in ?i ?c))
                  (assign (xloc ?i) -1) (assign (yloc ?i) -1) (assign turn (- 1 turn)))
    )
    (:action putdown
     :parameters (?a - agent ?i - item ?t - table)
     :precondition (and (has ?a ?i)
                            ; (or (and (= (xloc ?a) (xloc ?t)) (= (- (yloc ?a) 1) (yloc ?t)))
                            ; (and (= (xloc ?a) (xloc ?t)) (= (+ (yloc ?a) 1) (yloc ?t)))
                            ; (and (= (- (xloc ?a) 1) (xloc ?t)) (= (yloc ?a) (yloc ?t)))
                            ; (and (= (+ (xloc ?a) 1) (xloc ?t)) (= (yloc ?a) (yloc ?t))))
                            (= turn (agentcode ?a)))
     :effect (and (not (has ?a ?i)) (not (offgrid ?i))(on ?i ?t)
                  (assign (xloc ?i) -1) (assign (yloc ?i) -1) (assign turn (- 1 turn)))
    )
    ; (:action putin
    ;  :parameters (?a - agent ?i - item ?c - container)
    ;  :precondition (and (not (has ?a ?i))
    ;                         (or (and (= (xloc ?a) (xloc ?c)) (= (- (yloc ?a) 1) (yloc ?c)))
    ;                         (and (= (xloc ?a) (xloc ?c)) (= (+ (yloc ?a) 1) (yloc ?c)))
    ;                         (and (= (- (xloc ?a) 1) (xloc ?c)) (= (yloc ?a) (yloc ?c)))
    ;                         (and (= (+ (xloc ?a) 1) (xloc ?c)) (= (yloc ?a) (yloc ?c))))
    ;                         (= turn (agentcode ?a)))
    ;  :effect (and (not (has ?a ?i)) (not (offgrid ?i))(in ?i ?c)
    ;               (assign (xloc ?i) -1) (assign (yloc ?i) -1) (assign turn (- 1 turn)))
    ; )
    ; (:action up
    ;  :parameters (?a - agent)
    ;  :precondition
    ;     (and (> (yloc ?a) 1) (= turn (agentcode ?a))
    ;         (= (get-index walls (- (yloc ?a) 1) (xloc ?a)) false)
    ;         )
    ;  :effect (and (decrease (yloc ?a) 1) (assign turn (- 1  turn)))
    ; )
    ; (:action down
    ;  :parameters (?a - agent)
    ;  :precondition
    ;     (and (< (yloc ?a) (height walls)) (= turn (agentcode ?a))
    ;         (= (get-index walls (+ (yloc ?a) 1) (xloc ?a)) false)
    ;         )
    ;  :effect(and (increase (yloc ?a) 1) (assign turn (- 1  turn)))
    ; )
    ; (:action left
    ;  :parameters (?a - agent)
    ;  :precondition
    ;     (and (> (xloc ?a) 1) (= turn (agentcode ?a))
    ;         (= (get-index walls (yloc ?a) (- (xloc ?a) 1)) false)
    ;         )
    ;  :effect (and (decrease (xloc ?a) 1) (assign turn (- 1  turn)))
    ; )
    ; (:action right
    ;  :parameters (?a - agent)
    ;  :precondition
    ;     (and (< (xloc ?a) (width walls)) (= turn (agentcode ?a))
    ;         (= (get-index walls (yloc ?a) (+ (xloc ?a) 1)) false)
    ;         )
    ;  :effect (and (increase (xloc ?a) 1) (assign turn (- 1 turn)))
    ; )
    (:action noop
     :parameters (?a - agent)
     :precondition
     ((= turn (agentcode ?a)))
     :effect (assign turn (- 1 turn))
    )
)
