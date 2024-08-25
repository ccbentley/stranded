extends CharacterBody2D
class_name Boat

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var water_trail: Node2D = $WaterTrail

@onready var state_machine: FiniteStateMachine = $StateMachine
@onready var boat_idle_state: BoatIdleState = $StateMachine/BoatIdleState as BoatIdleState
@onready var boat_move_state: BoatMoveState = $StateMachine/BoatMoveState as BoatMoveState

@onready var player: Player = PlayerManager.player

enum TileType { WATER, SAND, GRASS }
var tile_type: int = TileType.WATER

var water_boat_speed: int = 150
var land_boat_speed: int = 25
var boat_speed: int

var friction: int = 100
var accel: int = 100

var turn_tween: Tween

var is_facing_right: bool = true:
	set(value):
		if value and is_facing_right != value:
			turn_tween = get_tree().create_tween()
			turn_tween.tween_property(sprite_2d, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		elif not value and is_facing_right != value:
			turn_tween = get_tree().create_tween()
			turn_tween.tween_property(sprite_2d, "scale", Vector2(-1, 1), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		is_facing_right = value


func _ready() -> void:
	animation_player.play("spawn")
	boat_move_state.player_exited.connect(state_machine.change_state.bind(boat_idle_state))


func player_interact(_player: Player) -> void:
	player.msm.change_state(player.player_sit_state)
	state_machine.change_state(boat_move_state)
	player.is_facing_right = true
	player.z_index = 1


func _physics_process(_delta: float) -> void:
	if is_on_grass():
		tile_type = TileType.GRASS
	elif is_on_sand():
		tile_type = TileType.SAND
	else:
		tile_type = TileType.WATER

	if tile_type == TileType.WATER:
		water_trail.visible = true
	else:
		water_trail.visible = false


func is_on_sand() -> bool:
	var tile_data: TileData = player.tile_map.ground_1_layer.get_cell_tile_data(player.tile_map.local_to_map(position))
	if tile_data:
		return true
	else:
		return false


func is_on_grass() -> bool:
	var tile_data: TileData = player.tile_map.ground_2_layer.get_cell_tile_data(player.tile_map.local_to_map(position))
	if tile_data:
		return true
	else:
		return false


func _on_health_component_died() -> void:
	player.msm.change_state(player.player_idle_state)
	player.z_index = 0

func on_save_chunk(saved_data: Array[SavedData]) -> void:
	if $HealthComponent.health <= 0:
		return
	var entity_data: SavedData = SavedData.new()
	entity_data.position = global_position
	entity_data.scene_path = scene_file_path

	saved_data.append(entity_data)


func on_load_chunk(saved_data: SavedData) -> void:
	global_position = saved_data.position
