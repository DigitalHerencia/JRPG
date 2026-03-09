extends Control

@onready var new_game_button: Button = %NewGameButton
@onready var exit_button: Button = %ExitButton

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	new_game_button.grab_focus()

func _on_new_game_pressed() -> void:
	SceneRouter.goto("campus")

func _on_exit_pressed() -> void:
	get_tree().quit()
