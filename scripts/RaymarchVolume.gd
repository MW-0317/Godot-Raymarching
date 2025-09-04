@tool
extends MeshInstance3D
class_name RaymarchVolume

## Max number of steps a ray will travel
@export var max_steps: int
## The minimum step size allowed
@export var min_step_size: float
## The max distance a ray will travel
@export var max_distance: float

@export var panorama: PanoramaSkyMaterial

@export var light: Light3D
@export var fog_color: Color

var children: Array[Node]
var material: Material

func _ready():
    var arguments = {}
    for argument in OS.get_cmdline_args():
        if argument.contains("="):
            var key_value = argument.split("=")
            arguments[key_value[0].trim_prefix("--")] = key_value[1]
        else:
            # Options without an argument will be present in the dictionary,
            # with the value set to an empty string.
            arguments[argument.trim_prefix("--")] = ""

    children = get_children()
    material = mesh.surface_get_material(0)

func _process(_delta: float):
    material = mesh.surface_get_material(0)
    set_shader_parameters(material)
   
func set_shader_parameters(m: Material):
    m.set_shader_parameter("MAX_STEPS", max_steps)
    m.set_shader_parameter("MIN_STEP_SIZE", min_step_size)
    m.set_shader_parameter("MAX_DISTANCE", max_distance)

    m.set_shader_parameter("panorama", panorama.panorama)

    m.set_shader_parameter("light_color", light.light_color)
    m.set_shader_parameter("light_position", light.position)
    m.set_shader_parameter("fog_color", fog_color)

    for child in children:
        child.set_shader_parameters(m)