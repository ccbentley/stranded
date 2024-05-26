extends CharacterBody2D

enum {
	IDLE,
	WALKING,
	ATTACKING,
}
var current_state : int = IDLE

const max_speed : int = 90
const accel : int = 1500
const friction : int = 1000
var input : Vector2 = Vector2.ZERO

var is_facing_right : bool = false

@onready var anim : Node2D = $AnimatedSprite2D

func _process(_delta) -> void:
	if input != Vector2.ZERO && current_state != ATTACKING:
		current_state = WALKING
	elif input == Vector2.ZERO && current_state != ATTACKING:
		current_state = IDLE
	if Input.is_action_just_pressed("attack"):
		attack()
		current_state = ATTACKING

func _physics_process(delta) -> void:
	match current_state:
		IDLE:
			pass
		WALKING:
			pass
	player_movement(delta)
	play_anim()

func get_input() -> Vector2:
	input.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	input.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	return input.normalized()
	
func player_movement(delta) -> void:
	input = get_input()
	if input == Vector2.ZERO:
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(max_speed)
	move_and_slide()

func play_anim() -> void:
	if(current_state == WALKING):
		anim.play("walk")
	else:
		anim.play("idle")
		
	if input.x < 0:
		anim.flip_h = true
		is_facing_right = false
	elif input.x > 0:
		anim.flip_h = false
		is_facing_right = true

func attack() -> void:
	pass
