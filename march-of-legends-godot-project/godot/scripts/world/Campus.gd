extends Node2D

@onready var info_label: Label = %InfoLabel

var player_position := Vector2(640, 360)
var speed := 220.0

func _ready() -> void:
	_update_text()

func _process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player_position += direction * speed * delta
	$Player.position = player_position
	if Input.is_action_just_pressed("interact"):
		_update_text("Mascot says: Freshman, destiny smells faintly like valve oil.")
	if Input.is_action_just_pressed("ui_accept"):
		SceneRouter.goto("field_command")
	if Input.is_action_just_pressed("back"):
		SceneRouter.goto("main_menu")

func _update_text(override_text: String = "") -> void:
	if override_text != "":
		info_label.text = override_text
	else:
		info_label.text = "WASD/Arrows to move. E to interact. Enter to rehearse. Esc for menu."
