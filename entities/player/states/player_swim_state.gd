class_name PlayerSwimState
extends State

@export var actor: Player
@export var anim: AnimationPlayer
@export var drown_bar: ProgressBar
@export var water_trail: Node2D
@onready var drown_bar_timer: Timer = drown_bar.get_child(0)
@onready var player_hurt_timer: Timer = drown_bar.get_child(1)

signal player_exited_water


func _ready() -> void:
	set_physics_process(false)
	drown_bar_timer.timeout.connect(self.on_drown_bar_timer_timeout)
	player_hurt_timer.timeout.connect(self.on_player_hurt_timer_timeout)


func _enter_state() -> void:
	set_physics_process(true)
	anim.play("swim")
	actor.set_speed(actor.SWIM_SPEED)
	drown_bar.visible = true
	drown_bar.value = 100
	drown_bar_timer.start()
	water_trail.visible = true


func _exit_state() -> void:
	set_physics_process(false)
	actor.set_speed(actor.MAX_SPEED)
	drown_bar.visible = false
	drown_bar_timer.stop()
	player_hurt_timer.stop()
	water_trail.visible = false


func _physics_process(delta: float) -> void:
	if !actor.is_in_water():
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
		actor.velocity = actor.velocity.limit_length(actor.max_speed)
	actor.move_and_slide()
	#Changes player facing direction
	if input.x < 0:
		actor.is_facing_right = false
	elif input.x > 0:
		actor.is_facing_right = true


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
