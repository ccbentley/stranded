extends Node


func play_sound(sound: AudioStream, volume: float = 0, random_pitch: bool = false) -> void:
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	audio_stream_player.stream = sound
	audio_stream_player.volume_db = volume
	audio_stream_player.bus = "Sfx"
	if random_pitch:
		randomize()
		audio_stream_player.pitch_scale = randf_range(0.8, 1.2)
	audio_stream_player.play()
	await audio_stream_player.finished
	audio_stream_player.queue_free()


func play_sound_2d(sound: AudioStream, volume: float = 0, pos: Vector2 = Vector2.ZERO, random_pitch: bool = false) -> void:
	var audio_stream_player_2d: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	add_child(audio_stream_player_2d)
	audio_stream_player_2d.stream = sound
	audio_stream_player_2d.volume_db = volume
	audio_stream_player_2d.global_position = pos
	audio_stream_player_2d.bus = "Sfx"
	if random_pitch:
		randomize()
		audio_stream_player_2d.pitch_scale = randf_range(0.8, 1.2)
	audio_stream_player_2d.play()
	await audio_stream_player_2d.finished
	audio_stream_player_2d.queue_free()


var music_audio_stream_player: AudioStreamPlayer
var music_tween: Tween


func _ready() -> void:
	music_audio_stream_player = AudioStreamPlayer.new()
	add_child(music_audio_stream_player)


func play_music(music: AudioStream, volume: float = 0) -> void:
	if music_audio_stream_player.playing:
		music_tween = get_tree().create_tween()
		music_tween.tween_property(music_audio_stream_player, "volume_db", -80, 1.5)
		await music_tween.finished
		music_audio_stream_player.stop()
	music_audio_stream_player.stream = music
	music_audio_stream_player.volume_db = volume
	music_audio_stream_player.bus = "Music"
	music_audio_stream_player.volume_db = -80
	music_audio_stream_player.play()
	music_tween = get_tree().create_tween()
	music_tween.tween_property(music_audio_stream_player, "volume_db", volume, 1.5)
