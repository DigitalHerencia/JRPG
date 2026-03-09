extends Node

var routes := {
	"main_menu": "res://scenes/ui/MainMenu.tscn",
	"campus": "res://scenes/world/Campus.tscn",
	"field_command": "res://scenes/band/FieldCommand.tscn",
	"rhythm_battle": "res://scenes/battle/RhythmBattle.tscn"
}

func goto(route_key: String) -> void:
	if not routes.has(route_key):
		push_error("Unknown route: %s" % route_key)
		return
	GameState.current_scene_key = route_key
	get_tree().change_scene_to_file(routes[route_key])


func change_scene(scene_path: String) -> void:
	if scene_path == "":
		push_error("Scene path cannot be empty")
		return
	get_tree().change_scene_to_file(scene_path)
