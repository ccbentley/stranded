class_name PlayerSwimState
extends State

@export var actor: Player
@export var anim: AnimationPlayer
@export var drown_bar: ProgressBar
@export var water_trail: Node2D
@onready var drown_bar_timer: Timer = drown_bar.get_child(0)
@onready var player_hurt_timer: Timer = drown_bar.get_child(1)

signal player_exited_water

const SPLASH_1 = preload("res://entities/player/sounds/splash/splash1.wav")
const SPLASH_2 = preload("res://entities/player/sounds/splash/splash2.wav")

func _ready() -> void:
	set_physics_process(false)
	drown_bar_timer.timeout.connect(self.on_drown_bar_timer_timeout)
	player_hurt_timer.timeout.connect(self.on_player_hurt_timer_timeout)


func _enter_state() -> void:
	set_physics_process(true)
	anim.play("swim")
	drown_bar.visible = true
	drown_bar.value = 100
	drown_bar_timer.start()
	water_trail.visible = true
	actor.main.vignette.display_vignette(Color.SKY_BLUE)
	AudioManager.play_sound_2d(SPLASH_2, -1, actor.global_position, true)


func _exit_state() -> void:
	set_physics_process(false)
	drown_bar.visible = false
	drown_bar_timer.stop()
	player_hurt_timer.stop()
	water_trail.visible = false
	actor.main.vignette.remove_vignette()
	AudioManager.play_sound_2d(SPLASH_1, -1, actor.global_position, true)


func _physics_process(delta: float) -> void:
	if not actor.player_tile_type == actor.PlayerTile.WATER:
		player_exited_water.emit()

	var input: Vector2 = actor.get_input()
	if input == Vector2.ZERO:
		if actor.velocity.length() > 0:
			var friction_force: Vector2 = actor.velocity.normalized() * actor.friction * delta
			if friction_force.length() > actor.velocity.length():
				actor.velocity = Vector2.ZERO
			else:
				actor.velocity -= friction_force
	else:
		actor.velocity += (input * actor.accel * delta)
		actor.velocity = actor.velocity.limit_length(actor.move_speed)
	#Changes player facing direction
	if input.x < 0:
		actor.is_facing_right = false
	elif input.x > 0:
		actor.is_facing_right = true

	actor.decrase_hunger(1 * delta)


func on_drown_bar_timer_timeout() -> void:
	if drown_bar.value > 0:
		drown_bar.value -= 10
	else:
		if player_hurt_timer.is_stopped():
			player_hurt_timer.start()


func on_player_hurt_timer_timeout() -> void:
	var attack: Attack = Attack.new()
	attack.attack_damage = 2
	actor.health_component.damage(attack)
