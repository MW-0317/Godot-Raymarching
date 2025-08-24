@tool
extends MeshInstance3D
class_name RaymarchVolume

@export var max_steps: int
@export var max_step_size: float

func _process(delta: float):
	var material = mesh.surface_get_material(0)
	material.set_shader_parameter("MAX_STEPS", max_steps)
	material.set_shader_parameter("MAX_STEP_SIZE", max_step_size)
