class_name Player
extends CharacterBody2D

@onready var hitbox_component = $HitboxComponent
@onready var health_component = $HealthComponent

@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip

#State Machines
@onready var msm = $MovementStateMachine as MovementStateMachine
@onready var asm = $ActionStateMachine as ActionStateMachine

#Movement States
@onready var player_idle_state = $MovementStateMachine/PlayerIdleState as PlayerIdleState
@onready var player_moving_state = $MovementStateMachine/PlayerMovingState as PlayerMovingState

#Action States
@onready var player_no_action_state = $ActionStateMachine/PlayerNoActionState as PlayerNoActionState
@onready var player_attack_state = $ActionStateMachine/PlayerAttackState as PlayerAttackState

#Player stats
const max_speed : int = 90
const accel : int = 1500
const friction : int = 1000

var input : Vector2 = Vector2.ZERO

var is_facing_right : bool = false

signal toggle_inventory

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()

func _ready() -> void:
	PlayerManager.player = self
	player_idle_state.player_moved.connect(msm.change_state.bind(player_moving_state))
	player_moving_state.player_stopped_moving.connect(msm.change_state.bind(player_idle_state))

#Returns move input as a Vector2
func get_input() -> Vector2:
	input.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	input.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	return input.normalized()

func interact() -> void:
	for area in hitbox_component.get_overlapping_areas():
		if area.is_in_group("interactable"):
			area.get_parent().player_interact()

func get_drop_position() -> Vector2:
	var direction : Vector2
	match is_facing_right:
		true:
			direction = Vector2(20,0)
		false:
			direction = Vector2(-20,0)
	return self.global_position + direction

func heal(heal_value: int) -> void:
	$HealthComponent.health += heal_value
