class_name BoatMoveState
extends State

@export var actor: Boat
@export var anim: Sprite2D

signal player_exited


func _ready() -> void:
	set_physics_process(false)


func _enter_state() -> void:
	set_physics_process(true)


func _exit_state() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	var player: Player = actor.player
	player.global_position = actor.global_position
	if !actor.is_in_water():
		actor.boat_speed = actor.land_boat_speed
	else:
		actor.boat_speed = actor.water_boat_speed
	var input: Vector2 = player.get_input()
	if input == Vector2.ZERO:
		if actor.velocity.length() > 0:
			var friction_force: Vector2 = actor.velocity.normalized() * actor.friction * delta
			if friction_force.length() > actor.velocity.length():
				actor.velocity = Vector2.ZERO
			else:
				actor.velocity -= friction_force
	else:
		actor.velocity += (input * actor.accel * delta)
		actor.velocity = actor.velocity.limit_length(actor.boat_speed)
	actor.move_and_slide()
	#Changes player facing direction
	if input.x < 0:
		actor.is_facing_right = false
		player.is_facing_right = false
	elif input.x > 0:
		actor.is_facing_right = true
		player.is_facing_right = true
	if Input.is_action_pressed("dismount"):
		player.z_index = 0
		player_exited.emit()
