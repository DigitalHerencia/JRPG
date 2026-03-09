extends Node

signal state_changed(changed_keys: Array[String])

const DEFAULT_PARTY := ["leo", "dr_major", "snare_kid"]
const SAVE_DIR := "user://saves"
const DEFAULT_SCENE_KEY := "main_menu"
const DEFAULT_SCENE_PATH := "res://scenes/ui/MainMenu.tscn"
const SERIALIZED_TYPE_KEY := "__type"
const SERIALIZED_VECTOR2I := "Vector2i"

var current_scene_key: String = DEFAULT_SCENE_KEY
var current_scene_path: String = DEFAULT_SCENE_PATH
var player_name: String = "Leo Crescendo"
var party: Array[String] = DEFAULT_PARTY.duplicate()
var flags: Dictionary = {}
var stats: Dictionary = _default_stats()

func reset_to_defaults() -> void:
	current_scene_key = DEFAULT_SCENE_KEY
	current_scene_path = DEFAULT_SCENE_PATH
	player_name = "Leo Crescendo"
	party = DEFAULT_PARTY.duplicate()
	flags = {}
	stats = _default_stats()
	_emit_state_changed([
		"current_scene_key",
		"current_scene_path",
		"player_name",
		"party",
		"flags",
		"stats"
	])

func set_flag(flag_name: String, value := true) -> void:
	var previous_value: Variant = flags.get(flag_name, null)
	if previous_value == value and flags.has(flag_name):
		return
	flags[flag_name] = value
	_emit_state_changed(["flags.%s" % flag_name])

func has_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

func set_stat(stat_name: String, value: Variant) -> void:
	var had_stat := stats.has(stat_name)
	var previous_value: Variant = stats.get(stat_name, null)
	if had_stat and previous_value == value:
		return
	stats[stat_name] = value
	_emit_state_changed(["stats.%s" % stat_name])

func add_stat(stat_name: String, delta: float) -> void:
	var previous_value: Variant = stats.get(stat_name, 0.0)
	if not _is_number(previous_value):
		push_error("Stat '%s' is not numeric." % stat_name)
		return
	var next_value: float = float(previous_value) + delta
	set_stat(stat_name, next_value)

func add_hype(amount: int) -> void:
	add_stat("hype", amount)

func advance_week() -> void:
	add_stat("semester_week", 1)

func set_current_scene_by_key(scene_key: String, scene_path: String = "") -> void:
	var changed_keys: Array[String] = []
	if current_scene_key != scene_key:
		current_scene_key = scene_key
		changed_keys.append("current_scene_key")
	if scene_path != "" and current_scene_path != scene_path:
		current_scene_path = scene_path
		changed_keys.append("current_scene_path")
	if not changed_keys.is_empty():
		_emit_state_changed(changed_keys)

func set_current_scene_path(scene_path: String, scene_key: String = "") -> void:
	var changed_keys: Array[String] = []
	if current_scene_path != scene_path:
		current_scene_path = scene_path
		changed_keys.append("current_scene_path")
	if scene_key != "" and current_scene_key != scene_key:
		current_scene_key = scene_key
		changed_keys.append("current_scene_key")
	if not changed_keys.is_empty():
		_emit_state_changed(changed_keys)

func get_current_scene_key() -> String:
	return current_scene_key

func get_current_scene_path() -> String:
	return current_scene_path

func to_dict() -> Dictionary:
	return {
		"current_scene_key": current_scene_key,
		"current_scene_path": current_scene_path,
		"player_name": player_name,
		"party": party.duplicate(),
		"flags": _serialize_value(flags),
		"stats": _serialize_value(stats)
	}

func from_dict(data: Dictionary) -> void:
	if not _validate_state_dict(data):
		push_error("Invalid game state schema.")
		return

	current_scene_key = data["current_scene_key"]
	current_scene_path = data["current_scene_path"]
	player_name = data["player_name"]
	party = (data["party"] as Array).duplicate()
	flags = _deserialize_value((data["flags"] as Dictionary).duplicate(true)) as Dictionary
	stats = _deserialize_value((data["stats"] as Dictionary).duplicate(true)) as Dictionary
	_emit_state_changed([
		"current_scene_key",
		"current_scene_path",
		"player_name",
		"party",
		"flags",
		"stats"
	])

func save_to_slot(slot_name: String = "save_01") -> Error:
	var save_path := _slot_path(slot_name)
	var dir_error := DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	if dir_error != OK and dir_error != ERR_ALREADY_EXISTS:
		return dir_error

	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()

	file.store_string(JSON.stringify(to_dict(), "\t"))
	return OK

func load_from_slot(slot_name: String = "save_01") -> Error:
	var save_path := _slot_path(slot_name)
	if not FileAccess.file_exists(save_path):
		return ERR_FILE_NOT_FOUND

	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return ERR_PARSE_ERROR

	var parsed_dict := parsed as Dictionary
	if not _validate_state_dict(parsed_dict):
		return ERR_INVALID_DATA

	from_dict(parsed_dict)
	return OK

func _slot_path(slot_name: String) -> String:
	return "%s/%s.json" % [SAVE_DIR, slot_name]

func _emit_state_changed(changed_keys: Array[String]) -> void:
	if changed_keys.is_empty():
		return
	state_changed.emit(changed_keys)

func _is_number(value: Variant) -> bool:
	var value_type := typeof(value)
	return value_type == TYPE_INT or value_type == TYPE_FLOAT

func _default_stats() -> Dictionary:
	return {
		"hype": 0,
		"discipline": 1,
		"improv": 0,
		"semester_week": 1
	}

func _serialize_value(value: Variant) -> Variant:
	match typeof(value):
		TYPE_DICTIONARY:
			var serialized_dict := {}
			for key in value.keys():
				serialized_dict[key] = _serialize_value(value[key])
			return serialized_dict
		TYPE_ARRAY:
			var serialized_array: Array = []
			for item in value:
				serialized_array.append(_serialize_value(item))
			return serialized_array
		TYPE_VECTOR2I:
			var point := value as Vector2i
			return {
				SERIALIZED_TYPE_KEY: SERIALIZED_VECTOR2I,
				"x": point.x,
				"y": point.y
			}
		_:
			return value

func _deserialize_value(value: Variant) -> Variant:
	match typeof(value):
		TYPE_DICTIONARY:
			var dict_value := value as Dictionary
			if dict_value.get(SERIALIZED_TYPE_KEY, "") == SERIALIZED_VECTOR2I:
				return Vector2i(int(dict_value.get("x", 0)), int(dict_value.get("y", 0)))
			var deserialized_dict := {}
			for key in dict_value.keys():
				deserialized_dict[key] = _deserialize_value(dict_value[key])
			return deserialized_dict
		TYPE_ARRAY:
			var deserialized_array: Array = []
			for item in value:
				deserialized_array.append(_deserialize_value(item))
			return deserialized_array
		_:
			return value

func _validate_state_dict(data: Dictionary) -> bool:
	var required_keys := [
		"current_scene_key",
		"current_scene_path",
		"player_name",
		"party",
		"flags",
		"stats"
	]
	for key in required_keys:
		if not data.has(key):
			return false

	if typeof(data["current_scene_key"]) != TYPE_STRING:
		return false
	if typeof(data["current_scene_path"]) != TYPE_STRING:
		return false
	if typeof(data["player_name"]) != TYPE_STRING:
		return false
	if typeof(data["party"]) != TYPE_ARRAY:
		return false
	if typeof(data["flags"]) != TYPE_DICTIONARY:
		return false
	if typeof(data["stats"]) != TYPE_DICTIONARY:
		return false

	for member in data["party"]:
		if typeof(member) != TYPE_STRING:
			return false

	return true
