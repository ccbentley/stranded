class_name Player
extends CharacterBody2D

#State Machines
@onready var msm = $MovementStateMachine as MovementStateMachine
@onready var asm = $ActionStateMachine as ActionStateMachine

#Movement States
@onready var player_idle_state = $MovementStateMachine/PlayerIdleState as PlayerIdleState
@onready var player_moving_state = $MovementStateMachine/PlayerMovingState as PlayerMovingState

#Action States
@onready var player_no_action_state = $ActionStateMachine/PlayerNoActionState as PlayerNoActionState
@onready var player_attack_state = $ActionStateMachine/PlayerAttackState as PlayerAttackState

@export var held_item : Node2D

#Player stats
const max_speed : int = 90
const accel : int = 1500
const friction : int = 1000

var input : Vector2 = Vector2.ZERO

var is_facing_right : bool = false

func _ready() -> void:
	player_idle_state.player_moved.connect(msm.change_state.bind(player_moving_state))
	player_moving_state.player_stopped_moving.connect(msm.change_state.bind(player_idle_state))

#Returns move input as a Vector2
func get_input() -> Vector2:
	input.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	input.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	return input.normalized()

func _physics_process(_delta) -> void:
	held_item.look_at(get_global_mouse_position())
