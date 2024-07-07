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
@export var noise_tree_text : NoiseTexture2D
var noise : Noise
var tree_noise : Noise
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

const TREE = preload("res://Scenes/Objects/tree.tscn")

var player_chunk_pos
var loaded_chunks = []
var view_distance = 2

func _ready() -> void:
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.force_close.connect(toggle_inventory_interface)

	load_inventory()

	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

	verify_save_directory(world_save_file_path)

	noise = noise_height_text.noise
	tree_noise = noise_tree_text.noise

	noise.seed = Global.worldData.world_seed
	tree_noise.seed = randi()

	save_game()

func generate_world() -> void:
	for x in view_distance:
		for y in view_distance:
			generate_chunk(x, y)

func generate_chunk(x_chunk, y_chunk) -> void:
	#Checks if chunk is already generated
	if loaded_chunks.has(Vector2i(x_chunk, y_chunk)):
		return
	if not loaded_chunks.has(Vector2i(x_chunk, y_chunk)):
		loaded_chunks.append(Vector2i(x_chunk, y_chunk))
	var expanded_sand_tiles_arr : Array = []
	var expanded_grass_tiles_arr : Array = []
	for _x in range(32):
		for _y in range(32):
			var x = _x + x_chunk * 32
			var y = _y + y_chunk * 32
			var noise_val : float = noise.get_noise_2d(x, y)
			var tree_noise_val : float = tree_noise.get_noise_2d(x, y)
			if noise_val > 0.3:
				sand_tiles_arr.append(Vector2i(x, y))
				# Add adjacent tiles to expanded_sand_tiles_arr
				for dx in range(-2, 3):
					for dy in range(-2, 3):
						var adj_tile = Vector2i(x + dx, y + dy)
						if not expanded_sand_tiles_arr.has(adj_tile) and is_in_chunk(Vector2i(x_chunk, y_chunk), adj_tile):
							expanded_sand_tiles_arr.append(adj_tile)
			if noise_val > 0.4:
				grass_tiles_arr.append(Vector2i(x, y))
				# Add adjacent tiles to expanded_grass_tiles_arr
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						var adj_tile = Vector2i(x + dx, y + dy)
						if not expanded_grass_tiles_arr.has(adj_tile) and is_in_chunk(Vector2i(x_chunk, y_chunk), adj_tile):
							expanded_grass_tiles_arr.append(adj_tile)
				if tree_noise_val > 0.6:
					var tree_obj = TREE.instantiate()
					$Trees.add_child(tree_obj)
					tree_obj.position = tile_map.map_to_local(Vector2i(x, y))
			else:
				if not expanded_sand_tiles_arr.has(Vector2i(x, y)) and not expanded_grass_tiles_arr.has(Vector2i(x, y)):
					tile_map.set_cell(water_layer, Vector2(x, y), source_id, water_atlas)
	tile_map.set_cells_terrain_connect(ground_1_layer, expanded_sand_tiles_arr, terrain_sand_int, 0)
	tile_map.set_cells_terrain_connect(ground_2_layer, expanded_grass_tiles_arr, terrain_grass_int, 0)

func is_in_chunk(chunk : Vector2i, tile_pos: Vector2i) -> bool:
	#Calculate the bottom-right corner of the chunk
	chunk = chunk * 32
	var chunk_end = chunk + Vector2i(32, 32)
	# Check if the position is within the chunk boundaries
	return tile_pos.x >= chunk.x and tile_pos.x < chunk_end.x and tile_pos.y >= chunk.y and tile_pos.y < chunk_end.y

func clear_chunk(x_chunk, y_chunk) -> void:
	for _x in range(32):
		for _y in range(32):
			var x = _x + x_chunk * 32
			var y = _y + y_chunk * 32
			tile_map.set_cell(water_layer, Vector2i(x, y), -1, Vector2i(-1, -1))
			tile_map.set_cell(ground_1_layer, Vector2i(x, y), -1, Vector2i(-1, -1))
			tile_map.set_cell(ground_2_layer, Vector2i(x, y), -1, Vector2i(-1, -1))
			tile_map.set_cell(cliff_layer, Vector2i(x, y), -1, Vector2i(-1, -1))
			tile_map.set_cell(environment_layer, Vector2i(x, y), -1, Vector2i(-1, -1))

func unload_distant_chunks(player_pos) -> void:
	var unload_dist = view_distance
	for chunk in loaded_chunks:
		var dist_to_player = dist(chunk, player_chunk_pos)
		if dist_to_player.x > unload_dist or dist_to_player.y > unload_dist:
			clear_chunk(chunk.x, chunk.y)
			loaded_chunks.erase(chunk)

func _process(delta: float) -> void:
	player_chunk_pos = tile_map.local_to_map(player.position) / 32
	for dx in range(-view_distance, 2):
		for dy in range(-view_distance, 2):
			var adj_chunk = Vector2i(player_chunk_pos.x + dx, player_chunk_pos.y + dy)
			generate_chunk(adj_chunk.x, adj_chunk.y)
	unload_distant_chunks(player_chunk_pos)

func dist(p1, p2):
	var d = p1 - p2
	if d < Vector2i.ZERO:
		d = d * -1
	return d

func load_inventory() -> void:
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

func zoom_in() -> void:
	$PhantomCamera2D.zoom += Vector2(0.5, 0.5)
func zoom_out() -> void:
	$PhantomCamera2D.zoom -= Vector2(0.5, 0.5)
