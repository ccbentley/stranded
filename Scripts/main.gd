extends Node2D

const PickUp = preload("res://Item/Pickup/pickup.tscn")

@onready var player : CharacterBody2D = $Player
@onready var inventory_interface : Control = $UI/InventoryInterface
@onready var hot_bar_inventory: PanelContainer = $UI/HotBarInventory

const save_file_path: String = "user://save/"
const player_save_file_name: String = "PlayerSave.tres"
const world_save_file_name: String = "WorldData.tres"
var world_save_file_path: String = save_file_path + Global.worldData.world_name + "/"
var playerData: PlayerData = PlayerData.new()

@export var noise_height_text : NoiseTexture2D
var noise : Noise
var width : int = 400
var height : int = 400
@onready var tile_map: TileMap = $TileMap
var source_id : int = 0

#Layers
var water_layer : int = 0
var ground_1_layer : int = 1
var ground_2_layer : int = 2
var cliff_layer : int = 3
var environment_layer : int = 4

var water_atlas : Vector2i = Vector2i(8, 4)
var land_atlas : Vector2i = Vector2i(1, 1)
var sand_tiles_arr : Array = []
var grass_tiles_arr : Array = []
var terrain_sand_int : int = 0
var terrain_grass_int : int = 1

func _ready() -> void:
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.force_close.connect(toggle_inventory_interface)

	load_inventory()

	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

	verify_save_directory(world_save_file_path)
	noise = noise_height_text.noise
	generate_world()

func generate_world() -> void:
	var expanded_sand_tiles_arr : Array = []
	var expanded_grass_tiles_arr : Array = []
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			var noise_val : float = noise.get_noise_2d(x, y)
			if noise_val > 0.3:
				sand_tiles_arr.append(Vector2i(x, y))
				# Add adjacent tiles to expanded_sand_tiles_arr
				for dx in range(-2, 3):
					for dy in range(-2, 3):
						var adj_tile = Vector2i(x + dx, y + dy)
						if not expanded_sand_tiles_arr.has(adj_tile):
							expanded_sand_tiles_arr.append(adj_tile)
			if noise_val > 0.4:
				grass_tiles_arr.append(Vector2i(x, y))
				# Add adjacent tiles to expanded_grass_tiles_arr
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						var adj_tile = Vector2i(x + dx, y + dy)
						if not expanded_grass_tiles_arr.has(adj_tile):
							expanded_grass_tiles_arr.append(adj_tile)
			else:
				if not expanded_sand_tiles_arr.has(Vector2i(x, y)) and not expanded_grass_tiles_arr.has(Vector2i(x, y)):
					tile_map.set_cell(water_layer, Vector2(x, y), source_id, water_atlas)

	tile_map.set_cells_terrain_connect(ground_1_layer, expanded_sand_tiles_arr, terrain_sand_int, 0)
	tile_map.set_cells_terrain_connect(ground_2_layer, expanded_grass_tiles_arr, terrain_grass_int, 0)

func load_inventory():
	inventory_interface.set_player_inventory_data(player.inventory_data)
	inventory_interface.set_equip_inventory_data(player.equip_inventory_data)
	hot_bar_inventory.set_inventory_data(player.inventory_data)

func toggle_inventory_interface(external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible

	if inventory_interface.visible:
		hot_bar_inventory.hide()
	else:
		hot_bar_inventory.show()

	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()

func _on_inventory_interface_drop_slot_data(slot_data: SlotData) -> void:
	var pick_up = PickUp.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = player.get_drop_position()
	add_child(pick_up)

func verify_save_directory(path: String) -> void:
	DirAccess.make_dir_absolute(path)

func save_game() -> void:
	playerData.inventory_data = player.inventory_data.duplicate()
	playerData.equip_inventory_data = player.equip_inventory_data.duplicate()

	playerData.position = player.global_position

	ResourceSaver.save(playerData, world_save_file_path + player_save_file_name)
	print("Player Data Saved To " + world_save_file_path)

func load_game() -> void:
	playerData = ResourceLoader.load(world_save_file_path + player_save_file_name).duplicate(true)
	player.inventory_data = playerData.inventory_data
	player.equip_inventory_data = playerData.equip_inventory_data
	load_inventory()

	player.global_position = playerData.position

	print("Player Data Loaded From " + world_save_file_path)
