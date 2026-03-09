extends Node2D

@onready var info_label: Label = %InfoLabel
@onready var grid: ColorRect = %Grid

var selected_points: Array[Vector2i] = []
var cell_size := 32

func _ready() -> void:
	_refresh_label()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos := grid.get_local_mouse_position()
		if Rect2(Vector2.ZERO, grid.size).has_point(local_pos):
			var cell := Vector2i(floor(local_pos.x / cell_size), floor(local_pos.y / cell_size))
			if not selected_points.has(cell):
				selected_points.append(cell)
				queue_redraw()
				_refresh_label()
	if Input.is_action_just_pressed("ui_accept"):
		var result := _evaluate_formation()
		info_label.text = "Formation: %s | Press Enter again for rhythm battle" % result
		if selected_points.size() >= 4:
			GameState.add_hype(5)
			SceneRouter.goto("rhythm_battle")
	if Input.is_action_just_pressed("back"):
		SceneRouter.goto("campus")

func _draw() -> void:
	for point in selected_points:
		draw_rect(Rect2(point * cell_size, Vector2(cell_size, cell_size)), Color(0.96, 0.62, 0.15, 0.65), true)

func _evaluate_formation() -> String:
	if selected_points.size() <= 1:
		return "lonely dot of destiny"
	var xs := selected_points.map(func(p): return p.x)
	var ys := selected_points.map(func(p): return p.y)
	var width := xs.max() - xs.min()
	var height := ys.max() - ys.min()
	if width > height * 2:
		return "line formation"
	if height > width * 2:
		return "column formation"
	if abs(width - height) <= 1 and selected_points.size() >= 4:
		return "box formation"
	return "chaotic jazz sigil"

func _refresh_label() -> void:
	info_label.text = "Click cells to place marchers. Enter to evaluate. Esc to return. Cells: %d" % selected_points.size()
