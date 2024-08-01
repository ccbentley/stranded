class_name BoatIdleState
extends State

@export var actor: Boat
@export var anim: Sprite2D

signal player_entered


func _ready() -> void:
	set_physics_process(false)


func _enter_state() -> void:
	set_physics_process(true)


func _exit_state() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	#Slows the boat down from moving
	if actor.velocity.length() > (actor.friction * delta):
		actor.velocity -= actor.velocity.normalized() * (actor.friction * delta)
		actor.move_and_slide()
	else:
		actor.velocity = Vector2.ZERO
