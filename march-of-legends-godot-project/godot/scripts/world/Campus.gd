extends Node2D

const CELL_SIZE := 32.0
const MOVE_CADENCE_SECONDS := 0.12
const INTERACT_RANGE_CELLS := 1
const FIELD_COMMAND_SCENE := "res://scenes/band/FieldCommand.tscn"
const SAVE_SLOT_NAME := "vertical_slice"
const DEFAULT_HINT := "WASD/Arrows move. E interacts near the Band Hall. F5 saves, F9 loads, Esc menu."
const BAND_HALL_HINT := "Press E to enter Band Hall rehearsal. F5 saves, F9 loads."
const SAVE_SUCCESS_HINT := "Progress saved to slot '%s'." % SAVE_SLOT_NAME
const LOAD_SUCCESS_HINT := "Progress loaded from slot '%s'." % SAVE_SLOT_NAME

@onready var player: ColorRect = $Player
@onready var band_hall_anchor: Marker2D = $BandHall/InteractAnchor
@onready var info_label: Label = %InfoLabel

var player_grid_position := Vector2i(20, 11)
var move_cooldown_remaining := 0.0
var is_band_hall_in_range := false

func _ready() -> void:
	if not GameState.state_changed.is_connected(_on_game_state_changed):
		GameState.state_changed.connect(_on_game_state_changed)
	_restore_from_state()
	_sync_player_position()
	_update_text(DEFAULT_HINT)
	_update_interaction_state()

func _process(delta: float) -> void:
	move_cooldown_remaining = max(move_cooldown_remaining - delta, 0.0)
	_attempt_grid_move()
	_attempt_interact()
	_handle_save_load_actions()
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
	GameState.set_flag("campus_player_grid_position", player_grid_position)
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

func _handle_save_load_actions() -> void:
	if Input.is_action_just_pressed("debug_save"):
		GameState.set_flag("campus_player_grid_position", player_grid_position)
		var save_error := GameState.save_to_slot(SAVE_SLOT_NAME)
		if save_error == OK:
			_update_text(SAVE_SUCCESS_HINT)
		else:
			_update_text("Save failed with error %d." % save_error)
	elif Input.is_action_just_pressed("debug_load"):
		var load_error := GameState.load_from_slot(SAVE_SLOT_NAME)
		if load_error != OK:
			_update_text("Load failed with error %d." % load_error)
			return
		var current_scene := get_tree().current_scene
		var current_scene_path := ""
		if current_scene != null:
			current_scene_path = current_scene.scene_file_path
		if GameState.get_current_scene_path() != "" and GameState.get_current_scene_path() != current_scene_path:
			SceneRouter.change_scene(GameState.get_current_scene_path())
			return
		_restore_from_state()
		_sync_player_position()
		_update_interaction_state()
		_update_text(LOAD_SUCCESS_HINT)

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

func _restore_from_state() -> void:
	var saved_position := GameState.flags.get("campus_player_grid_position", null)
	if typeof(saved_position) == TYPE_VECTOR2I:
		player_grid_position = saved_position

func _on_game_state_changed(changed_keys: Array[String]) -> void:
	if changed_keys.has("flags") or changed_keys.has("flags.campus_player_grid_position"):
		_restore_from_state()
		_sync_player_position()
		_update_interaction_state()

func _update_text(new_text: String) -> void:
	info_label.text = new_text
