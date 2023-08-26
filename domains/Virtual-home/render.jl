# Test gridworld rendering
using PDDL, SymbolicPlanners
using PDDLViz, GLMakie
using Test

using Makie.FFMPEG
import Makie: to_color
import PDDLViz: Animation, is_displayed

# Define colors
vibrant = PDDLViz.colorschemes[:vibrant]
gem_colors = [to_color(:red), vibrant[2], colorant"#56b4e9", colorant"#009e73"]
colordict = Dict(
    :red => vibrant[1],
    :yellow => vibrant[2],
    :blue => colorant"#0072b2",
    :green => :springgreen,
    :purple => vibrant[5],
    :orange => vibrant[6],
    :none => :gray
)

# Construct gridworld renderer
renderer_b = PDDLViz.GridworldRenderer(
    resolution = (600, 700),
    has_agent = false,
    obj_renderers = Dict(
        :agent => (d, s, o) -> o.name == :human ?
            HumanGraphic() : RobotGraphic(),
        # :key => (d, s, o) -> KeyGraphic(-0.1,-0.1,
        #     visible=!s[Compound(:has, [o])],
        #     # color=get_obj_color(s, o).name
        #     color=colordict[get_obj_color(s, o).name]
        # ),
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
            color=colordict[get_obj_color(s, o).name]
        ),
        :gem => (d, s, o) -> GemGraphic(
            color=gem_colors[parse(Int, string(o.name)[end])]
        )
    ),
    obj_type_z_order = [:door, :key, :gem, :agent],
    show_inventory = true,
    inventory_fns = [
        (d, s, o) -> s[Compound(:has, [Const(:human), o])]
    ],
    inventory_types = [:item],
    inventory_labels = ["Human Inventory"],
    trajectory_options = Dict(
        :tracked_objects => [Const(:human), Const(:robot)],
        :tracked_types => Const[],
        :object_colors => [:black, :slategray]
    )
)

renderer = PDDLViz.GridworldRenderer(
    resolution = (600, 700),
    has_agent = false,
    obj_renderers = Dict(
        :agent => (d, s, o) -> o.name == :human ?
            HumanGraphic() : RobotGraphic(),
        # :key => (d, s, o) -> KeyGraphic(-0.1,-0.1,
        #     visible=!s[Compound(:has, [o])],
        #     # color=get_obj_color(s, o).name
        #     color=colordict[get_obj_color(s, o).name]
        # ),
        :key => (d, s, o) -> MultiGraphic(KeyGraphic(-0.1,-0.1,
            # color=get_obj_color(s, o).name
            color=colordict[get_obj_color(s, o).name]
        ),
        TextGraphic(
            string(o.name)[end:end], 0.3, 0.2, 0.5,
            color=:black, font=:bold
        )),
        :door => (d, s, o) -> LockedDoorGraphic(
            visible=s[Compound(:locked, [o])],
            color=colordict[get_obj_color(s, o).name]
        ),
        :gem => (d, s, o) -> GemGraphic(
            color=gem_colors[parse(Int, string(o.name)[end])]
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
        :tracked_types => Const[],
        :object_colors => [:black, :slategray]
    )
)

renderer_door = PDDLViz.GridworldRenderer(
    resolution = (600, 700),
    has_agent = false,
    obj_renderers = Dict(
        :agent => (d, s, o) -> o.name == :human ?
            HumanGraphic() : RobotGraphic(),
        # :key => (d, s, o) -> KeyGraphic(-0.1,-0.1,
        #     visible=!s[Compound(:has, [o])],
        #     # color=get_obj_color(s, o).name
        #     color=colordict[get_obj_color(s, o).name]
        # ),
        :key => (d, s, o) -> KeyGraphic(
            visible=!s[Compound(:has, [o])],
            # color=get_obj_color(s, o).name
            color=colordict[get_obj_color(s, o).name]
        ),
        :door => (d, s, o) -> MultiGraphic(LockedDoorGraphic(
            visible=s[Compound(:locked, [o])],
            color=colordict[get_obj_color(s, o).name]
        ),
        TextGraphic(
            string(o.name)[end:end], 0.3, 0.2, 0.5,
            color=:white, font=:bold
        )
        ),
        :gem => (d, s, o) -> GemGraphic(
            color=gem_colors[parse(Int, string(o.name)[end])]
        )
    ),
    obj_type_z_order = [:door, :key, :gem, :agent],
    show_inventory = true,
    inventory_fns = [
        (d, s, o) -> s[Compound(:has, [Const(:human), o])],
        (d, s, o) -> s[Compound(:has, [Const(:robot), o])]
    ],
    inventory_types = [:item, :item],
    inventory_labels = ["Human Inventory", "Robot Inventory"],
    trajectory_options = Dict(
        :tracked_objects => [Const(:human), Const(:robot)],
        :tracked_types => Const[],
        :object_colors => [:black, :slategray]
    )
)

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
