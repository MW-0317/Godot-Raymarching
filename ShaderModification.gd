class_name ShaderModification

extends Node

@export var max_steps: int
@export var max_step_size: float
@export var material: ShaderMaterial
@export var main_camera: Camera3D
@export var color_rect: Node
@export var slider: Slider

var modified_time = -1
var enabled = true

var time_ref = [0.0]
var distance_ref = [1.0]
var moving = [false]
var opacity = [1.0]

func _ready():
	modified_time = FileAccess.get_modified_time("./shaders/raymarch.gdshader")

func _process(delta: float):
	# var current_time = FileAccess.get_modified_time("./shaders/raymarch.gdshader")
	# if current_time != modified_time:
	#     modified_time = current_time
	#     print("File changed!")
		#get_tree().change_scene_to_file("res://main.tscn")

	# var t = Time.get_ticks_msec() as float / 1000
	if (moving[0]):
		time_ref[0] += delta
	
	if (time_ref[0] >= 2 * PI):
		time_ref[0] = 0

	var distance = distance_ref[0]
	var time = time_ref[0]

	var forward = main_camera.get_global_transform().basis.z
	forward += Vector3(1.0, 1.0, 1.0)
	forward /= Vector3(2.0, 2.0, 2.0)

	ImGui.Begin("Raymarch")

	main_camera.position = Vector3(distance*sin(time), 0, distance*cos(time))
	main_camera.look_at(Vector3(0,0,0))

	var VIEW_MATRIX = main_camera.get_camera_transform()
	var VIEW_MATRIX_PROJECTION = Projection(VIEW_MATRIX)
	# var INVERSE_VIEW_MATRIX = VIEW_MATRIX_PROJECTION.inverse()
	var INVERSE_VIEW_MATRIX = Projection(main_camera.global_transform.affine_inverse())
	var CAMERA_PROJECTION = main_camera.get_camera_projection()
	CAMERA_PROJECTION = Projection.create_depth_correction(true) * CAMERA_PROJECTION
	var INVERSE_CAMERA_PROJECTION = CAMERA_PROJECTION.inverse()

	ImGui.SliderFloat("Distance", distance_ref, 1.0, 10.0)
	ImGui.Checkbox("Spinning", moving)
	ImGui.SliderFloat("Time", time_ref, 0.0, 2*PI)
	# ImGui.InputFloat("Time", time_ref)
	ImGui.SliderFloat("Opacity", opacity, 0.0, 1.0)
	ImGui.Text(str(forward))
	ImGui.Text(str(INVERSE_VIEW_MATRIX))
	ImGui.Text(str(INVERSE_CAMERA_PROJECTION))

	ImGui.Text("VIEW")
	if (ImGui.BeginTable("VIEW", 4)):
		for i in range(0, 4):
			ImGui.TableNextRow()
			for j in range(0, 4):
				ImGui.TableSetColumnIndex(j)
				# main_camera.get_camera_transform()[4 * i + j]
				ImGui.Text("%f"% VIEW_MATRIX_PROJECTION[i][j])
		ImGui.EndTable()

	ImGui.Text("INVERSE VIEW")
	if (ImGui.BeginTable("INVERSE VIEW", 4)):
		for i in range(0, 4):
			ImGui.TableNextRow()
			for j in range(0, 4):
				ImGui.TableSetColumnIndex(j)
				# main_camera.get_camera_transform()[4 * i + j]
				ImGui.Text("%f"% INVERSE_VIEW_MATRIX[i][j])
		ImGui.EndTable()


	ImGui.Text("PROJECTION")
	if (ImGui.BeginTable("PROJECTION", 4)):
		for i in range(0, 4):
			ImGui.TableNextRow()
			for j in range(0, 4):
				ImGui.TableSetColumnIndex(j)
				# main_camera.get_camera_transform()[4 * i + j]
				ImGui.Text("%f"% CAMERA_PROJECTION[i][j])
		ImGui.EndTable()

	ImGui.Text("INVERSE PROJECTION")
	if (ImGui.BeginTable("INVERSE PROJECTION", 4)):
		for i in range(0, 4):
			ImGui.TableNextRow()
			for j in range(0, 4):
				ImGui.TableSetColumnIndex(j)
				# main_camera.get_camera_transform()[4 * i + j]
				ImGui.Text("%f"% INVERSE_CAMERA_PROJECTION[i][j])
		ImGui.EndTable()

	# var s = "%f, %f, %f"% [test.x, test.y, test.z]
	# ImGui.Text(s)

	ImGui.ColorButton("Forward Color", Color(forward.x, forward.y, forward.z))
	ImGui.End()

	material.set_shader_parameter("MAX_STEPS", max_steps)

	material.set_shader_parameter("MAX_STEP_SIZE", max_step_size)

	material.set_shader_parameter("CAMERA_POSITION", main_camera.position)

	material.set_shader_parameter("INVERSE_CAMERA_PROJECTION", INVERSE_CAMERA_PROJECTION)

	material.set_shader_parameter("INVERSE_VIEW_MATRIX", VIEW_MATRIX_PROJECTION)

	material.set_shader_parameter("test_distance", distance_ref[0])

	material.set_shader_parameter("alpha", opacity[0])

func _input(event):
	if event.is_action_pressed("SDF"):
		enabled = !enabled
		# canvas.set_process(enabled)
		color_rect.visible = enabled
