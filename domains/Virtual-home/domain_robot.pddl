(define (domain virtual-home)
    (:requirements :fluents :adl :typing)
    (:types 
        cutleryknife cutleryfork cutleryspoon bowl chefknife wineglass waterglass plate juice wine cupcake cheese cuttingboard lettuce beef chicken fish carrot onion - item
        cabinet fridge - container
        item table container agent - physical
    )
    (:predicates
        (has ?i - item) 
        (offgrid ?i - item)
        (on ?i - item ?t - table)
        (in ?i - item ?c - container)
    )
    (:functions
        (xloc ?o - physical) (yloc ?o - physical) - integer
        (agentcode ?a - agent) - integer
        (walls)- bit-matrix
    )
    (:action pickup
     :parameters (?i - item ?t - table)
     :precondition (and (not (has ?i)) (on ?i ?t))
     :effect (and (has ?i) (offgrid ?i) (not (on ?i ?t))
                  (assign (xloc ?i) -1) (assign (yloc ?i) -1))
    )
    (:action takeout
     :parameters (?a - agent ?i - item ?c - container)
     :precondition (and (not (has ?i)) 
                            (in ?i ?c)
                            (= turn (agentcode ?a)))
     :effect (and (has ?i) (offgrid ?i)(not (in ?i ?c))
                  (assign (xloc ?i) -1) (assign (yloc ?i) -1))
    )
    (:action putdown
     :parameters (?a - agent ?i - item ?t - table)
     :precondition (and (has ?i)
                            (= turn (agentcode ?a)))
     :effect (and (not (has ?i)) (not (offgrid ?i))(on ?i ?t)
                  (assign (xloc ?i) -1) (assign (yloc ?i) -1))
    )

)
