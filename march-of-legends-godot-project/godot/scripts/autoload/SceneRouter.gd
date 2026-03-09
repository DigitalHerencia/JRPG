extends Node

signal route_changed(route_key: String)
signal scene_change_started(previous_scene_path: String, next_scene_path: String)
signal scene_change_finished(previous_scene_path: String, next_scene_path: String)

const FADE_DURATION := 0.2
const FADE_COLOR := Color(0, 0, 0, 1)

var routes := {
	"main_menu": "res://scenes/ui/MainMenu.tscn",
	"campus": "res://scenes/world/Campus.tscn",
	"field_command": "res://scenes/band/FieldCommand.tscn",
	"rhythm_battle": "res://scenes/battle/RhythmBattle.tscn"
}

var _transition_locked := false
var _fade_layer: CanvasLayer
var _fade_rect: ColorRect

func _ready() -> void:
	_build_fade_layer()

func change_scene(path: String) -> void:
	if _transition_locked:
		push_warning("Scene transition is already in progress.")
		return
	if path == "":
		push_error("Scene path cannot be empty.")
		return
	if not ResourceLoader.exists(path):
		push_error("Scene path does not exist: %s" % path)
		return

	_transition_locked = true
	var previous_path := _current_scene_path()
	scene_change_started.emit(previous_path, path)
	await _fade_to(1.0)

	var result := get_tree().change_scene_to_file(path)
	if result != OK:
		push_error("Failed to change scene to %s (error %d)" % [path, result])
		await _fade_to(0.0)
		_transition_locked = false
		return

	await get_tree().process_frame
	_update_game_state(path)
	await _fade_to(0.0)
	scene_change_finished.emit(previous_path, path)
	_transition_locked = false

func change_scene_key(route_key: String) -> void:
	if not routes.has(route_key):
		push_error("Unknown route: %s" % route_key)
		return
	await change_scene(routes[route_key])

func goto(route_key: String) -> void:
	# Backward-compatible alias.
	await change_scene_key(route_key)

func push_scene(path: String) -> Node:
	if path == "":
		push_error("Scene path cannot be empty.")
		return null
	var packed := load(path)
	if packed == null or not (packed is PackedScene):
		push_error("Unable to load scene for push_scene: %s" % path)
		return null

	var instance := (packed as PackedScene).instantiate()
	var host := get_tree().current_scene
	if host == null:
		host = get_tree().root
	host.add_child(instance)
	return instance

func _build_fade_layer() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100
	_fade_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	_fade_layer.name = "SceneRouterFadeLayer"

	_fade_rect = ColorRect.new()
	_fade_rect.name = "FadeRect"
	_fade_rect.color = FADE_COLOR
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.modulate.a = 0.0
	_fade_layer.add_child(_fade_rect)

	if _fade_layer.get_parent() == null:
		get_tree().root.add_child(_fade_layer)

func _fade_to(alpha: float) -> void:
	if _fade_rect == null:
		return
	var tween := create_tween()
	tween.tween_property(_fade_rect, "modulate:a", alpha, FADE_DURATION)
	await tween.finished

func _current_scene_path() -> String:
	var current := get_tree().current_scene
	if current == null:
		return ""
	return current.scene_file_path

func _update_game_state(scene_path: String) -> void:
	var route_key := _find_key_for_path(scene_path)
	if GameState.has_method("set_current_scene_path"):
		GameState.set_current_scene_path(scene_path, route_key)
	else:
		GameState.current_scene_path = scene_path
		GameState.current_scene_key = route_key
	if route_key != "":
		route_changed.emit(route_key)

func _find_key_for_path(scene_path: String) -> String:
	for route_key in routes.keys():
		if routes[route_key] == scene_path:
			return route_key
	return ""
