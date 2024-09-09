extends Node2D
class_name FootstepComponent

@export var volume_db: float = -10

@onready var footstep_sound_timer: Timer = $FootStepSoundTimer

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
				AudioManager.play_sound_2d(grass_footstep_sfx.pick_random(), volume_db, global_position, true)
				footstep_sound_timer.start()
		elif value == FootStepSound.SAND:
			if footstep_sound_timer.time_left <= 0:
				AudioManager.play_sound_2d(sand_footstep_sfx.pick_random(), volume_db, global_position, true)
				footstep_sound_timer.start()


func _physics_process(_delta: float) -> void:
	if owner.velocity != Vector2.ZERO:
		if WorldManager.world.tile_map.get_tile_type(global_position) == 2:
			footstep_sound = FootStepSound.GRASS
		elif WorldManager.world.tile_map.get_tile_type(global_position) == 1:
			footstep_sound = FootStepSound.SAND
