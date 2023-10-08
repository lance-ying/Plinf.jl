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
        (at ?a - agent ?l - location)
        (in ?i - item ?c - container)
        (occupied ?l - location)
    )

    (:action move
     :parameters (?a - agent ?l1 - location ?l2 - location)
     :precondition (and (active ?a)  (not (at ?a ?l2)) (at ?a ?l1)
                           )
     :effect (and (at ?a ?l2) (not (at ?a ?l1))
                (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a)))
    )

    (:action grab
     :parameters (?a - agent ?i - item ?c - container)
     :precondition (and (active ?a)  (not (delivered ?i)) (at ?a ?c) (in ?i ?c) 
                           )
     :effect (and (delivered ?i) (not (in ?i ?c))
                (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
            (not (active ?a)))
    )

    ; (:action get_h
    ;  :parameters (?a - human ?i - item ?c - container)
    ;  :precondition (and (active ?a)  (not (delivered ?i)) (at ?a ?c) (in ?i ?c) 
    ;                        )
    ;  :effect (and (delivered ?i) (not (in ?i ?c))
    ;             (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
    ;         (not (active ?a)))
    ; )
    

    ; (:action takeout_r
    ;  :parameters (?a - robot ?i - item )
    ;  :precondition (and (active ?a)  (not (has ?a ?i)) 
    ;                         )
    ;  :effect (and (has ?a ?i) 
    ;             (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
    ;         (not (active ?a)))
    ; )
    ;     (:action takeout_h
    ;  :parameters (?a - human ?i - item ?c - container)
    ;  :precondition (and (active ?a)  (not (has ?a ?i)) 
    ;                         )
    ;  :effect (and (has ?a ?i) 
    ;             (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
    ;         (not (active ?a)))
    ; )



    ; (:action putdown_h
    ;  :parameters (?a - human ?i - item ?t - table)
    ;  :precondition (and (active ?a) (has ?a ?i)
    ;                         )
    ;  :effect (and (not (has ?a ?i))(on ?i ?t)
    ;               (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
    ;         (not (active ?a))
    ;         )
    ; )

    ; (:action putdown_r
    ;  :parameters (?a - robot ?i - item ?t - table)
    ;  :precondition (and (active ?a) (has ?a ?i)
    ;                         )
    ;  :effect (and (not (has ?a ?i))(on ?i ?t)
    ;               (forall (?b - agent) (when (next-turn ?a ?b) (active ?b)))
    ;         (not (active ?a))
    ;         )
    ; )

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
