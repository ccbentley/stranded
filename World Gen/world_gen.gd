extends TileMap

@onready var player: Player = $"../Player"

#Noise
@export var noise_height_text : NoiseTexture2D
@export var noise_tree_text : NoiseTexture2D
@export var noise_water_text : NoiseTexture2D
var noise : Noise
var tree_noise : Noise
var water_noise : Noise

#Source ID
var source_id : int = 0

#Layers
var water_layer : int = 0
var ground_1_layer : int = 1
var ground_2_layer : int = 2
var cliff_layer : int = 3
var environment_layer : int = 4

#Tiles
var water_atlas : Vector2i = Vector2i(8, 4)
var sand_tiles_arr : PackedVector2Array = []
var grass_tiles_arr : PackedVector2Array = []
var water_tiles_arr : PackedVector2Array = []
var water_bubble_atlas_arr : Array = [Vector2i(28,2), Vector2i(29,2), Vector2i(30,2), Vector2i(31,2)]
var terrain_sand_int : int = 0
var terrain_grass_int : int = 1
var terrain_water_int : int = 2

#Chunks
var player_chunk_pos : Vector2i
var loaded_chunks : PackedVector2Array = []
var view_distance : int = 1

#Objects
const TREE = preload("res://Scenes/Objects/tree.tscn")

func _ready() -> void:
	noise = noise_height_text.noise
	tree_noise = noise_tree_text.noise
	water_noise = noise_water_text.noise

	noise.seed = Global.worldData.world_seed
	tree_noise.seed = randi()
	water_noise.seed = randi()

func generate_chunk(x_chunk, y_chunk) -> void:
	for _x in range(32):
		for _y in range(32):
			var x = _x + x_chunk * 32
			var y = _y + y_chunk * 32
			var noise_val : float = noise.get_noise_2d(x, y)
			var tree_noise_val : float = tree_noise.get_noise_2d(x, y)
			var water_noise_val : float = water_noise.get_noise_2d(x, y)
			if noise_val >= 0.4:
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						var adj_tile = Vector2i(x + dx, y + dy)
						if not grass_tiles_arr.has(adj_tile):
							if is_in_chunk(Vector2i(x_chunk, y_chunk), adj_tile):
								grass_tiles_arr.append(adj_tile)
								if tree_noise_val > 0.7:
									call_deferred("draw_tree", map_to_local(Vector2i(x, y)))
			elif noise_val >= 0.3:
				for dx in range(-2, 3):
					for dy in range(-2, 3):
						var adj_tile = Vector2i(x + dx, y + dy)
						if not sand_tiles_arr.has(adj_tile):
							if is_in_chunk(Vector2i(x_chunk, y_chunk), adj_tile):
								sand_tiles_arr.append(adj_tile)
			else:
				if not sand_tiles_arr.has(Vector2i(x, y)) and not grass_tiles_arr.has(Vector2i(x, y)):
					water_tiles_arr.append(Vector2i(x, y))
					if water_noise_val > 0.8:
						call_deferred("set_cell", environment_layer, Vector2i(x, y), source_id, water_bubble_atlas_arr.pick_random())
	call_deferred("draw_tiles", water_tiles_arr, sand_tiles_arr, grass_tiles_arr)

func draw_tiles(_water_tiles_arr, _sand_tiles_arr, _grass_tiles_arr) -> void:
	for tile in _water_tiles_arr:
		set_cell(water_layer, tile, source_id, water_atlas)
	set_cells_terrain_connect(ground_1_layer, _sand_tiles_arr, terrain_sand_int, 0)
	set_cells_terrain_connect(ground_2_layer, _grass_tiles_arr, terrain_grass_int, 0)

func draw_tree(pos: Vector2i) -> void:
	var tree_obj = TREE.instantiate()
	$Trees.add_child(tree_obj)
	tree_obj.position = pos

func is_in_chunk(chunk : Vector2i, tile_pos: Vector2i) -> bool:
	chunk = chunk * 32
	var chunk_end = chunk + Vector2i(32, 32)
	return tile_pos.x >= chunk.x and tile_pos.x < chunk_end.x and tile_pos.y >= chunk.y and tile_pos.y < chunk_end.y

func clear_chunk(x_chunk, y_chunk) -> void:
	for _x in range(32):
		for _y in range(32):
			var x = _x + x_chunk * 32
			var y = _y + y_chunk * 32
			set_cell(water_layer, Vector2i(x, y), -1, Vector2i(-1, -1))
			set_cell(ground_1_layer, Vector2i(x, y), -1, Vector2i(-1, -1))
			set_cell(ground_2_layer, Vector2i(x, y), -1, Vector2i(-1, -1))
			set_cell(cliff_layer, Vector2i(x, y), -1, Vector2i(-1, -1))
			set_cell(environment_layer, Vector2i(x, y), -1, Vector2i(-1, -1))

func unload_distant_chunks(player_pos) -> void:
	for chunk in loaded_chunks.size():
		var dist_to_player = dist(Vector2i(loaded_chunks[chunk]), player_chunk_pos)
		if dist_to_player.x > view_distance or dist_to_player.y > view_distance:
			clear_chunk(loaded_chunks[chunk].x, loaded_chunks[chunk].y)
			loaded_chunks.remove_at(chunk)

func _process(delta: float) -> void:
	player_chunk_pos = local_to_map(player.position) / 32
	for dx in range(-view_distance, view_distance + 1):
		for dy in range(-view_distance, view_distance + 1):
			var adj_chunk = Vector2i(player_chunk_pos.x + dx, player_chunk_pos.y + dy)
			try_to_generate_chunk(adj_chunk)

func try_to_generate_chunk(chunk: Vector2i) -> void:
	if loaded_chunks.has(Vector2i(chunk.x, chunk.y)):
		return
	else:
		loaded_chunks.append(chunk)
		var task := TaskManager.create_task(generate_chunk.bind(chunk.x, chunk.y))
		if task:
			await task.completed
			task.is_completed()
	#unload_distant_chunks(player_chunk_pos)

func dist(p1, p2):
	var distance = p1 - p2
	if distance.x < 0:
		distance.x = distance.x * -1
	if distance.y < 0:
		distance.y = distance.y * -1
	return distance
