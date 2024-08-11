class_name Player
extends CharacterBody2D

@export var tile_map: TileMap
@onready var main: Node2D = $".."

@onready var on_hand_animation_player: AnimationPlayer = $OnHandAnimationPlayer
@onready var movement_animation_player: AnimationPlayer = $MovementAnimationPlayer

#Custom Components
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_component: AttackComponent = $AttackComponent

@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip

#State Machines
@onready var msm: FiniteStateMachine = $StateMachines/MovementStateMachine as FiniteStateMachine

#Movement States
@onready var player_idle_state: PlayerIdleState = (
	$StateMachines/MovementStateMachine/PlayerIdleState as PlayerIdleState
)
@onready var player_moving_state: PlayerMovingState = (
	$StateMachines/MovementStateMachine/PlayerMovingState as PlayerMovingState
)
@onready var player_swim_state: PlayerSwimState = (
	$StateMachines/MovementStateMachine/PlayerSwimState as PlayerSwimState
)
@onready var player_sit_state: PlayerSitState = (
	$StateMachines/MovementStateMachine/PlayerSitState as PlayerSitState
)

@onready var on_hand: Sprite2D = $OnHand
@onready var player_sprite: Sprite2D = $CharacterSprite

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

var turn_tween: Tween


func _physics_process(_delta: float) -> void:
	player_tile = tile_map.local_to_map(global_position)


var is_facing_right: bool = true:
	set(value):
		if value and is_facing_right != value:
			# Turn right
			turn_tween = get_tree().create_tween()
			(
				turn_tween
				. tween_property(player_sprite, "scale", Vector2(1, 1), 0.5)
				. set_trans(Tween.TRANS_CUBIC)
				. set_ease(Tween.EASE_OUT)
			)
			on_hand.flip_h = false
			on_hand.position.x = 7
			on_hand.offset.x = held_offset.x
		elif not value and is_facing_right != value:
			# Turn left
			turn_tween = get_tree().create_tween()
			(
				turn_tween
				. tween_property(player_sprite, "scale", Vector2(-1, 1), 0.5)
				. set_trans(Tween.TRANS_CUBIC)
				. set_ease(Tween.EASE_OUT)
			)
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
	if Input.is_action_just_pressed("debug_menu") and OS.has_feature("debug"):
		main.toggle_debug_menu()


func _ready() -> void:
	PlayerManager.player = self
	player_idle_state.player_moved.connect(msm.change_state.bind(player_moving_state))
	player_moving_state.player_stopped_moving.connect(msm.change_state.bind(player_idle_state))
	player_moving_state.player_entered_water.connect(msm.change_state.bind(player_swim_state))
	player_swim_state.player_exited_water.connect(msm.change_state.bind(player_moving_state))
	player_sit_state.player_exited.connect(msm.change_state.bind(player_idle_state))


#Returns move input as a Vector2
func get_input() -> Vector2:
	input.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return input.normalized()


func interact() -> void:
	for area in hitbox_component.get_overlapping_areas():
		if area.is_in_group("interactable"):
			area.owner.player_interact(self)


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


func melee_attack(attack: Attack) -> void:
	attack_cooldown_timer.start(attack.attack_cooldown)
	attack.attack_position = global_position
	attack_component.set_attack_range(attack.attack_range, is_facing_right)
	attack_component.attack(attack)
	if is_facing_right:
		on_hand_animation_player.play("melee_attack_right")
	else:
		on_hand_animation_player.play("melee_attack_left")


func ranged_attack(attack: Attack) -> void:
	attack_cooldown_timer.start(attack.attack_cooldown)


func place_object(object: PackedScene) -> void:
	var obj: Node2D = object.instantiate()
	obj.position = get_global_mouse_position()
	owner.add_child(obj)


func set_speed(speed: int) -> void:
	max_speed = speed


func display_on_hand(texture: Texture2D, _held_offset: Vector2) -> void:
	on_hand.texture = texture
	held_offset = _held_offset
	on_hand.offset = held_offset
	if not is_facing_right:
		on_hand.offset.x = -held_offset.x


func is_in_water() -> bool:
	var tile_data: TileData = tile_map.get_cell_tile_data(0, player_tile)
	if tile_data:
		return tile_data.get_custom_data("can_swim")
	else:
		return false
