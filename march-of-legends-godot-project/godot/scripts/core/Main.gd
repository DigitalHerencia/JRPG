extends Node

func _ready() -> void:
	# Bootstrap into the main menu.
	SceneRouter.change_scene_key("main_menu")
