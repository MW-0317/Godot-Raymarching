@tool
extends MeshInstance3D
class_name RaymarchVolume_legacy

@export var max_steps: int
@export var max_step_size: float
@export var max_distance: float

@export_range(0, 100000, 0.01, "exp") var gravity_constant: float

@export var panorama: PanoramaSkyMaterial
@export var light: Light3D
@export var fog_color: Color

@export var size: float = 1.0
@export var intensity: float = 1.0
@export var density_coeff: float = 1.0
@export var distance_power: float = 2.0
@export var offset: float = 1.0

@export var noise_3d: NoiseTexture3D

# @export var time = 0.0
# @export var cubemap: Cubemap

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

	max_step_size = float(arguments["max_step_size"])

func _process(_delta: float):
	var material = mesh.surface_get_material(0)
	material.set_shader_parameter("MAX_STEPS", max_steps)
	material.set_shader_parameter("MAX_STEP_SIZE", max_step_size)
	material.set_shader_parameter("MAX_DISTANCE", max_distance)

	material.set_shader_parameter("panorama", panorama.panorama)
	material.set_shader_parameter("noise_texture", noise_3d)
	material.set_shader_parameter("GRAVITY_CONSTANT", 1 / gravity_constant)

	# print(delta)
	# time += delta
	# var time = float(Time.get_ticks_msec()) / 1000
	# time = 100
	# time = 0
	# light.position = Vector3((2 + sin(3*time))*sin(time), 0, (2 + sin(3*time))*cos(time))
	# light.position = Vector3(0.0, 0.0, 0.0)
	material.set_shader_parameter("light_position", light.position)
	material.set_shader_parameter("light_color", light.light_color)
	material.set_shader_parameter("fog_color", fog_color)
	material.set_shader_parameter("SIZE", size)
	material.set_shader_parameter("INTENSITY", intensity)
	material.set_shader_parameter("DENSITY_COEFFICIENT", density_coeff)
	material.set_shader_parameter("DISTANCE_POWER", distance_power)
	material.set_shader_parameter("OFFSET", offset)
	
