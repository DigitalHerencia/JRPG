extends Node

const DOMAIN_CHARACTERS := "characters"
const DOMAIN_FORMATIONS := "formations"
const DOMAIN_SKILLS := "skills"
const DOMAIN_LEVELS := "levels"

const CONTENT_ROOT := "res://content"
const LEGACY_CONTENT_ROOT := "res://data/json"

const EMPTY_CONTENT: Dictionary = {}

var characters: Dictionary = {}
var formations: Dictionary = {}
var skills: Dictionary = {}
var levels: Dictionary = {}

var _raw_cache: Dictionary = {}

func _ready() -> void:
	load_characters()
	load_formations()
	load_skills()
	load_levels()

func load_characters() -> void:
	characters = _load_domain(DOMAIN_CHARACTERS, _validate_character)

func load_formations() -> void:
	formations = _load_domain(DOMAIN_FORMATIONS, _validate_formation)

func load_skills() -> void:
	skills = _load_domain(DOMAIN_SKILLS, _validate_skill)

func load_levels() -> void:
	levels = _load_domain(DOMAIN_LEVELS, _validate_level)

func get_character(id: String) -> Dictionary:
	return _get_or_warn(characters, id, DOMAIN_CHARACTERS)

func get_skill(id: String) -> Dictionary:
	return _get_or_warn(skills, id, DOMAIN_SKILLS)

func get_level(id: String) -> Dictionary:
	return _get_or_warn(levels, id, DOMAIN_LEVELS)

func get_formation_by_id(id: String) -> Dictionary:
	return _get_or_warn(formations, id, DOMAIN_FORMATIONS)

func get_formation(id: String) -> Dictionary:
	return get_formation_by_id(id)

func get_formations() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for formation in formations.values():
		if typeof(formation) == TYPE_DICTIONARY:
			out.append(formation)
	return out

func find_formation_by_pattern(pattern: Array[Vector2i]) -> Dictionary:
	if pattern.is_empty():
		_warn("pattern_lookup_empty", DOMAIN_FORMATIONS, {"requested_pattern": []})
		return EMPTY_CONTENT

	var normalized_pattern := _normalize_pattern(pattern)
	for formation in formations.values():
		if typeof(formation) != TYPE_DICTIONARY:
			continue
		var formation_pattern: Array[Vector2i] = _parse_pattern(formation.get("pattern", []))
		if formation_pattern.is_empty():
			continue
		if _normalize_pattern(formation_pattern) == normalized_pattern:
			return formation

	_warn("pattern_lookup_miss", DOMAIN_FORMATIONS, {"requested_pattern": _pattern_to_json(normalized_pattern)})
	return EMPTY_CONTENT

func _load_domain(domain: String, validator: Callable) -> Dictionary:
	var path := _resolve_domain_path(domain)
	if path.is_empty():
		_error("content_path_missing", domain, {"preferred": "%s/%s.json" % [CONTENT_ROOT, domain], "legacy": "%s/%s.json" % [LEGACY_CONTENT_ROOT, domain]})
		return {}

	if _raw_cache.has(path):
		return _build_domain_index(_raw_cache[path], domain, validator)

	var raw := FileAccess.get_file_as_string(path)
	if raw.is_empty():
		_error("content_file_empty", domain, {"path": path})
		return {}

	var parsed = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_ARRAY:
		_error("content_schema_root_invalid", domain, {"path": path, "expected": "Array", "actual_type": typeof(parsed)})
		return {}

	_raw_cache[path] = parsed
	return _build_domain_index(parsed, domain, validator)

func _build_domain_index(entries: Array, domain: String, validator: Callable) -> Dictionary:
	var out := {}
	for i in entries.size():
		var item = entries[i]
		if typeof(item) != TYPE_DICTIONARY:
			_error("entry_not_dictionary", domain, {"index": i, "actual_type": typeof(item)})
			continue
		var record: Dictionary = item
		if not validator.call(record, i):
			continue
		var record_id := str(record["id"])
		if out.has(record_id):
			_error("duplicate_id", domain, {"id": record_id, "index": i})
			continue
		out[record_id] = record
	return out

func _resolve_domain_path(domain: String) -> String:
	var preferred := "%s/%s.json" % [CONTENT_ROOT, domain]
	if FileAccess.file_exists(preferred):
		return preferred

	var legacy := "%s/%s.json" % [LEGACY_CONTENT_ROOT, domain]
	if FileAccess.file_exists(legacy):
		_warn("using_legacy_alias", domain, {"legacy_path": legacy, "preferred_path": preferred})
		return legacy

	return ""

func _get_or_warn(data: Dictionary, id: String, domain: String) -> Dictionary:
	if data.has(id):
		return data[id]
	_warn("missing_id", domain, {"id": id})
	return EMPTY_CONTENT

func _validate_character(item: Dictionary, index: int) -> bool:
	return _validate_required_string_fields(item, index, DOMAIN_CHARACTERS, ["id", "name", "section", "instrument", "role", "arc"])

func _validate_skill(item: Dictionary, index: int) -> bool:
	if not _validate_required_string_fields(item, index, DOMAIN_SKILLS, ["id", "character_id", "branch", "effect"]):
		return false
	if not item.has("tier") or typeof(item["tier"]) != TYPE_INT:
		_error("field_type_invalid", DOMAIN_SKILLS, {"index": index, "field": "tier", "expected": "int"})
		return false
	return true

func _validate_level(item: Dictionary, index: int) -> bool:
	if not _validate_required_string_fields(item, index, DOMAIN_LEVELS, ["id", "name", "type", "boss"]):
		return false
	if item.has("rhythm") and not _validate_rhythm_level(item["rhythm"], index):
		return false
	return true

func _validate_formation(item: Dictionary, index: int) -> bool:
	if not _validate_required_string_fields(item, index, DOMAIN_FORMATIONS, ["id", "name", "effect", "description"]):
		return false
	if not item.has("pattern"):
		_error("field_missing", DOMAIN_FORMATIONS, {"index": index, "field": "pattern"})
		return false
	var parsed_pattern: Array[Vector2i] = _parse_pattern(item["pattern"])
	if parsed_pattern.is_empty():
		_error("field_invalid", DOMAIN_FORMATIONS, {"index": index, "field": "pattern", "reason": "must be non-empty array of {x:int, y:int}"})
		return false
	item["pattern"] = _pattern_to_json(parsed_pattern)
	return true

func _validate_required_string_fields(item: Dictionary, index: int, domain: String, fields: Array[String]) -> bool:
	for field_name in fields:
		if not item.has(field_name):
			_error("field_missing", domain, {"index": index, "field": field_name})
			return false
		if typeof(item[field_name]) != TYPE_STRING or str(item[field_name]).strip_edges().is_empty():
			_error("field_type_invalid", domain, {"index": index, "field": field_name, "expected": "non-empty string"})
			return false
	return true

func _parse_pattern(raw_pattern: Variant) -> Array[Vector2i]:
	if typeof(raw_pattern) != TYPE_ARRAY:
		return []
	var pattern: Array[Vector2i] = []
	for point in raw_pattern:
		if typeof(point) != TYPE_DICTIONARY:
			return []
		if not point.has("x") or not point.has("y"):
			return []
		if typeof(point["x"]) != TYPE_INT or typeof(point["y"]) != TYPE_INT:
			return []
		pattern.append(Vector2i(point["x"], point["y"]))
	return pattern

func _normalize_pattern(pattern: Array[Vector2i]) -> Array[Vector2i]:
	if pattern.is_empty():
		return []
	var sorted := pattern.duplicate()
	sorted.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		if a.x == b.x:
			return a.y < b.y
		return a.x < b.x
	)
	var anchor := sorted[0]
	var normalized: Array[Vector2i] = []
	for point in sorted:
		normalized.append(point - anchor)
	return normalized

func _pattern_to_json(pattern: Array[Vector2i]) -> Array[Dictionary]:
	var serialized: Array[Dictionary] = []
	for point in pattern:
		serialized.append({"x": point.x, "y": point.y})
	return serialized

func _validate_rhythm_level(raw_rhythm: Variant, index: int) -> bool:
	if typeof(raw_rhythm) != TYPE_DICTIONARY:
		_error("field_type_invalid", DOMAIN_LEVELS, {"index": index, "field": "rhythm", "expected": "Dictionary"})
		return false

	var rhythm := raw_rhythm as Dictionary
	var number_fields := ["approach_time", "miss_window", "perfect_window", "good_window"]
	if not rhythm.has("lanes") or typeof(rhythm["lanes"]) != TYPE_INT or int(rhythm["lanes"]) <= 0:
		_error("field_type_invalid", DOMAIN_LEVELS, {"index": index, "field": "rhythm.lanes", "expected": "positive int"})
		return false
	for field_name in number_fields:
		if not rhythm.has(field_name) or not _is_number(rhythm[field_name]):
			_error("field_type_invalid", DOMAIN_LEVELS, {"index": index, "field": "rhythm.%s" % field_name, "expected": "number"})
			return false
	if not rhythm.has("chart_notes") or typeof(rhythm["chart_notes"]) != TYPE_ARRAY:
		_error("field_type_invalid", DOMAIN_LEVELS, {"index": index, "field": "rhythm.chart_notes", "expected": "Array"})
		return false

	for note_index in rhythm["chart_notes"].size():
		var note = rhythm["chart_notes"][note_index]
		if typeof(note) != TYPE_DICTIONARY:
			_error("field_type_invalid", DOMAIN_LEVELS, {"index": index, "field": "rhythm.chart_notes[%d]" % note_index, "expected": "Dictionary"})
			return false
		if not note.has("lane") or typeof(note["lane"]) != TYPE_INT:
			_error("field_type_invalid", DOMAIN_LEVELS, {"index": index, "field": "rhythm.chart_notes[%d].lane" % note_index, "expected": "int"})
			return false
		if int(note["lane"]) < 0 or int(note["lane"]) >= int(rhythm["lanes"]):
			_error("field_invalid", DOMAIN_LEVELS, {"index": index, "field": "rhythm.chart_notes[%d].lane" % note_index, "reason": "out of range"})
			return false
		if not note.has("hit_time") or not _is_number(note["hit_time"]):
			_error("field_type_invalid", DOMAIN_LEVELS, {"index": index, "field": "rhythm.chart_notes[%d].hit_time" % note_index, "expected": "number"})
			return false
	return true

func _is_number(value: Variant) -> bool:
	var value_type := typeof(value)
	return value_type == TYPE_INT or value_type == TYPE_FLOAT

func _warn(code: String, domain: String, context: Dictionary = {}) -> void:
	push_warning("ContentDB warning [%s/%s]: %s" % [domain, code, JSON.stringify(context)])

func _error(code: String, domain: String, context: Dictionary = {}) -> void:
	push_error("ContentDB error [%s/%s]: %s" % [domain, code, JSON.stringify(context)])
