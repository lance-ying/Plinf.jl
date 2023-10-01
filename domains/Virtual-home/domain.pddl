(define (domain virtual-home)
    (:requirements :fluents :adl :typing)
    (:types 
        ; cutleryknife cutleryfork cutleryspoon bowl chefknife wineglass waterglass plate juice wine cupcake cheese cuttingboard potato beef carrot onion - item
        cabinet fridge - container
        item table container agent - physical
    )
    (:predicates
        (has ?a - agent ?i - item) 
        (offgrid ?i - item)
        (on ?i - item ?t - table)
        (in ?i - item ?c - container)
        (taken-by ?a - agent ?i - item)
        (frozen ?a - agent)
        (active ?a - agent)
        (next-turn ?a - agent ?b - agent)
    )
    (:functions
        (agentcode ?a - agent) - integer
        (walls)- bit-matrix
    )
    (:action pickup
     :parameters (?a - agent ?i - item ?t - table)
     :precondition (and (active ?a) (not (frozen ?a)) (not (has ?a ?i)) 
                            (on ?i ?t)
                            )
     :effect (and (has ?a ?i) (not (on ?i ?t))
                  (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a)))
    )
    (:action takeout
     :parameters (?a - agent ?i - item ?c - container)
     :precondition (and (active ?a) (not (frozen ?a)) (not (has ?a ?i)) 
                            (in ?i ?c))
     :effect (and (has ?a ?i) (not (in ?i ?c)) (taken-by ?a ?i)
                (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a)))
    )
    (:action putdown
     :parameters (?a - agent ?i - item ?t - table)
     :precondition (and (active ?a) (not (frozen ?a)) (has ?a ?i)
                            (= turn (agentcode ?a)))
     :effect (and (not (has ?a ?i))(on ?i ?t)
                  
                  (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a))
            )
    )
    (:action noop
     :parameters (?a - agent)
     :precondition (active ?a)
     :effect (and (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
                  (not (active ?a)))
    )
)
