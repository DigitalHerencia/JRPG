extends Node

const DEFAULT_PARTY := ["leo", "dr_major", "snare_kid"]

var current_scene_key: String = "main_menu"
var current_scene_path: String = "res://scenes/ui/MainMenu.tscn"
var player_name: String = "Leo Crescendo"
var party: Array[String] = DEFAULT_PARTY.duplicate()
var flags: Dictionary = {}
var stats: Dictionary = {
	"hype": 0,
	"discipline": 1,
	"improv": 0,
	"semester_week": 1
}

func set_flag(flag_name: String, value := true) -> void:
	flags[flag_name] = value

func has_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

func add_hype(amount: int) -> void:
	stats["hype"] = stats.get("hype", 0) + amount

func advance_week() -> void:
	stats["semester_week"] = stats.get("semester_week", 1) + 1
