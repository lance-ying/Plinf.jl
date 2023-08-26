# Test gridworld rendering
using PDDL, SymbolicPlanners
using PDDLViz, GLMakie
using Test

using Makie.FFMPEG
import Makie: to_color
import PDDLViz: Animation, is_displayed

# Load example gridworld domain and problem
# domain = load_domain(joinpath(@__DIR__, "domain.pddl"))
# problem = load_problem(joinpath(@__DIR__, "p1.pddl"))

# Load array extension to PDDL
PDDL.Arrays.register!()

function get_obj_color(state::State, obj::Const)
    for color in PDDL.get_objects(state, :color)
        if state[Compound(:iscolor, Term[obj, color])]
            return color
        end
    end
    return Const(:none)
end



# Construct gridworld renderer
colorscheme = PDDLViz.colorschemes[:vibrant]
colors=[:red, colorscheme[2], colorant"#56b4e9", colorant"#009e73"]
colordict = Dict(
    :red => colorscheme[1],
    :yellow => colorscheme[2],
    :blue => colorant"#0072b2",
    :green => :springgreen,
    :purple => colorscheme[5],
    :orange => colorscheme[6],
    :none => :gray
)
renderer = PDDLViz.GridworldRenderer(
    has_agent = false,
    obj_renderers = Dict(
        :agent => (d, s, o) -> o.name == :human ?
            HumanGraphic() : RobotGraphic(),
        :key => (d, s, o) -> MultiGraphic(KeyGraphic(-0.1,-0.1,
            visible=!s[Compound(:has, [o])],
            # color=get_obj_color(s, o).name
            color=colordict[get_obj_color(s, o).name]
        ),
        TextGraphic(
            string(o.name)[end:end], 0.3, 0.2, 0.5,
            color=:black, font=:bold
        )),
        :door => (d, s, o) -> LockedDoorGraphic(
            visible=s[Compound(:locked, [o])],
            # color=get_obj_color(s, o).name
            color=colordict[get_obj_color(s, o).name]
        ),
        :gem => (d, s, o) -> MultiGraphic(
            GemGraphic(
                visible=!s[Compound(:has, [o])],
                # color=colorscheme[parse(Int, string(o.name)[end])]
                color=colors[parse(Int, string(o.name)[end])]
                # color=:orange
            )
        )
    ),
    obj_type_z_order = [:door, :key, :gem, :agent],
    show_inventory = true,
    inventory_fns = [
        (d, s, o) -> s[Compound(:has, [Const(:human), o])],
        (d, s, o) -> s[Compound(:has, [Const(:robot), o])]
    ],
    inventory_types = [:item, :item],
    inventory_labels = ["Human", "Robot"],
    trajectory_options = Dict(
        :tracked_objects => [Const(:human), Const(:robot)],
        :object_colors => [:black, :slategray]
    )
)

# # Construct initial state from domain and problem
# state = initstate(domain, problem)

# # Render initial state
# canvas = renderer(domain, state)

# Render plan
# plan = @pddl("(right human)", "(left robot)", "(right human)", "(left robot)")
# renderer(canvas, domain, state, plan)

# Custom animation override to support captions
function PDDLViz.anim_trajectory!(
    canvas::Canvas, renderer::GridworldRenderer, domain::Domain, trajectory;
    format="mp4", framerate=5, show::Bool=is_displayed(canvas),
    showrate=framerate, captions=nothing, options...
)
    if canvas.state === nothing
        caption = isnothing(captions) ? nothing : get(captions, 1, "")
        render_state!(canvas, renderer, domain, trajectory[1];
                      caption=caption, options...)
    else
        canvas.state[] = trajectory[1]
    end
    if show && !is_displayed(canvas)
        display(canvas)
    end
    record_args = filter(Dict(options)) do (k, v)
        k in (:compression, :profile, :pixel_format)
    end
    vs = Record(canvas.figure; visible=is_displayed(canvas), format=format,
                framerate=framerate, record_args...) do io
        recordframe!(io)
        for (i, state) in enumerate(trajectory[2:end])
            canvas.state[] = state
            if !isnothing(captions)
                caption = get(captions, i+1, nothing)
                if !isnothing(caption)
                    canvas.observables[:caption][] = caption
                end
            end
            recordframe!(io)
            if show
                notify(canvas.state)
                sleep(1/showrate)
            end
        end
    end
    return PDDLViz.Animation(vs)
end

# Override Makie.convert_video to support GIF loop control
function Makie.convert_video(input_path, output_path; loop=nothing, video_options...)
    p, typ = splitext(output_path)
    format = lstrip(typ, '.')
    vso = Makie.VideoStreamOptions(; format=format, input=input_path,
                                   rawvideo=false, video_options...)
    cmd = Makie.to_ffmpeg_cmd(vso)
    if format == "gif" && !isnothing(loop) # Append loop setting to options
        cmd = `$cmd -loop $loop`
    end
    Makie.@ffmpeg_env run(`$cmd $output_path`)
end

# # Construct trajectory 
# planner = AStarPlanner(GoalCountHeuristic())
# spec = Specification(problem)
# sol = planner(domain, state, spec); sol.status
# plan = collect(sol)
# trajectory = PDDL.simulate(domain, state, plan)

# # Define captions in dictionary (a vector is also allowed)
# captions = Dict(
#     1 => "Human: \"Pick up the red gem for me.\"",
#     6 => "...",
#     9 => "Human: \"Now unlock the door.\"",
#     15 => "...",
#     21 => "Human: \"Thanks! 😃\""
# )

# # Animate trajectory with captions
# anim = anim_trajectory(renderer, domain, trajectory, format="gif", 
#                        captions=captions, framerate=3)

# # Save animation with loop=-1 to get rid of GIF looping
# save("multi-agent-dkg-w-captions.gif", anim, framerate=3, loop=-1)
