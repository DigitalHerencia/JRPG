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
	GameState.set_current_scene_by_key(route_key, routes[route_key])
	get_tree().change_scene_to_file(routes[route_key])
