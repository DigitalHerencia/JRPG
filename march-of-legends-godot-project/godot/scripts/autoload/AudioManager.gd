extends Node

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SfxPlayer"
	add_child(sfx_player)

func play_music(stream: AudioStream) -> void:
	if stream == null:
		return
	music_player.stream = stream
	music_player.play()

func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	sfx_player.stream = stream
	sfx_player.play()
