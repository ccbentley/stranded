class_name Player
extends CharacterBody2D

@onready var player_sprite: Sprite2D = $CharacterSprite

@onready var main: Node2D = $".."
@export var tile_map: Node2D

@onready var on_hand_animation_player: AnimationPlayer = $OnHandAnimationPlayer
@onready var movement_animation_player: AnimationPlayer = $MovementAnimationPlayer

# Custom Components
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_component: AttackComponent = $AttackComponent

# Inventory
@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip
signal toggle_inventory

# State Machine
@onready var player_state: FiniteStateMachine = $StateMachines/MovementStateMachine as FiniteStateMachine

# States
@onready var player_idle_state: PlayerIdleState = $StateMachines/MovementStateMachine/PlayerIdleState as PlayerIdleState
@onready var player_moving_state: PlayerMovingState = $StateMachines/MovementStateMachine/PlayerMovingState as PlayerMovingState
@onready var player_swim_state: PlayerSwimState = $StateMachines/MovementStateMachine/PlayerSwimState as PlayerSwimState
@onready var player_sit_state: PlayerSitState = $StateMachines/MovementStateMachine/PlayerSitState as PlayerSitState

# On hand
@onready var on_hand: Sprite2D = $OnHand
var held_item: Node2D = null

#Timers
@onready var attack_cooldown_timer: Timer = $AttackCooldown

# Movement
var input: Vector2 = Vector2.ZERO

var can_move: bool = true

const accel: int = 1500
const friction: int = 1000

const MOVE_SPEED: int = 90
const SWIM_SPEED: int = 50

var move_speed: int:
	get:
		if can_move:
			if player_state.state == player_swim_state:
				return SWIM_SPEED
			else:
				return MOVE_SPEED
		return 0

# Tiles
var player_tile_pos: Vector2i

enum PlayerTile {
	WATER,
	SAND,
	GRASS,
}

var player_tile_type: int = PlayerTile.GRASS


func _physics_process(_delta: float) -> void:
	player_tile_pos = tile_map.local_to_map(position)
	if is_on_grass():
		player_tile_type = PlayerTile.GRASS
	elif is_on_sand():
		player_tile_type = PlayerTile.SAND
	else:
		player_tile_type = PlayerTile.WATER


var is_facing_right: bool = true:
	set(value):
		if value and is_facing_right != value:
			# Turn right
			var turn_tween: Tween = get_tree().create_tween()
			turn_tween.tween_property(player_sprite, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			on_hand.scale.x = abs(on_hand.scale.x)
			on_hand.position.x = abs(on_hand.position.x)
		elif not value and is_facing_right != value:
			# Turn left
			var turn_tween: Tween = get_tree().create_tween()
			turn_tween.tween_property(player_sprite, "scale", Vector2(-1, 1), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			on_hand.scale.x = -abs(on_hand.scale.x)
			on_hand.position.x = -abs(on_hand.position.x)
		is_facing_right = value


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()
	if Input.is_action_just_pressed("zoom_in"):
		main.zoom_in()
	if Input.is_action_just_pressed("zoom_out"):
		main.zoom_out()
	if Input.is_action_just_pressed("debug_menu") and OS.has_feature("debug"):
		main.toggle_debug_menu()


func _input(_event: InputEvent) -> void:
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
	player_idle_state.player_moved.connect(player_state.change_state.bind(player_moving_state))
	player_moving_state.player_stopped_moving.connect(player_state.change_state.bind(player_idle_state))
	player_moving_state.player_entered_water.connect(player_state.change_state.bind(player_swim_state))
	player_swim_state.player_exited_water.connect(player_state.change_state.bind(player_moving_state))
	player_sit_state.player_exited.connect(player_state.change_state.bind(player_moving_state))


#Returns move input as a Vector2
func get_input() -> Vector2:
	input.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return input.normalized()


func interact() -> void:
	if not player_state.state == player_sit_state:
		for area in hitbox_component.get_overlapping_areas():
			if area.is_in_group("interactable"):
				area.owner.player_interact(self)
				return


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
	AudioManager.play_sound(load("res://assets/sounds/woosh.wav"), 0, true)
	can_move = false
	if player_state.state == player_moving_state:
		movement_animation_player.play("idle")
	await get_tree().create_timer(0.4).timeout
	if player_state.state == player_moving_state:
		movement_animation_player.play("move")
	can_move = true


func ranged_attack(attack: Attack) -> void:
	attack_cooldown_timer.start(attack.attack_cooldown)


func place_object(object: PackedScene, pos: Vector2) -> void:
	var obj: Node2D = object.instantiate()
	obj.position = pos
	owner.add_child(obj)


func get_tile_data(pos: Vector2i) -> int:
	var grass_tile_data: TileData = tile_map.ground_2_layer.get_cell_tile_data(pos)
	var sand_tile_data: TileData = tile_map.ground_1_layer.get_cell_tile_data(pos)
	if grass_tile_data:
		return PlayerTile.GRASS
	elif sand_tile_data:
		return PlayerTile.SAND
	else:
		return PlayerTile.WATER


func hold_item(item_scene: PackedScene) -> void:
	for child: Node2D in on_hand.get_children():
		child.queue_free()
	if item_scene:
		var item_node: Node2D = item_scene.instantiate()
		on_hand.add_child(item_node)
		held_item = item_node


func is_on_sand() -> bool:
	var tile_data: TileData = tile_map.ground_1_layer.get_cell_tile_data(player_tile_pos)
	if tile_data:
		return true
	else:
		return false


func is_on_grass() -> bool:
	var tile_data: TileData = tile_map.ground_2_layer.get_cell_tile_data(player_tile_pos)
	if tile_data:
		return true
	else:
		return false


func use_item(index: int) -> void:
	held_item.use(index)


func _on_health_component_damaged(_prev_health: float, _health: float) -> void:
	main.vignette.pulse_vignette(Color.RED)
