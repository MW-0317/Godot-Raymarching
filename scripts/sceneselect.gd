extends VBoxContainer
class_name SceneSelect

# const SceneButton = preload("res://scripts/SceneButton.gd")

func _init():
    var scenes = ResourceLoader.list_directory("res://scenes")

    for scene in scenes:
        var scene_button = SceneButton.new()
        scene_button.scene_directory = "res://scenes"
        scene_button.text = scene
        self.add_child(scene_button)