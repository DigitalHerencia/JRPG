extends Control

@onready var start_button: Button = %StartButton
@onready var field_button: Button = %FieldButton
@onready var rhythm_button: Button = %RhythmButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	field_button.pressed.connect(func(): SceneRouter.change_scene_key("field_command"))
	rhythm_button.pressed.connect(func(): SceneRouter.change_scene_key("rhythm_battle"))
	quit_button.pressed.connect(func(): get_tree().quit())

func _on_start_pressed() -> void:
	SceneRouter.change_scene_key("campus")
