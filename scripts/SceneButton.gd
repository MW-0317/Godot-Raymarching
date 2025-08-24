extends Button
class_name SceneButton

var scene_directory

func _init():
    self.pressed.connect(_button_pressed)

func _button_pressed():
    get_tree().change_scene_to_file(scene_directory + "/" + text)