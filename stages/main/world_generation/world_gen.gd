extends Node2D

@onready var player: Player = $"../Player"

#Noise
@export var noise_height_text: NoiseTexture2D
@export var noise_decoration_text: NoiseTexture2D
var noise: Noise
var decoration_noise: Noise

#Source ID
var source_id: int = 0

const tile_size: int = 16

#Layers
@onready var ground_1_layer: TileMapLayer = $Ground1
@onready var ground_2_layer: TileMapLayer = $Ground2
@onready var cliff_layer: TileMapLayer = $Cliff
@onready var environment_layer: TileMapLayer = $Environment

#Tiles
var water_atlas: Vector2i = Vector2i(8, 4)
var water_bubble_atlas_arr: Array = [Vector2i(28, 2), Vector2i(29, 2), Vector2i(30, 2), Vector2i(31, 2)]
var grass_blade_atlas_arr: Array = [Vector2i(0, 14), Vector2i(1, 14), Vector2i(2, 14), Vector2i(3, 14)]
var flower_atlas_arr: Array = [Vector2i(0, 12), Vector2i(4, 12), Vector2i(8, 12)]
var sand_decoration_atlas_arr: Array = [
	Vector2i(14, 10),
	Vector2i(15, 10),
	Vector2i(14, 11),
	Vector2i(15, 11),
	Vector2i(15, 12),
	Vector2i(16, 13),
	Vector2i(17, 13),
	Vector2i(18, 13),
	Vector2i(16, 14),
	Vector2i(17, 14),
	Vector2i(18, 14),
	Vector2i(15, 0),
	Vector2i(15, 1),
	Vector2i(15, 2),
	Vector2i(15, 3),
]
var terrain_sand_int: int = 0
var terrain_grass_int: int = 1

#Chunks
var player_chunk_pos: Vector2i
var loaded_chunks: PackedVector2Array = []
var view_distance: int = 1

@onready var chunks_node: Node2D = $Chunks

#Objects
const TREE: PackedScene = preload("res://entities/environment/trees/tree.tscn")
const ROCK: PackedScene = preload("res://entities/environment/rocks/rock.tscn")


func _ready() -> void:
	noise = noise_height_text.noise
	decoration_noise = noise_decoration_text.noise

	noise.seed = Global.world_data.world_seed
	decoration_noise.seed = Global.world_data.world_seed


func find_spawn_location() -> void:
	for x: int in range(500):
		for y: int in range(500):
			var noise_val: float = noise.get_noise_2d(x, y)
			if noise_val >= 0.7:
				player.main.teleport_player(map_to_local(Vector2i(x, y)))
				return
	push_error("Could not find a suitable spawn location.")


func generate_chunk(chunk: Vector2i, chunk_node: Node2D, chunk_entites_generated: bool) -> void:
	var sand_tiles_arr: PackedVector2Array = []
	var grass_tiles_arr: PackedVector2Array = []
	for _x: int in range(32):
		for _y: int in range(32):
			var x: int = _x + chunk.x * 32
			var y: int = _y + chunk.y * 32
			var noise_val: float = noise.get_noise_2d(x, y)
			var decoration_noise_val: float = decoration_noise.get_noise_2d(x, y)
			if noise_val >= 0.65:
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						var adj_tile: Vector2i = Vector2i(x + dx, y + dy)
						if not grass_tiles_arr.has(adj_tile):
							if is_in_chunk(chunk, adj_tile):
								grass_tiles_arr.append(adj_tile)
				if decoration_noise_val > 0.7 and not chunk_entites_generated:
					call_deferred("draw_object", TREE, map_to_local(Vector2i(x, y)), chunk_node)
				elif decoration_noise_val > 0.6 and not chunk_entites_generated:
					call_deferred("draw_object", ROCK, map_to_local(Vector2i(x, y)), chunk_node)
				elif decoration_noise_val > 0.5:
					environment_layer.call_deferred("set_cell", Vector2i(x, y), source_id, flower_atlas_arr.pick_random())
				elif decoration_noise_val > 0.4:
					environment_layer.call_deferred("set_cell", Vector2i(x, y), source_id, grass_blade_atlas_arr.pick_random())
			elif noise_val >= 0.6:
				for dx in range(-2, 3):
					for dy in range(-2, 3):
						var adj_tile: Vector2i = Vector2i(x + dx, y + dy)
						if not sand_tiles_arr.has(adj_tile):
							if is_in_chunk(chunk, adj_tile):
								sand_tiles_arr.append(adj_tile)
	# Places sand decoration tiles
	for tile: Vector2i in sand_tiles_arr:
		# Checks if sand tiles are overlapping grass tiles
		if not grass_tiles_arr.has(tile):
			var valid_tile: bool = true
			# Checks the edges
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					var adj_tile: Vector2i = Vector2i(tile.x + dx, tile.y + dy)
					if not sand_tiles_arr.has(adj_tile):
						valid_tile = false
			if valid_tile:
				var decoration_noise_val: float = decoration_noise.get_noise_2d(tile.x, tile.y)
				if decoration_noise_val > 0.5:
					environment_layer.call_deferred("set_cell", Vector2i(tile.x, tile.y), source_id, sand_decoration_atlas_arr.pick_random())
	# Fixes issue of grass tiles out of place and not next to sand
	# Causes some tile to be rendered outside of the chunk
	for tile: Vector2i in grass_tiles_arr:
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				var adj_tile: Vector2i = Vector2i(tile.x + dx, tile.y + dy)
				if not grass_tiles_arr.has(adj_tile) and not sand_tiles_arr.has(adj_tile):
					if not is_in_chunk(chunk, adj_tile):
						sand_tiles_arr.append(adj_tile)
	call_deferred("draw_tiles", chunk, sand_tiles_arr, grass_tiles_arr)


const WATER_TEXTURE = preload("res://common/shaders/water_texture/water_texture.tscn")


func get_chunk_node(chunk: Vector2i) -> Node2D:
	var chunk_node: Node2D = Node2D.new()
	chunk_node.name = str(chunk)
	chunk_node.y_sort_enabled = true
	chunk_node.z_as_relative = false
	chunks_node.add_child(chunk_node)
	var water_texture: Node2D = WATER_TEXTURE.instantiate()
	chunk_node.add_child(water_texture)
	water_texture.position = map_to_local(chunk * 32)
	return chunk_node


func draw_tiles(_chunk: Vector2i, _sand_tiles_arr: PackedVector2Array, _grass_tiles_arr: PackedVector2Array) -> void:
	ground_1_layer.set_cells_terrain_connect(_sand_tiles_arr, terrain_sand_int, 0)
	ground_2_layer.set_cells_terrain_connect(_grass_tiles_arr, terrain_grass_int, 0)


func draw_object(OBJ: PackedScene, pos: Vector2 = Vector2i(0, 0), child_node: Node2D = self) -> void:
	var obj: Node2D = OBJ.instantiate()
	child_node.add_child(obj)
	obj.position = pos


func is_in_chunk(chunk: Vector2i, tile_pos: Vector2i) -> bool:
	chunk = chunk * 32
	var chunk_end: Vector2i = chunk + Vector2i(32, 32)
	return tile_pos.x >= chunk.x and tile_pos.x < chunk_end.x and tile_pos.y >= chunk.y and tile_pos.y < chunk_end.y


func save_chunk_entities(chunk: Vector2i) -> void:
	Global.verify_save_directory(Global.world_save_file_path + Global.chunk_data_save_file_path)
	var saved_chunk: SavedChunk = SavedChunk.new()
	var chunk_node: Node2D = chunks_node.get_node(str(chunk))
	var saved_data: Array[SavedData] = []

	for child: Node2D in chunk_node.get_children():
		if child.has_method("on_save_chunk"):
			child.on_save_chunk(saved_data)
	saved_chunk.saved_data = saved_data
	ResourceSaver.save(saved_chunk, Global.world_save_file_path + Global.chunk_data_save_file_path + str(chunk) + ".res")


func chunk_save_exisits(chunk: Vector2i) -> bool:
	if not ResourceLoader.exists(Global.world_save_file_path + Global.chunk_data_save_file_path + str(chunk) + ".res"):
		return false
	else:
		return true


func load_chunk_entities(chunk: Vector2i) -> bool:
	var saved_chunk: SavedChunk = ResourceLoader.load(Global.world_save_file_path + Global.chunk_data_save_file_path + str(chunk) + ".res")
	var chunk_node: Node2D = get_chunk_node(chunk)
	for entity in saved_chunk.saved_data:
		var scene: PackedScene = load(entity.scene_path) as PackedScene
		var loaded_node: Node2D = scene.instantiate()
		if loaded_node.has_method("on_load_chunk"):
			loaded_node.on_load_chunk(entity)
		chunk_node.add_child(loaded_node)
	return true


func clear_chunk(chunk: Vector2i) -> void:
	for _x: int in range(32):
		for _y: int in range(32):
			var x: int = _x + chunk.x * 32
			var y: int = _y + chunk.y * 32
			ground_1_layer.set_cell(Vector2i(x, y), -1, Vector2i(-1, -1))
			ground_2_layer.set_cell(Vector2i(x, y), -1, Vector2i(-1, -1))
			cliff_layer.set_cell(Vector2i(x, y), -1, Vector2i(-1, -1))
			environment_layer.set_cell(Vector2i(x, y), -1, Vector2i(-1, -1))
	save_chunk_entities(chunk)
	chunks_node.get_node(str(chunk)).queue_free()


func unload_distant_chunks() -> void:
	var times_chunk_removed: int = 0
	for chunk: int in loaded_chunks.size():
		var _chunk: int = chunk - times_chunk_removed
		var dist_to_player: Vector2i = dist(Vector2i(loaded_chunks[_chunk]), player_chunk_pos)
		if (dist_to_player.x > view_distance or dist_to_player.y > view_distance) and _chunk <= loaded_chunks.size():
			clear_chunk(loaded_chunks[_chunk])
			loaded_chunks.remove_at(_chunk)
			times_chunk_removed += 1


func _process(_delta: float) -> void:
	player_chunk_pos = local_to_map(player.position) / 32
	for dx in range(-view_distance, view_distance + 1):
		for dy in range(-view_distance, view_distance + 1):
			var adj_chunk: Vector2i = Vector2i(player_chunk_pos.x + dx, player_chunk_pos.y + dy)
			try_to_generate_chunk(adj_chunk)


func try_to_generate_chunk(chunk: Vector2i) -> void:
	if loaded_chunks.has(chunk):
		return
	loaded_chunks.append(chunk)
	var chunk_entites_generated: bool = false
	var chunk_node: Node2D
	if chunk_save_exisits(chunk):
		chunk_entites_generated = true
		load_chunk_entities(chunk)
		chunk_node = chunks_node.get_node(str(chunk))
	else:
		chunk_node = get_chunk_node(chunk)
	var task: TaskManager.Task = TaskManager.create_task(generate_chunk.bind(chunk, chunk_node, chunk_entites_generated))
	await task.completed
	task.is_completed()
	unload_distant_chunks()


func dist(p1: Vector2i, p2: Vector2i) -> Vector2i:
	var distance: Vector2i = p1 - p2
	if distance.x < 0:
		distance.x = distance.x * -1
	if distance.y < 0:
		distance.y = distance.y * -1
	return distance


func map_to_local(tile_pos: Vector2i) -> Vector2:
	return tile_pos * tile_size


func local_to_map(pos: Vector2) -> Vector2i:
	return pos / tile_size
