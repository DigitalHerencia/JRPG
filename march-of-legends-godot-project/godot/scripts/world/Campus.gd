extends Node2D

const CELL_SIZE := 32.0
const MOVE_CADENCE_SECONDS := 0.12
const INTERACT_RANGE_CELLS := 1
const FIELD_COMMAND_SCENE := "res://scenes/band/FieldCommand.tscn"
const DEFAULT_HINT := "WASD/Arrows to move. E to interact near the band hall. Esc for menu."
const BAND_HALL_HINT := "Press E to enter Band Hall rehearsal."

@onready var player: ColorRect = $Player
@onready var band_hall_anchor: Marker2D = $BandHall/InteractAnchor
@onready var info_label: Label = %InfoLabel

var player_grid_position := Vector2i(20, 11)
var move_cooldown_remaining := 0.0
var is_band_hall_in_range := false

func _ready() -> void:
	_sync_player_position()
	_update_text(DEFAULT_HINT)
	_update_interaction_state()

func _process(delta: float) -> void:
	move_cooldown_remaining = max(move_cooldown_remaining - delta, 0.0)
	_attempt_grid_move()
	_attempt_interact()
	if Input.is_action_just_pressed("back"):
		SceneRouter.change_scene_key("main_menu")

func _attempt_grid_move() -> void:
	if move_cooldown_remaining > 0.0:
		return

	var move_direction := Vector2i.ZERO
	if Input.is_action_pressed("move_left"):
		move_direction = Vector2i.LEFT
	elif Input.is_action_pressed("move_right"):
		move_direction = Vector2i.RIGHT
	elif Input.is_action_pressed("move_up"):
		move_direction = Vector2i.UP
	elif Input.is_action_pressed("move_down"):
		move_direction = Vector2i.DOWN

	if move_direction == Vector2i.ZERO:
		return

	player_grid_position += move_direction
	move_cooldown_remaining = MOVE_CADENCE_SECONDS
	_sync_player_position()
	_update_interaction_state()

func _sync_player_position() -> void:
	player.position = Vector2(player_grid_position) * CELL_SIZE

func _attempt_interact() -> void:
	if not Input.is_action_just_pressed("interact"):
		return

	if is_band_hall_in_range:
		SceneRouter.change_scene(FIELD_COMMAND_SCENE)
		return

	_update_text(DEFAULT_HINT)

func _update_interaction_state() -> void:
	var band_hall_grid_position := Vector2i(band_hall_anchor.global_position / CELL_SIZE)
	var distance := player_grid_position - band_hall_grid_position
	var in_range := abs(distance.x) <= INTERACT_RANGE_CELLS and abs(distance.y) <= INTERACT_RANGE_CELLS

	if in_range == is_band_hall_in_range:
		return

	is_band_hall_in_range = in_range
	if is_band_hall_in_range:
		_update_text(BAND_HALL_HINT)
	else:
		_update_text(DEFAULT_HINT)

func _update_text(new_text: String) -> void:
	info_label.text = new_text
