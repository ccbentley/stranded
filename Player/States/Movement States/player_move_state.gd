class_name PlayerMovingState
extends State

@export var actor : Player
@export var anim : AnimatedSprite2D

var input : Vector2 = Vector2.ZERO

signal player_stopped_moving

func _ready() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	anim.play("move")

func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(delta) -> void:
	input = actor.get_input()
	#Exits state if there is no move input
	if input == Vector2.ZERO:
		player_stopped_moving.emit()
	#Move logic if there is input
	else:
		actor.velocity += (input * actor.accel * delta)
		actor.velocity = actor.velocity.limit_length(actor.max_speed)
	actor.move_and_slide()
	#Changes player facing direction
	if input.x < 0:
		actor.is_facing_right = false
	elif input.x > 0:
		actor.is_facing_right = true
