using PDDL, SymbolicPlanners

"Validates a goal generation with several checks."
function validate_goal(str::AbstractString, domain::Domain, state::State;
                       verbose::Bool=false)
    # Check if string parses to PDDL formula
    goal = nothing
    try
        goal = parse_goal(str)
    catch e
        reason = "Parse error"
        if verbose println("Validation Failed: $reason") end
        return (false, reason)
    end
    if verbose println("Validation: Goal Parsed") end
    # Check if predicates and types exist in the domain
    valid = validate_predicates_and_types(goal, domain)
    if !valid
        reason = "Non-existent predicates or types"
        if verbose println("Validation Failed: $reason") end
        return (false, reason)
    end
    if verbose println("Validation: Predicates and Types Exist") end
    # Check if objects exist in the initial state
    valid = validate_objects(goal, domain, state)
    if !valid
        reason = "Non-existent objects or variables"
        if verbose println("Validation Failed: $reason") end
        return (false, reason)
    end
    if verbose println("Validation: Objects and Variables Exist") end
    # Check if goal is reachable from the initial state
    valid = validate_reachability(goal, domain, state; verbose=verbose)
    if !valid
        reason = "Goal is not reachable"
        if verbose println("Validation Failed: $reason") end
        return (false, reason)
    end
    if verbose println("Validation: Goal is Reachable") end
    return (true, "All checks passed")
end

"Parse a string as a PDDL goal, checking if it is a valid PDDL formula."
function parse_goal(str::AbstractString)
    goal = parse_pddl(str)
    @assert goal isa Term
    return goal
end

"Returns whether all predicates and types in a `term` are defined in `domain`."
function validate_predicates_and_types(term::Term, domain::Domain)
    if PDDL.is_quantifier(term)
        typeconds = PDDL.flatten_conjs(term.args[1])
        body = term.args[2]
        return (all(PDDL.is_type(cond, domain) for cond in typeconds) &&
                validate_predicates_and_types(body, domain))
    elseif PDDL.is_logical_op(term)
        return all(validate_predicates_and_types(a, domain) for a in term.args)
    elseif PDDL.is_pred(term, domain) || PDDL.is_global_pred(term)
        return true
    else
        return false
    end
end

"Returns whether all objects referenced in a `term` exist in the initial `state`."
function validate_objects(term::Term, domain::Domain, state::State,
                          variables=Var[])
    if PDDL.is_quantifier(term)
        typeconds = PDDL.flatten_conjs(term.args[1])
        vars = vcat(variables, [cond.args[1] for cond in typeconds])
        body = term.args[2]
        return validate_objects(body, domain, state, vars)
    elseif PDDL.is_logical_op(term)
        return all(validate_objects(a, domain, state, variables) for a in term.args)
    elseif PDDL.is_pred(term, domain) || PDDL.is_global_pred(term)
        return all(obj in PDDL.get_objects(state) ||
                   (obj isa Var && obj in variables) for obj in term.args)
    else
        return false
    end
end

"Returns whether goal is reachable from initial state."
function validate_reachability(goal::Term, domain::Domain, state::State;
                               verbose::Bool=false, max_time=10.0)
    # Check if reachable using HMax
    heuristic = HMax()
    hval = heuristic(domain, state, goal)
    if hval == Inf
        if verbose println("Unreachable according to heuristic.") end
        return false
    end
    
    # Check if a plan can be found that reaches the goal
    planner = AStarPlanner(HAdd(), max_time=max_time)
    sol = planner(domain, state, goal)
    if sol isa NullSolution
        if verbose println("Unreachable according to planner.") end
        return false
    end
    return true
end

# # Load domain and problem
# domain = load_domain(joinpath(@__DIR__, "domain.pddl"))
# problem = load_problem(joinpath(@__DIR__, "problem-5-1.pddl"))
# state = initstate(domain, problem)

# # Goal as string
# str = """
#     (exists (?lettuce - food ?tomato - food ?plate - receptacle)
#         (and (food-type lettuce ?lettuce)
#              (food-type tomato ?tomato)
#              (receptacle-type plate ?plate)
#              (prepared slice ?lettuce)
#              (prepared slice ?tomato)
#              (in-receptacle ?lettuce ?plate)
#              (in-receptacle ?tomato ?plate)))
# """

# # Test whether goal string is valid