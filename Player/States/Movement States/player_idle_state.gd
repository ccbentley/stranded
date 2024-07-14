class_name PlayerIdleState
extends State

@export var actor: Player
@export var anim: AnimatedSprite2D

signal player_moved

func _ready() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	anim.play("idle")

func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	#Slows the player down from moving
	if actor.velocity.length() > (actor.friction * delta):
			actor.velocity -= actor.velocity.normalized() * (actor.friction * delta)
			actor.move_and_slide()
	else:
		actor.velocity = Vector2.ZERO
	#Exits state if player moved
	if actor.get_input() != Vector2.ZERO:
		player_moved.emit()
