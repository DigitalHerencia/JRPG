extends Node

var characters: Dictionary = {}
var formations: Dictionary = {}
var skills: Dictionary = {}
var levels: Dictionary = {}

func _ready() -> void:
	characters = _load_json_as_dict("res://data/json/characters.json", "id")
	formations = _load_json_as_dict("res://data/json/formations.json", "id")
	skills = _load_json_as_dict("res://data/json/skills.json", "id")
	levels = _load_json_as_dict("res://data/json/levels.json", "id")

func get_character(id: String) -> Dictionary:
	return characters.get(id, {})

func get_formation(id: String) -> Dictionary:
	return formations.get(id, {})

func _load_json_as_dict(path: String, key_field: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var raw := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_ARRAY:
		return {}
	var out := {}
	for item in parsed:
		if typeof(item) == TYPE_DICTIONARY and item.has(key_field):
			out[item[key_field]] = item
	return out
