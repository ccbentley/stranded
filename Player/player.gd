class_name Player
extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

#Custom Components
@onready var hitbox_component = $HitboxComponent
@onready var health_component = $HealthComponent
@onready var attack_component = $AttackComponent

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

@onready var on_hand: Sprite2D = $OnHand
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
var held_offset: Vector2 = Vector2.ZERO

#Timers
@onready var attack_cooldown_timer: Timer = $AttackCooldown

#Player stats
const MAX_SPEED : int = 90
var max_speed : int = MAX_SPEED
const accel : int = 1500
const friction : int = 1000

var input : Vector2 = Vector2.ZERO

var is_facing_right : bool = false:
	set(value):
		if value:
			player_sprite.flip_h = false
			on_hand.flip_h = false
			on_hand.position.x = 7
			on_hand.offset.x = held_offset.x
		else:
			player_sprite.flip_h = true
			on_hand.flip_h = true
			on_hand.position.x = -7
			on_hand.offset.x = -held_offset.x

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
	health_component.health += heal_value

func try_attack() -> bool:
	return attack_cooldown_timer.time_left <= 0

func melee_attack(attack_range: float, attack_cooldown: float, attack_damage: float, attack_knockback: float, attack_stun_time: float) -> void:
	attack_cooldown_timer.start(attack_cooldown)
	var attack = Attack.new()
	attack.attack_damage = attack_damage
	attack.attack_knockback = attack_knockback
	attack.attack_position  = global_position
	attack.attack_stun_time = attack_stun_time
	attack_component.set_attack_range(attack_range, is_facing_right)
	attack_component.attack(attack)
	animation_player.play("melee_attack")

func ranged_attack(attack_cooldown, attack_damage, attack_knockback, attack_stun_time):
	attack_cooldown_timer.start(attack_cooldown)


func display_on_hand(texture: Texture2D, _held_offset: Vector2):
	on_hand.texture = texture
	held_offset = _held_offset
	on_hand.offset = held_offset

func _physics_process(_delta: float) -> void:
	on_hand.look_at(get_global_mouse_position())
