extends Node2D

const CELL_SIZE := 32
const ALLOW_ROTATION_MATCH := true

@onready var info_label: Label = %InfoLabel
@onready var grid: ColorRect = %Grid
@onready var submit_button: Button = %SubmitButton
@onready var cancel_button: Button = %CancelButton

var selected_points: Array[Vector2i] = []

func _ready() -> void:
	submit_button.pressed.connect(_on_submit_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	_refresh_label()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos := grid.get_local_mouse_position()
		if Rect2(Vector2.ZERO, grid.size).has_point(local_pos):
			var cell := Vector2i(floor(local_pos.x / CELL_SIZE), floor(local_pos.y / CELL_SIZE))
			if selected_points.has(cell):
				info_label.text = "Cell already selected. Submit or choose another cell."
			else:
				selected_points.append(cell)
				queue_redraw()
				_refresh_label()

	if event.is_action_pressed("ui_accept"):
		_on_submit_pressed()
	elif event.is_action_pressed("back"):
		_on_cancel_pressed()

func _draw() -> void:
	for point in selected_points:
		draw_rect(Rect2(point * CELL_SIZE, Vector2(CELL_SIZE, CELL_SIZE)), Color(0.96, 0.62, 0.15, 0.65), true)

func _on_submit_pressed() -> void:
	if selected_points.is_empty():
		info_label.text = "Select at least one grid cell before submitting."
		return

	var validation := _validate_selected_formation()
	if not validation["is_valid"]:
		info_label.text = "Invalid formation: %s" % validation["message"]
		return

	var selected_snapshot: Array[Vector2i] = selected_points.duplicate()
	GameState.set_flag("field_command_selection", {
		"formation_id": validation["formation_id"],
		"formation_name": validation["formation_name"],
		"selected_points": selected_snapshot,
		"normalized_cell_set": validation["normalized_cell_set"],
		"normalized_sequence": validation["normalized_sequence"]
	})

	info_label.text = "Formation locked: %s" % validation["formation_name"]
	SceneRouter.change_scene_key("rhythm_battle")

func _on_cancel_pressed() -> void:
	SceneRouter.change_scene_key("campus")

func _validate_selected_formation() -> Dictionary:
	var selected_set_key := _canonicalize_point_set(selected_points, ALLOW_ROTATION_MATCH)
	var selected_sequence_key := _canonicalize_sequence(selected_points, ALLOW_ROTATION_MATCH)

	for formation_record in ContentDB.get_formations():
		var formation_id := str(formation_record.get("id", ""))
		if formation_id == "":
			continue

		var template_points := _points_from_pattern(formation_record.get("pattern", []))
		if template_points.is_empty():
			continue
		var template_set_key := _canonicalize_point_set(template_points, ALLOW_ROTATION_MATCH)
		if selected_set_key != template_set_key:
			continue

		return {
			"is_valid": true,
			"formation_id": formation_id,
			"formation_name": formation_record.get("name", formation_id),
			"normalized_cell_set": selected_set_key,
			"normalized_sequence": selected_sequence_key,
			"message": "ok"
		}

	return {
		"is_valid": false,
		"message": "pattern does not match any known formation"
	}

func _points_from_pattern(raw_pattern: Variant) -> Array[Vector2i]:
	if typeof(raw_pattern) != TYPE_ARRAY:
		return []
	var points: Array[Vector2i] = []
	for point in raw_pattern:
		if typeof(point) != TYPE_DICTIONARY:
			return []
		if not point.has("x") or not point.has("y"):
			return []
		points.append(Vector2i(int(point["x"]), int(point["y"])))
	return points

func _canonicalize_point_set(points: Array[Vector2i], allow_rotation: bool) -> String:
	if points.is_empty():
		return ""
	var variants: Array = []
	if allow_rotation:
		for rotation in [0, 1, 2, 3]:
			variants.append(_normalize_points(_rotate_points(points, rotation)))
	else:
		variants.append(_normalize_points(points))
	variants.sort_custom(func(a: String, b: String) -> bool: return a < b)
	return variants[0]

func _canonicalize_sequence(points: Array[Vector2i], allow_rotation: bool) -> String:
	if points.is_empty():
		return ""

	var translated := []
	var anchor: Vector2i = points[0]
	for point in points:
		translated.append(point - anchor)

	var variants: Array = []
	if allow_rotation:
		for rotation in [0, 1, 2, 3]:
			variants.append(_serialize_sequence(_rotate_points(translated, rotation)))
	else:
		variants.append(_serialize_sequence(translated))

	variants.sort_custom(func(a: String, b: String) -> bool: return a < b)
	return variants[0]

func _rotate_points(points: Array, rotation_quarters: int) -> Array:
	var out := []
	for point_variant in points:
		var point := point_variant as Vector2i
		match rotation_quarters:
			0:
				out.append(Vector2i(point.x, point.y))
			1:
				out.append(Vector2i(-point.y, point.x))
			2:
				out.append(Vector2i(-point.x, -point.y))
			3:
				out.append(Vector2i(point.y, -point.x))
	return out

func _normalize_points(points: Array) -> String:
	if points.is_empty():
		return ""

	var min_x := INF
	var min_y := INF
	for point_variant in points:
		var point := point_variant as Vector2i
		if point.x < min_x:
			min_x = point.x
		if point.y < min_y:
			min_y = point.y

	var normalized: Array[String] = []
	for point_variant in points:
		var point := point_variant as Vector2i
		normalized.append("%s:%s" % [point.x - min_x, point.y - min_y])
	normalized.sort()
	return ",".join(normalized)

func _serialize_sequence(points: Array) -> String:
	var out: Array[String] = []
	for point_variant in points:
		var point := point_variant as Vector2i
		out.append("%s:%s" % [point.x, point.y])
	return "|".join(out)

func _refresh_label() -> void:
	info_label.text = "Click cells to place marchers. Enter submits, Esc cancels. Cells: %d" % selected_points.size()
