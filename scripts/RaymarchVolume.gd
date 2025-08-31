@tool
extends MeshInstance3D
class_name RaymarchVolume

@export var max_steps: int
@export var max_step_size: float
@export var max_distance: float

@export_range(0, 100000, 0.01, "exp") var gravity_constant: float

@export var panorama: PanoramaSkyMaterial
@export var light: Light3D

# @export var time = 0.0
# @export var cubemap: Cubemap

func _process(delta: float):
    var material = mesh.surface_get_material(0)
    material.set_shader_parameter("MAX_STEPS", max_steps)
    material.set_shader_parameter("MAX_STEP_SIZE", max_step_size)
    material.set_shader_parameter("MAX_DISTANCE", max_distance)

    material.set_shader_parameter("panorama", panorama.panorama)
    material.set_shader_parameter("GRAVITY_CONSTANT", 1 / gravity_constant)

    # print(delta)
    # time += delta
    var time = float(Time.get_ticks_msec()) / 1000
    # time = 100
    light.position = Vector3((2 + sin(3*time))*sin(time), 0, (2 + sin(3*time))*cos(time))
    material.set_shader_parameter("light_position", light.position)
    material.set_shader_parameter("light_color", light.light_color)
    
