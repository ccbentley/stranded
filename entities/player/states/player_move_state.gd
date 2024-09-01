class_name PlayerMovingState
extends State

@export var actor: Player
@export var anim: AnimationPlayer
@export var footstep_audio_player: AudioStreamPlayer2D
@export var footstep_sound_timer: Timer

signal player_stopped_moving
signal player_entered_water

var grass_footstep_sfx: Array = [
	preload("res://entities/player/sounds/footsteps/grass/0.ogg"),
	preload("res://entities/player/sounds/footsteps/grass/1.ogg"),
	preload("res://entities/player/sounds/footsteps/grass/2.ogg"),
	preload("res://entities/player/sounds/footsteps/grass/3.ogg"),
	preload("res://entities/player/sounds/footsteps/grass/4.ogg"),
	preload("res://entities/player/sounds/footsteps/grass/5.ogg"),
	preload("res://entities/player/sounds/footsteps/grass/6.ogg"),
	preload("res://entities/player/sounds/footsteps/grass/7.ogg"),
	preload("res://entities/player/sounds/footsteps/grass/8.ogg"),
]

var sand_footstep_sfx: Array = [
	preload("res://entities/player/sounds/footsteps/sand/0.ogg"),
	preload("res://entities/player/sounds/footsteps/sand/1.ogg"),
	preload("res://entities/player/sounds/footsteps/sand/2.ogg"),
	preload("res://entities/player/sounds/footsteps/sand/3.ogg"),
	preload("res://entities/player/sounds/footsteps/sand/4.ogg"),
	preload("res://entities/player/sounds/footsteps/sand/5.ogg"),
	preload("res://entities/player/sounds/footsteps/sand/6.ogg"),
	preload("res://entities/player/sounds/footsteps/sand/7.ogg"),
	preload("res://entities/player/sounds/footsteps/sand/8.ogg"),
	preload("res://entities/player/sounds/footsteps/sand/9.ogg"),
]

enum FootStepSound {
	GRASS,
	SAND,
}

var footstep_sound: int:
	set(value):
		footstep_sound = value
		if value == FootStepSound.GRASS:
			if footstep_sound_timer.time_left <= 0:
				AudioManager.play_sound_2d(grass_footstep_sfx.pick_random(), -10, actor.global_position, true)
				footstep_sound_timer.start()
		elif value == FootStepSound.SAND:
			if footstep_sound_timer.time_left <= 0:
				AudioManager.play_sound_2d(sand_footstep_sfx.pick_random(), -10, actor.global_position, true)
				footstep_sound_timer.start()


func _ready() -> void:
	set_physics_process(false)


func _enter_state() -> void:
	set_physics_process(true)
	anim.play("move")


func _exit_state() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	var input: Vector2 = actor.get_input()
	# Exits state if there is no move input
	if input == Vector2.ZERO:
		player_stopped_moving.emit()
	#Move logic if there is input
	else:
		actor.velocity += (input * actor.accel * delta)
		actor.velocity = actor.velocity.limit_length(actor.move_speed)
	actor.move_and_slide()
	# Changes player facing direction
	if input.x < 0:
		actor.is_facing_right = false
	elif input.x > 0:
		actor.is_facing_right = true

	if actor.player_tile_type == actor.PlayerTile.WATER:
		player_entered_water.emit()

	# Footsteps
	if actor.player_tile_type == actor.PlayerTile.GRASS:
		footstep_sound = FootStepSound.GRASS
	elif actor.player_tile_type == actor.PlayerTile.SAND:
		footstep_sound = FootStepSound.SAND
