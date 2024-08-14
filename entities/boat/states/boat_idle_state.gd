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
	print("yes")
	if actor.velocity.length() > 0:
		var friction_force: Vector2 = actor.velocity.normalized() * actor.friction * delta
		if friction_force.length() > actor.velocity.length():
			actor.velocity = Vector2.ZERO
		else:
			actor.velocity -= friction_force
	else:
		actor.velocity = Vector2.ZERO
	actor.move_and_slide()
