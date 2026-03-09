extends Node

const MUSIC_BUS_NAME := "Music"
const SFX_BUS_NAME := "SFX"
const MIN_DB := -80.0

@export var music_stream_paths: Dictionary[String, String] = {}
@export var sfx_stream_paths: Dictionary[String, String] = {}
@export var route_music_keys: Dictionary[String, String] = {}

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

var _music_streams: Dictionary[String, AudioStream] = {}
var _sfx_streams: Dictionary[String, AudioStream] = {}
var _music_tween: Tween

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = MUSIC_BUS_NAME
	add_child(music_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SfxPlayer"
	sfx_player.bus = SFX_BUS_NAME
	add_child(sfx_player)

	_music_streams = _build_audio_table(music_stream_paths, "music")
	_sfx_streams = _build_audio_table(sfx_stream_paths, "sfx")
	_connect_scene_router()

func play_music(name: String, fade_in_sec := 0.5) -> void:
	var stream := _music_streams.get(name) as AudioStream
	if stream == null:
		push_warning("AudioManager missing music key: %s" % name)
		return

	var target_volume_db := music_player.volume_db
	if music_player.stream == stream and music_player.playing:
		if target_volume_db <= MIN_DB:
			_tween_music_volume(0.0, target_volume_db)
		return

	stop_music(fade_in_sec)
	music_player.stream = stream
	music_player.volume_db = MIN_DB
	music_player.play()
	_tween_music_volume(max(fade_in_sec, 0.0), target_volume_db)

func stop_music(fade_out_sec := 0.5) -> void:
	if not music_player.playing:
		return

	var safe_fade := max(fade_out_sec, 0.0)
	if safe_fade == 0.0:
		music_player.stop()
		music_player.volume_db = 0.0
		return

	if _music_tween != null and _music_tween.is_running():
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(music_player, "volume_db", MIN_DB, safe_fade)
	_music_tween.finished.connect(func() -> void:
		music_player.stop()
		music_player.volume_db = 0.0
	)

func play_sound(name: String) -> void:
	var stream := _sfx_streams.get(name) as AudioStream
	if stream == null:
		push_warning("AudioManager missing sfx key: %s" % name)
		return
	sfx_player.stream = stream
	sfx_player.play()

func set_music_volume_db(volume_db: float) -> void:
	_set_bus_volume_db(MUSIC_BUS_NAME, volume_db)

func set_sfx_volume_db(volume_db: float) -> void:
	_set_bus_volume_db(SFX_BUS_NAME, volume_db)

func _connect_scene_router() -> void:
	if not has_node("/root/SceneRouter"):
		push_warning("AudioManager could not find SceneRouter autoload for route-based BGM")
		return

	var scene_router := get_node("/root/SceneRouter")
	if not scene_router.has_signal("route_changed"):
		push_warning("AudioManager expected SceneRouter.route_changed signal")
		return

	if not scene_router.route_changed.is_connected(_on_scene_route_changed):
		scene_router.route_changed.connect(_on_scene_route_changed)

func _on_scene_route_changed(route_key: String) -> void:
	if not route_music_keys.has(route_key):
		return
	play_music(route_music_keys[route_key])

func _build_audio_table(paths: Dictionary[String, String], label: String) -> Dictionary[String, AudioStream]:
	var streams: Dictionary[String, AudioStream] = {}
	for key: String in paths:
		var path := paths[key]
		var resource := load(path)
		if resource is AudioStream:
			streams[key] = resource
		else:
			push_warning("AudioManager failed to load %s key '%s' from path '%s'" % [label, key, path])
	return streams

func _set_bus_volume_db(bus_name: String, volume_db: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		push_warning("AudioManager missing audio bus: %s" % bus_name)
		return
	AudioServer.set_bus_volume_db(bus_idx, volume_db)

func _tween_music_volume(duration_sec: float, target_volume_db: float) -> void:
	if _music_tween != null and _music_tween.is_running():
		_music_tween.kill()

	if duration_sec == 0.0:
		music_player.volume_db = target_volume_db
		return

	_music_tween = create_tween()
	_music_tween.tween_property(music_player, "volume_db", target_volume_db, duration_sec)
