class_name PlayerSwimState
extends State

@export var actor : Player
@export var anim : AnimatedSprite2D

signal player_exited_water

func _ready() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	anim.play("swim")
	actor.set_speed(actor.SWIM_SPEED)

func _exit_state() -> void:
	set_physics_process(false)
	actor.set_speed(actor.MAX_SPEED)

func _physics_process(delta) -> void:
	if !actor.is_in_water():
		player_exited_water.emit()

	var input = actor.get_input()
	#Exits state if there is no move input
	if input == Vector2.ZERO:
		if actor.velocity.length() > (actor.friction * delta):
			actor.velocity -= actor.velocity.normalized() * (actor.friction * delta)
			actor.move_and_slide()
		else:
			actor.velocity = Vector2.ZERO
	else:
		actor.velocity += (input * actor.accel * delta)
		actor.velocity = actor.velocity.limit_length(actor.max_speed)
	actor.move_and_slide()
	#Changes player facing direction
	if input.x < 0:
		actor.is_facing_right = false
	elif input.x > 0:
		actor.is_facing_right = true

