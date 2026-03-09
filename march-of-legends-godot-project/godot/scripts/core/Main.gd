extends Node

func _ready() -> void:
	# Bootstrap into the main menu.
	SceneRouter.goto("main_menu")
