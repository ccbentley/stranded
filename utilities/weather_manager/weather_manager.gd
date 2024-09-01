extends CanvasLayer

@onready var rain: ColorRect = $Rain
@onready var timer: Timer = $Timer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum State { CLEAR, RAIN, STORM }

var state: int = State.CLEAR:
	set(value):
		if state != value:
			state = value
			if state == State.CLEAR:
				animation_player.play("clear")
				await animation_player.animation_finished
				rain.visible = false
				audio_stream_player.stop()
			elif state == State.RAIN:
				rain.material.set_shader_parameter("rain_color", Color(105, 255, 235, 0))
				rain.visible = true
				animation_player.play("rain")
				audio_stream_player.play()
			elif state == State.STORM:
				rain.visible = true
				animation_player.play("rain")
				audio_stream_player.play()


func _ready() -> void:
	set_timer()


func set_timer(time: float = randi_range(60, 120)) -> void:
	timer.wait_time = time
	timer.start()


func _on_timer_timeout() -> void:
	var rand: int = randi_range(1, 6)
	if rand == 1:
		state = State.RAIN
	elif rand == 2:
		state = State.STORM
	else:
		state = State.CLEAR
	set_timer()
