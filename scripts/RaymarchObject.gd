@tool
extends Node3D
class_name RaymarchObject

@export var noise_texture: NoiseTexture3D

func set_shader_parameters(m: Material):
    m.set_shader_parameter("noise_texture", noise_texture)