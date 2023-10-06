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
        (has ?a - agent ?i - item) 
        (on ?i - item ?t - table)
        (in ?i - item ?c - container)
        (at ?a - agent ?i - location)
        (isset2 ?a - item ?b - item)
        (isset3 ?a - item ?b - item ?c - item)
        (isset4 ?a - item ?b - item ?c - item ?d - item)
        ; (taken-by ?a - agent ?i - item)
        ; (frozen ?a - agent)
        (active ?a - agent)
        (next-turn ?a - agent ?b - agent)
    )
    ; (:action pickup
    ;  :parameters (?a - agent ?i - item ?t - table)
    ;  :precondition (and (active ?a) (not (has ?a ?i)) 
    ;                         (on ?i ?t)
    ;                         )
    ;  :effect (and (has ?a ?i) (not (on ?i ?t))
    ;               (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
    ;         (not (active ?a)))
    ; )
    (:action takeout
     :parameters (?a - agent ?i - item ?c - container)
     :precondition (and (active ?a)  (not (has ?a ?i)) 
                            (in ?i ?c))
     :effect (and (has ?a ?i) (not (in ?i ?c)) 
                (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a)))
    )

     (:action takeout2
     :parameters (?a - agent ?i - item ?j - item ?c - container)
     :precondition (and (active ?a)  (not (has ?a ?i)) (not (has ?a ?j)) 
                            (in ?i ?c) (in ?j ?c) (isset2 ?i ?j))
     :effect (and (has ?a ?i)(has ?a ?j) (not (in ?i ?c))  (not (in ?j ?c)) 
                (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a)))
    )

    ; (:action takeout3
    ;  :parameters (?a - agent ?i - item ?j - item ?k - item ?c - container)
    ;  :precondition (and (active ?a)  (not (has ?a ?i)) (not (has ?a ?j)) (not (has ?a ?k)) 
    ;                          (in ?i ?c) (in ?j ?c) (in ?k ?c) (isset3 ?i ?j ?k))
    ;  :effect (and (has ?a ?i)(has ?a ?j)(has ?a ?j) (not (in ?i ?c)) (not (in ?j ?c)) (not (in ?k ?c)) 
    ;             (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
    ;         (not (active ?a)))
    ; )

    ; (:action takeout4
    ;  :parameters (?a - agent ?i - item ?j - item ?k - item ?h - item ?c - container)
    ;  :precondition (and (active ?a) (not (has ?a ?i)) (not (has ?a ?j)) (not (has ?a ?k))  (not (has ?a ?h)) 
    ;                         (in ?i ?c) (in ?j ?c) (in ?k ?c) (in ?h ?c) (isset4 ?i ?j ?k ?h))
    ;  :effect (and  (has ?a ?i)(has ?a ?j)(has ?a ?j)(has ?a ?h) (not (in ?i ?c)) (not (in ?j ?c)) (not (in ?k ?c)) (not (in ?h ?c)) 
    ;             (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
    ;         (not (active ?a)))
    ; )

    ; (:action putdown
    ;  :parameters (?a - agent ?i - item ?t - table)
    ;  :precondition (and (active ?a) (has ?a ?i)
    ;                         )
    ;  :effect (and (not (has ?a ?i))(on ?i ?t)
                  
    ;               (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
    ;         (not (active ?a))
    ;         )
    ; )

    (:action putdown
     :parameters (?a - agent ?i - item ?t - table)
     :precondition (and (active ?a) (has ?a ?i)
                            )
     :effect (and (not (has ?a ?i))(on ?i ?t)
                  (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a))
            )
    )

        (:action putdown2
     :parameters (?a - agent ?i - item ?j - item ?t - table)
     :precondition (and (active ?a) (has ?a ?i)(has ?a ?j) (isset2 ?i ?j)
                            )
     :effect (and (not (has ?a ?i))(not (has ?a ?j))(on ?i ?t)(on ?j ?t)
                  
                  (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a))
            )
    )

    ;     (:action putdown3
    ;  :parameters (?a - agent ?i - item ?j - item ?k - item ?t - table)
    ;  :precondition (and (active ?a) (has ?a ?i)(has ?a ?j)(has ?a ?k) (isset3 ?i ?j ?k)
    ;                         )
    ;  :effect (and (not (has ?a ?i))(not (has ?a ?j))(not (has ?a ?k))(on ?i ?t)(on ?j ?t)(on ?k ?t)
                  
    ;               (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
    ;         (not (active ?a))
    ;         )
    ; )

    ;     (:action putdown4
    ;  :parameters (?a - agent ?i - item ?j - item ?k - item ?h - item ?t - table)
    ;  :precondition (and (active ?a)  (has ?a ?i)(has ?a ?j)(has ?a ?k)(has ?a ?h) (isset4 ?i ?j ?k ?h)
    ;                         )
    ;  :effect (and (not (has ?a ?i))(not (has ?a ?j))(not (has ?a ?k))(not (has ?a ?h))(on ?i ?t)(on ?j ?t)(on ?k ?t)(on ?h ?t)
                  
    ;               (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
    ;         (not (active ?a))
    ;         )
    ; )


    (:action noop
     :parameters (?a - agent)
     :precondition (active ?a)
     :effect (and (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
                  (not (active ?a)))
    )
)
