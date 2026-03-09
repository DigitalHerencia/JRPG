extends Control

const LEVEL_ID := "pep_rally"
const DEFAULT_LANE_COUNT := 4
const LANE_WIDTH := 168.0
const LANE_GAP := 16.0
const NOTE_WIDTH := 128.0
const NOTE_HEIGHT := 20.0
const DEFAULT_APPROACH_TIME := 1.8
const DEFAULT_MISS_WINDOW := 0.20
const DEFAULT_PERFECT_WINDOW := 0.06
const DEFAULT_GOOD_WINDOW := 0.12
const SCORE_PERFECT := 1000
const SCORE_GOOD := 500
const SCORE_MISS := 0
const LANE_ACTIONS := ["rhythm_1", "rhythm_2", "rhythm_3", "rhythm_4"]

@onready var info_label: Label = %InfoLabel
@onready var score_label: Label = %ScoreLabel
@onready var combo_label: Label = %ComboLabel
@onready var accuracy_label: Label = %AccuracyLabel
@onready var timer_label: Label = %TimerLabel
@onready var result_label: Label = %ResultLabel
@onready var hit_line: ColorRect = %HitLine
@onready var notes_layer: Control = %NotesLayer

var scheduled_notes: Array[Dictionary] = []
var next_spawn_index := 0
var battle_time := 0.0
var battle_complete := false
var total_notes := 0

var lane_count := DEFAULT_LANE_COUNT
var approach_time := DEFAULT_APPROACH_TIME
var miss_window := DEFAULT_MISS_WINDOW
var perfect_window := DEFAULT_PERFECT_WINDOW
var good_window := DEFAULT_GOOD_WINDOW
var chart_notes: Array[Dictionary] = []

var score := 0
var combo := 0
var max_combo := 0
var perfect_count := 0
var good_count := 0
var miss_count := 0

func _ready() -> void:
	_load_rhythm_config()
	_build_chart()
	_update_labels()

func _process(delta: float) -> void:
	if battle_complete:
		return
	battle_time += delta
	_spawn_incoming_notes()
	_move_active_notes()
	_check_missed_notes()
	_update_labels()
	_check_battle_completion()
	if Input.is_action_just_pressed("back"):
		_finish_battle(false)

func _unhandled_input(event: InputEvent) -> void:
	if battle_complete:
		return
	for lane_index in LANE_ACTIONS.size():
		if event.is_action_pressed(LANE_ACTIONS[lane_index]):
			_judge_lane_input(lane_index)
			get_viewport().set_input_as_handled()
			return

func _load_rhythm_config() -> void:
	chart_notes.clear()
	var level_data := ContentDB.get_level(LEVEL_ID)
	if level_data.is_empty():
		_set_default_rhythm_config()
		info_label.text = "Using fallback rhythm config."
		return

	var rhythm_config = level_data.get("rhythm", {})
	if typeof(rhythm_config) != TYPE_DICTIONARY:
		_set_default_rhythm_config()
		info_label.text = "Invalid rhythm config. Using fallback."
		return

	lane_count = clampi(int(rhythm_config.get("lanes", DEFAULT_LANE_COUNT)), 1, LANE_ACTIONS.size())
	approach_time = float(rhythm_config.get("approach_time", DEFAULT_APPROACH_TIME))
	miss_window = float(rhythm_config.get("miss_window", DEFAULT_MISS_WINDOW))
	perfect_window = float(rhythm_config.get("perfect_window", DEFAULT_PERFECT_WINDOW))
	good_window = float(rhythm_config.get("good_window", DEFAULT_GOOD_WINDOW))

	var raw_chart = rhythm_config.get("chart_notes", [])
	if typeof(raw_chart) != TYPE_ARRAY or raw_chart.is_empty():
		_set_default_rhythm_config()
		info_label.text = "Missing rhythm chart. Using fallback."
		return

	for note in raw_chart:
		if typeof(note) != TYPE_DICTIONARY:
			continue
		chart_notes.append({
			"lane": int(note.get("lane", 0)),
			"hit_time": float(note.get("hit_time", 0.0))
		})

	if chart_notes.is_empty():
		_set_default_rhythm_config()
		info_label.text = "No valid rhythm notes. Using fallback."

func _set_default_rhythm_config() -> void:
	lane_count = DEFAULT_LANE_COUNT
	approach_time = DEFAULT_APPROACH_TIME
	miss_window = DEFAULT_MISS_WINDOW
	perfect_window = DEFAULT_PERFECT_WINDOW
	good_window = DEFAULT_GOOD_WINDOW
	chart_notes = [
		{"lane": 0, "hit_time": 1.50},
		{"lane": 1, "hit_time": 2.00},
		{"lane": 2, "hit_time": 2.50},
		{"lane": 3, "hit_time": 3.00},
		{"lane": 0, "hit_time": 3.35},
		{"lane": 2, "hit_time": 3.80},
		{"lane": 1, "hit_time": 4.20},
		{"lane": 3, "hit_time": 4.70},
		{"lane": 0, "hit_time": 5.20},
		{"lane": 1, "hit_time": 5.65},
		{"lane": 2, "hit_time": 6.10},
		{"lane": 3, "hit_time": 6.55},
		{"lane": 2, "hit_time": 7.00},
		{"lane": 1, "hit_time": 7.35},
		{"lane": 0, "hit_time": 7.80},
		{"lane": 3, "hit_time": 8.35}
	]

func _build_chart() -> void:
	scheduled_notes.clear()
	next_spawn_index = 0
	for entry in chart_notes:
		var lane_index: int = clampi(int(entry.get("lane", 0)), 0, lane_count - 1)
		var hit_time: float = float(entry.get("hit_time", 0.0))
		scheduled_notes.append({
			"lane_index": lane_index,
			"spawn_time": maxf(hit_time - approach_time, 0.0),
			"hit_time": hit_time,
			"consumed": false,
			"spawned": false,
			"note_node": null
		})
	total_notes = scheduled_notes.size()

func _spawn_incoming_notes() -> void:
	while next_spawn_index < scheduled_notes.size() and battle_time >= float(scheduled_notes[next_spawn_index]["spawn_time"]):
		var note_data: Dictionary = scheduled_notes[next_spawn_index]
		var note_node := ColorRect.new()
		note_node.color = Color(0.86, 0.91, 0.98, 1)
		note_node.size = Vector2(NOTE_WIDTH, NOTE_HEIGHT)
		note_node.position = _note_position(int(note_data["lane_index"]), 0.0)
		notes_layer.add_child(note_node)
		note_data["note_node"] = note_node
		note_data["spawned"] = true
		scheduled_notes[next_spawn_index] = note_data
		next_spawn_index += 1

func _move_active_notes() -> void:
	for i in scheduled_notes.size():
		var note_data: Dictionary = scheduled_notes[i]
		if note_data["consumed"] or not note_data["spawned"]:
			continue
		var note_node: ColorRect = note_data["note_node"]
		if note_node == null:
			continue
		var hit_time: float = note_data["hit_time"]
		var progress := clampf(1.0 - ((hit_time - battle_time) / approach_time), 0.0, 1.2)
		note_node.position = _note_position(int(note_data["lane_index"]), progress)

func _check_missed_notes() -> void:
	for i in scheduled_notes.size():
		var note_data: Dictionary = scheduled_notes[i]
		if note_data["consumed"]:
			continue
		var hit_time: float = note_data["hit_time"]
		if battle_time - hit_time > miss_window:
			_consume_note(i, "miss")

func _judge_lane_input(lane_index: int) -> void:
	var candidate_index := -1
	var best_timing := INF
	for i in scheduled_notes.size():
		var note_data: Dictionary = scheduled_notes[i]
		if note_data["consumed"] or not note_data["spawned"]:
			continue
		if int(note_data["lane_index"]) != lane_index:
			continue
		var timing_delta := absf(float(note_data["hit_time"]) - battle_time)
		if timing_delta <= miss_window and timing_delta < best_timing:
			best_timing = timing_delta
			candidate_index = i
	if candidate_index == -1:
		combo = 0
		miss_count += 1
		info_label.text = "Lane %d stray tap." % (lane_index + 1)
		return
	if best_timing <= perfect_window:
		_consume_note(candidate_index, "perfect")
	elif best_timing <= good_window:
		_consume_note(candidate_index, "good")
	else:
		_consume_note(candidate_index, "miss")

func _consume_note(note_index: int, result: String) -> void:
	var note_data: Dictionary = scheduled_notes[note_index]
	note_data["consumed"] = true
	if note_data["spawned"] and note_data["note_node"] != null:
		note_data["note_node"].queue_free()
	note_data["note_node"] = null
	scheduled_notes[note_index] = note_data

	match result:
		"perfect":
			perfect_count += 1
			combo += 1
			score += SCORE_PERFECT
			info_label.text = "Perfect"
		"good":
			good_count += 1
			combo += 1
			score += SCORE_GOOD
			info_label.text = "Good"
		_:
			miss_count += 1
			combo = 0
			score += SCORE_MISS
			info_label.text = "Miss"
	max_combo = maxi(max_combo, combo)

func _check_battle_completion() -> void:
	for note_data in scheduled_notes:
		if not note_data["consumed"]:
			return
	_finish_battle(_did_win())

func _did_win() -> bool:
	var accuracy := _accuracy_ratio()
	return accuracy >= 0.70 and miss_count <= total_notes / 3

func _finish_battle(won: bool) -> void:
	if battle_complete:
		return
	battle_complete = true

	if won:
		GameState.add_hype(20)
		GameState.set_flag("rival_defeated", true)
		result_label.text = "Result: Victory! Max Combo %d | Accuracy %.1f%%" % [max_combo, _accuracy_ratio() * 100.0]
	else:
		GameState.set_flag("rival_defeated", false)
		result_label.text = "Result: Defeat. Max Combo %d | Accuracy %.1f%%" % [max_combo, _accuracy_ratio() * 100.0]

	await get_tree().create_timer(2.2).timeout
	SceneRouter.change_scene_key("campus")

func _accuracy_ratio() -> float:
	if total_notes <= 0:
		return 0.0
	var weighted_hits := (perfect_count * 1.0) + (good_count * 0.5)
	return weighted_hits / float(total_notes)

func _update_labels() -> void:
	score_label.text = "Score: %d" % score
	combo_label.text = "Combo: %d" % combo
	accuracy_label.text = "Perfect: %d | Good: %d | Miss: %d" % [perfect_count, good_count, miss_count]
	timer_label.text = "Time: %.2f | Windows P %.2f / G %.2f / M %.2f" % [battle_time, perfect_window, good_window, miss_window]

func _note_position(lane_index: int, progress: float) -> Vector2:
	var lane_start_x := lane_index * (LANE_WIDTH + LANE_GAP)
	var center_x := lane_start_x + ((LANE_WIDTH - NOTE_WIDTH) * 0.5)
	var lane_top := 0.0
	var lane_bottom := hit_line.position.y - (NOTE_HEIGHT * 0.5)
	var y := lerpf(lane_top, lane_bottom, progress)
	return Vector2(center_x, y)
