# Functions for generating gridworld PDDL problems
using PDDL

"Converts ASCII gridworlds to PDDL problem."
function ascii_to_pddl(str::String, name="virtual-home")
    rows = split(str, "\n", keepempty=false)
    width, height = maximum(length.(strip.(rows))), length(rows)
    cabinets, tables, fridges, agents, sofas = Const[], Const[], Const[],Const[], Const[]
    push!(agents, Const(Symbol("robot")))
    push!(agents, Const(Symbol("human")))
    walls = parse_pddl("(= walls (new-bit-matrix false $height $width))")
    init = Term[walls]
    append!(init, parse_pddl("(= (agentcode human) 0)","(= (agentcode robot) 1)","(= turn 0)"))
    start_human, start_robot, goal = Term[],Term[], pddl"(true)"
    for (y, row) in enumerate(rows)
        for (x, char) in enumerate(strip(row))
            if char == '.' # Unoccupied
                continue
            elseif char == 'W' # Wall
                wall = parse_pddl("(= walls (set-index walls true $y $x))")
                push!(init, wall)
            elseif char == 'S'  # Door R = Red; B = Blue; Y = Yellow; E = Green; P = Purple
                s = Const(Symbol("sofa$(length(sofas)+1)"))
                push!(sofas, s)
                append!(init, parse_pddl("(= (xloc $s) $x)", "(= (yloc $s) $y)"))
            elseif char == 'C'  # Door R = Red; B = Blue; Y = Yellow; E = Green; P = Purple
                c = Const(Symbol("cabinet$(length(cabinets)+1)"))
                push!(cabinets, c)
                append!(init, parse_pddl("(= (xloc $c) $x)", "(= (yloc $c) $y)"))
                if length(cabinets)==1
                    for i in 1:4
                        item = Const(Symbol("bowl$i"))
                        append!(init, parse_pddl("(in $item $c)"))
                        append!(init, parse_pddl("(= (xloc $item) $x)", "(= (yloc $item) $y)"))
                    end
                end

                if length(cabinets)==1
                    for i in 1:4
                        item = Const(Symbol("bowl$i"))
                        append!(init, parse_pddl("(in $item $c)"))
                        append!(init, parse_pddl("(= (xloc $item) $x)", "(= (yloc $item) $y)"))
                    end
                end
                
            elseif char == 'T'  # Door R = Red; B = Blue; Y = Yellow; E = Green; P = Purple
                t = Const(Symbol("table$(length(tables)+1)"))
                push!(tables, t)
                append!(init, parse_pddl("(= (xloc $t) $x)", "(= (yloc $t) $y)"))
            elseif char == 'F'  # Door R = Red; B = Blue; Y = Yellow; E = Green; P = Purple
                f = Const(Symbol("fridge$(length(fridges)+1)"))
                push!(fridges, f)
                append!(init, parse_pddl("(= (xloc $f) $x)", "(= (yloc $f) $y)"))
            elseif char == 'h' # Start position
                start_human = parse_pddl("(= (xloc human) $x)", "(= (yloc human) $y)")
            elseif char == 'm'
                start_robot = parse_pddl("(= (xloc robot) $x)", "(= (yloc robot) $y)")
            end
        end
    end
    append!(init, start_human)
    append!(init, start_robot)
    objtypes = merge(Dict(f => :fridge for f in fridges),
                     Dict(t => :table for t in tables),
                     Dict(a => :agent for a in agents),
                     Dict(s => :sofa for s in sofas),
                     Dict(c => :cabinet for c in cabinets))

    problem = GenericProblem(Symbol(name), Symbol("virtual-home"),
                             [fridges; tables; agents; sofas; cabinets], objtypes, init, goal,
                             nothing, nothing)
    return problem
end

function load_ascii_problem(path::AbstractString)
    str = open(f->read(f, String), path)
    return ascii_to_pddl(str)
end

function convert_ascii_problem(path::String)
    str = open(f->read(f, String), path)
    str = ascii_to_pddl(str)
    new_path = splitext(path)[1] * ".pddl"
    write(new_path, write_problem(str))
    return new_path
end
