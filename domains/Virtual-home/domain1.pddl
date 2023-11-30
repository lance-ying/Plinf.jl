(define (domain virtual-home)
    (:requirements :fluents :adl :typing)
    (:types 
        ; cutleryknife cutleryfork cutleryspoon bowl chefknife wineglass waterglass plate juice wine cupcake cheese cuttingboard potato beef carrot onion - item
        cabinet fridge - container
        table container - location
        item table container agent - physical
        robot human - agent
    )
    (:predicates
        (delivered ?i - item)
        (active ?a - agent)
        (next-turn ?a - agent ?b - agent)
        (frozen ?a - agent)
        (at ?a - agent ?l - location)
        (in ?i - item ?c - container)
    )

    (:action move
     :parameters (?a - agent ?l1 - location ?l2 - location)
     :precondition (and (active ?a) (not (frozen ?a)) (not (at ?a ?l2)) (at ?a ?l1)
                           )
     :effect (and (at ?a ?l2) (not (at ?a ?l1))
                (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a)))
    )

    (:action grab
     :parameters (?a - agent ?i - item ?c - container)
     :precondition (and (active ?a) (not (frozen ?a)) (not (delivered ?i)) (at ?a ?c) (in ?i ?c) 
                           )
     :effect (and (delivered ?i) (not (in ?i ?c))
                (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a)))
    )
    (:action noop
     :parameters (?a - agent)
     :precondition (active ?a)
     :effect (and (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
                  (not (active ?a)))
    )
)
