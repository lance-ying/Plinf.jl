# Functions for generating gridworld PDDL problems
using PDDL

"Converts ASCII gridworlds to PDDL problem."
function ascii_to_pddl(str::String, name="doors-keys-gems-problem")
    rows = split(str, "\n", keepempty=false)
    width, height = maximum(length.(strip.(rows))), length(rows)
    doors, keys, gems, robot, human, colors = Const[], Const[], Const[],Const[], Const[], Const[]
    push!(robot, Const(Symbol("robot")))
    push!(human, Const(Symbol("human")))
    key_dict=Dict('r' =>  Const(Symbol("red")) , 'b' =>  Const(Symbol("blue")), 'y' =>  Const(Symbol("yellow")) , 'e' =>  Const(Symbol("green")), 'p' => Const(Symbol("pink")))
    door_dict=Dict('R' =>  Const(Symbol("red")) , 'B' =>  Const(Symbol("blue")), 'Y' =>  Const(Symbol("yellow")) , 'E' =>  Const(Symbol("green")), 'P' => Const(Symbol("pink")))
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
            elseif haskey(door_dict, char)  # Door R = Red; B = Blue; Y = Yellow; E = Green; P = Purple
                d = Const(Symbol("door$(length(doors)+1)"))
                c = door_dict[char]
                push!(doors, d)
                if !(c in colors)
                    push!(colors, c)
                end
                append!(init, parse_pddl("(= (xloc $d) $x)", "(= (yloc $d) $y)"))
                push!(init, parse_pddl("(iscolor $d $c)"))
                push!(init, parse_pddl("(locked $d)"))
            elseif haskey(key_dict, char)  # Key
                k = Const(Symbol("key$(length(keys)+1)"))
                c = key_dict[char]
                push!(keys, k)
                append!(init, parse_pddl("(= (xloc $k) $x)", "(= (yloc $k) $y)"))
                # print(c)
                # print(typeof(c))
                push!(init, parse_pddl("(iscolor $k $c)"))
            elseif char == 'g' || char == 'G' # Gem
                g = Const(Symbol("gem$(length(gems)+1)"))
                push!(gems, g)
                append!(init, parse_pddl("(= (xloc $g) $x)", "(= (yloc $g) $y)"))
                goal = parse_pddl("(has human $g)")
            elseif char == 'h' # Start position
                start_human = parse_pddl("(= (xloc human) $x)", "(= (yloc human) $y)")
            elseif char == 'm'
                start_robot = parse_pddl("(= (xloc robot) $x)", "(= (yloc robot) $y)")
            end
        end
    end
    append!(init, start_human)
    append!(init, start_robot)
    objtypes = merge(Dict(d => :door for d in doors),
                     Dict(k => :key for k in keys),
                     Dict(g => :gem for g in gems),
                     Dict(c => :color for c in colors),
                     Dict(h => :human for h in human),
                     Dict(m => :robot for m in robot))

    problem = GenericProblem(Symbol(name), Symbol("doors-keys-gems"),
                             [doors; keys; gems; colors; robot; human], objtypes, init, goal,
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
