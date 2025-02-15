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
@onready var on_hand: Marker2D = $OnHand
@onready var hand_point: Node2D = $OnHand/HandPoint
var held_item: Node2D = null

# Movement
var input: Vector2 = Vector2.ZERO

var can_move: bool = true

const accel: int = 1500
const friction: int = 1000

const MOVE_SPEED: int = 70
const SWIM_SPEED: int = 40

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

signal temp_changed
const STARTING_TEMP: int = 25
var temp: int = STARTING_TEMP:
	set(value):
		temp = value
		temp_changed.emit()

signal hunger_updated
@onready var starve_damage_timer: Timer = $StarveDamageTimer

const MAX_HUNGER: float = 100
const MAX_SATURATION: float = 25

var hunger: float = MAX_HUNGER:
	set(value):
		hunger = clamp(value, 0, MAX_HUNGER)
		hunger_updated.emit()

var saturation: float = MAX_SATURATION:
	set(value):
		saturation = clamp(value, 0, MAX_SATURATION)


func decrase_hunger(value: float) -> void:
	if saturation > 0:
		saturation -= value
	else:
		hunger -= value

	if hunger <= 0 and starve_damage_timer.is_stopped():
		starve_damage_timer.start()


func _on_starve_damage_timer_timeout() -> void:
	if hunger > 0:
		starve_damage_timer.stop()
		return
	var attack: Attack = Attack.new()
	attack.attack_damage = 1
	health_component.damage(attack)


func _process(_delta: float) -> void:
	on_hand_rotation()


func _physics_process(_delta: float) -> void:
	move_and_slide()
	player_tile_pos = tile_map.local_to_map(position)
	if is_on_grass():
		player_tile_type = PlayerTile.GRASS
	elif is_on_sand():
		player_tile_type = PlayerTile.SAND
	else:
		player_tile_type = PlayerTile.WATER


func on_hand_rotation() -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	on_hand.look_at(mouse_position)
	if mouse_position.x - global_position.x < 0:
		on_hand.scale.y = -1
	else:
		on_hand.scale.y = 1


var is_facing_right: bool = true:
	set(value):
		if value and is_facing_right != value:
			# Turn right
			var turn_tween: Tween = get_tree().create_tween()
			turn_tween.tween_property(player_sprite, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		elif not value and is_facing_right != value:
			# Turn left
			var turn_tween: Tween = get_tree().create_tween()
			turn_tween.tween_property(player_sprite, "scale", Vector2(-1, 1), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		is_facing_right = value


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("quests"):
		main.toggle_quests()
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

	health_component.died.connect(on_health_component_died)


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
	for child: Node2D in hand_point.get_children():
		child.queue_free()
	if item_scene:
		var item_node: Node2D = item_scene.instantiate()
		hand_point.add_child(item_node)
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


func on_health_component_died() -> void:
	main.display_death_screen()


func increase_temp(value: int) -> void:
	temp += value
