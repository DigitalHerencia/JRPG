extends Control

@onready var info_label: Label = %InfoLabel
@onready var combo_label: Label = %ComboLabel
@onready var timer_label: Label = %TimerLabel

var sequence := ["rhythm_1", "rhythm_2", "rhythm_3", "rhythm_4", "rhythm_2", "rhythm_1"]
var index := 0
var combo := 0
var time_left := 15.0

func _ready() -> void:
	_update_labels()

func _process(delta: float) -> void:
	time_left -= delta
	if time_left <= 0.0:
		_end_battle()
		time_left = 9999.0
	_update_labels()
	_check_inputs()
	if Input.is_action_just_pressed("back"):
		SceneRouter.goto("campus")

func _check_inputs() -> void:
	if index >= sequence.size():
		_end_battle(true)
		return
	var expected := sequence[index]
	if Input.is_action_just_pressed(expected):
		combo += 1
		index += 1
		info_label.text = "Perfect hit. Phrase %d/%d" % [index, sequence.size()]
	elif Input.is_action_just_pressed("rhythm_1") or Input.is_action_just_pressed("rhythm_2") or Input.is_action_just_pressed("rhythm_3") or Input.is_action_just_pressed("rhythm_4"):
		combo = 0
		info_label.text = "Off-beat. The judges look concerned."

func _end_battle(won := false) -> void:
	if won:
		GameState.add_hype(10)
		info_label.text = "Victory solo achieved. Crowd hype increased. Returning to campus..."
	else:
		info_label.text = "Rehearsal over. Your embouchure survives. Returning to campus..."
	await get_tree().create_timer(1.4).timeout
	SceneRouter.goto("campus")

func _update_labels() -> void:
	combo_label.text = "Combo: %d" % combo
	timer_label.text = "Time: %.1f" % max(time_left, 0.0)
