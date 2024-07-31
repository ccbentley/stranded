class_name Player
extends CharacterBody2D

@export var tile_map: TileMap
@onready var main: Node2D = $".."

@onready var animation_player: AnimationPlayer = $AnimationPlayer

#Custom Components
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_component: AttackComponent = $AttackComponent

@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip

#State Machines
@onready var msm: MovementStateMachine = $StateMachines/MovementStateMachine as MovementStateMachine
@onready var asm: ActionStateMachine = $StateMachines/ActionStateMachine as ActionStateMachine

#Movement States
@onready var player_idle_state: PlayerIdleState = $StateMachines/MovementStateMachine/PlayerIdleState as PlayerIdleState
@onready var player_moving_state: PlayerMovingState = $StateMachines/MovementStateMachine/PlayerMovingState as PlayerMovingState
@onready var player_swim_state: PlayerSwimState = $StateMachines/MovementStateMachine/PlayerSwimState as PlayerSwimState

#Action States
@onready var player_no_action_state: PlayerNoActionState = $StateMachines/ActionStateMachine/PlayerNoActionState as PlayerNoActionState
@onready var player_attack_state: PlayerAttackState = $StateMachines/ActionStateMachine/PlayerAttackState as PlayerAttackState

@onready var on_hand: Sprite2D = $OnHand
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
var held_offset: Vector2 = Vector2.ZERO

#Timers
@onready var attack_cooldown_timer: Timer = $AttackCooldown

#Player stats
const MAX_SPEED: int = 90
const SWIM_SPEED: int = 50
var max_speed: int = MAX_SPEED
const accel: int = 1500
const friction: int = 1000

var input: Vector2 = Vector2.ZERO

var player_tile: Vector2i

signal toggle_inventory


func _physics_process(_delta: float) -> void:
	player_tile = tile_map.local_to_map(global_position)


var is_facing_right: bool = true:
	set(value):
		if value and is_facing_right != value:
			animation_player.play("flip")
			player_sprite.flip_h = false
			on_hand.flip_h = false
			on_hand.position.x = 7
			on_hand.offset.x = held_offset.x
			is_facing_right = value
		elif not value and is_facing_right != value:
			animation_player.play("flip")
			player_sprite.flip_h = true
			on_hand.flip_h = true
			on_hand.position.x = -7
			on_hand.offset.x = -held_offset.x
			is_facing_right = value


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()
	if Input.is_action_just_pressed("save"):
		main.save_game()
	if Input.is_action_just_pressed("load"):
		main.load_game()
	if Input.is_action_just_pressed("zoom_in"):
		main.zoom_in()
	if Input.is_action_just_pressed("zoom_out"):
		main.zoom_out()
	if Input.is_action_just_pressed("use"):
		var mouse_position: Vector2 = get_viewport().get_mouse_position()
		#Clicked left side
		if mouse_position.x < get_viewport().size.x / 2:
			is_facing_right = false
		#Clicked right side
		else:
			is_facing_right = true


func _ready() -> void:
	PlayerManager.player = self
	player_idle_state.player_moved.connect(msm.change_state.bind(player_moving_state))
	player_moving_state.player_stopped_moving.connect(msm.change_state.bind(player_idle_state))
	player_moving_state.player_entered_water.connect(msm.change_state.bind(player_swim_state))
	player_swim_state.player_exited_water.connect(msm.change_state.bind(player_moving_state))


#Returns move input as a Vector2
func get_input() -> Vector2:
	input.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return input.normalized()


func interact() -> void:
	for area in hitbox_component.get_overlapping_areas():
		if area.is_in_group("interactable"):
			area.get_parent().player_interact()


func get_drop_position() -> Vector2:
	var direction: Vector2
	match is_facing_right:
		true:
			direction = Vector2(20, 0)
		false:
			direction = Vector2(-20, 0)
	return self.global_position + direction


func heal(heal_value: int) -> void:
	health_component.health += heal_value


func try_attack() -> bool:
	return attack_cooldown_timer.time_left <= 0


func melee_attack(attack_range: float, attack_cooldown: float, attack_damage: float, attack_knockback: float, attack_stun_time: float, material_type: int) -> void:
	attack_cooldown_timer.start(attack_cooldown)
	var attack: Attack = Attack.new()
	attack.attack_damage = attack_damage
	attack.attack_knockback = attack_knockback
	attack.attack_position = global_position
	attack.attack_stun_time = attack_stun_time
	attack.material_type = material_type
	attack_component.set_attack_range(attack_range, is_facing_right)
	attack_component.attack(attack)
	animation_player.play("melee_attack")


func ranged_attack(attack_cooldown: float, attack_damage: float, attack_knockback: float, attack_stun_time: float) -> void:
	attack_cooldown_timer.start(attack_cooldown)
	var attack: Attack = Attack.new()
	attack.attack_damage = attack_damage
	attack.attack_knockback = attack_knockback
	attack.attack_stun_time = attack_stun_time


func set_speed(speed: int) -> void:
	max_speed = speed


func display_on_hand(texture: Texture2D, _held_offset: Vector2) -> void:
	on_hand.texture = texture
	held_offset = _held_offset
	on_hand.offset = held_offset


func is_in_water() -> bool:
	var tile_data: TileData = tile_map.get_cell_tile_data(0, player_tile)
	if tile_data:
		return tile_data.get_custom_data("can_swim")
	else:
		return false
