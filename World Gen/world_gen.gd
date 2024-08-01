extends TileMap

@onready var player: Player = $"../Player"

#Noise
@export var noise_height_text: NoiseTexture2D
@export var noise_decoration_text: NoiseTexture2D
var noise: Noise
var decoration_noise: Noise

#Source ID
var source_id: int = 0

#Layers
var number_of_layers: int = 5

var water_layer: int = 0
var ground_1_layer: int = 1
var ground_2_layer: int = 2
var cliff_layer: int = 3
var environment_layer: int = 4

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
	Vector2i(15, 3)
]
var terrain_sand_int: int = 0
var terrain_grass_int: int = 1

#Chunks
var player_chunk_pos: Vector2i
var loaded_chunks: PackedVector2Array = []
var view_distance: int = 1

#Objects
const TREE = preload("res://Scenes/Objects/tree.tscn")
const ROCK = preload("res://Scenes/Objects/rock.tscn")


func _ready() -> void:
	noise = noise_height_text.noise
	decoration_noise = noise_decoration_text.noise

	noise.seed = Global.worldData.world_seed
	decoration_noise.seed = Global.worldData.world_seed


func find_spawn_location() -> void:
	for x: int in range(500):
		for y: int in range(500):
			var noise_val: float = noise.get_noise_2d(x, y)
			if noise_val >= 0.7:
				player.global_position = map_to_local(Vector2i(x, y))
				print(player.global_position)
				return
	push_error("Could not find a suitable spawn location.")


func generate_chunk(chunk: Vector2i, chunk_node: Node2D) -> void:
	var sand_tiles_arr: PackedVector2Array = []
	var grass_tiles_arr: PackedVector2Array = []
	var water_tiles_arr: PackedVector2Array = []
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
				if decoration_noise_val > 0.7:
					call_deferred("draw_object", TREE, map_to_local(Vector2i(x, y)), chunk_node)
				elif decoration_noise_val > 0.6:
					call_deferred("draw_object", ROCK, map_to_local(Vector2i(x, y)), chunk_node)
				elif decoration_noise_val > 0.5:
					call_deferred("set_cell", environment_layer, Vector2i(x, y), source_id, flower_atlas_arr.pick_random())
				elif decoration_noise_val > 0.4:
					call_deferred("set_cell", environment_layer, Vector2i(x, y), source_id, grass_blade_atlas_arr.pick_random())
			elif noise_val >= 0.6:
				for dx in range(-2, 3):
					for dy in range(-2, 3):
						var adj_tile: Vector2i = Vector2i(x + dx, y + dy)
						if not sand_tiles_arr.has(adj_tile):
							if is_in_chunk(chunk, adj_tile):
								sand_tiles_arr.append(adj_tile)
			else:
				water_tiles_arr.append(Vector2i(x, y))
	#Checks if water tiles are overlapping grass or sand tiles
	var times_water_removed: int = 0
	for tile: int in water_tiles_arr.size():
		var _tile: int = tile - times_water_removed
		var x: int = int(water_tiles_arr[_tile].x)
		var y: int = int(water_tiles_arr[_tile].y)
		var decoration_noise_val: float = decoration_noise.get_noise_2d(x, y)
		if (sand_tiles_arr.has(water_tiles_arr[_tile]) or grass_tiles_arr.has(water_tiles_arr[_tile])) and _tile <= water_tiles_arr.size():
			water_tiles_arr.remove_at(_tile)
			times_water_removed += 1
		else:
			if decoration_noise_val > 0.8:
				call_deferred("set_cell", environment_layer, Vector2i(x, y), source_id, water_bubble_atlas_arr.pick_random())
	#Checks if sand tiles are overlapping grass tiles
	for tile: Vector2i in sand_tiles_arr:
		if not grass_tiles_arr.has(tile):
			var valid_tile: bool = true
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					var adj_tile: Vector2i = Vector2i(tile.x + dx, tile.y + dy)
					if not sand_tiles_arr.has(adj_tile):
						valid_tile = false
			if valid_tile:
				var x: int = tile.x
				var y: int = tile.y
				var decoration_noise_val: float = decoration_noise.get_noise_2d(x, y)
				if decoration_noise_val > 0.5:
					call_deferred("set_cell", environment_layer, Vector2i(x, y), source_id, sand_decoration_atlas_arr.pick_random())
	call_deferred("draw_tiles", water_tiles_arr, sand_tiles_arr, grass_tiles_arr)


func get_chunk_node(chunk: Vector2i) -> Node2D:
	var chunk_node: Node2D = Node2D.new()
	chunk_node.name = str(chunk)
	chunk_node.y_sort_enabled = true
	chunk_node.z_as_relative = false
	add_child(chunk_node)
	return chunk_node


func draw_tiles(_water_tiles_arr: PackedVector2Array, _sand_tiles_arr: PackedVector2Array, _grass_tiles_arr: PackedVector2Array) -> void:
	for tile: Vector2i in _water_tiles_arr:
		set_cell(water_layer, tile, source_id, water_atlas)
	set_cells_terrain_connect(ground_1_layer, _sand_tiles_arr, terrain_sand_int, 0)
	set_cells_terrain_connect(ground_2_layer, _grass_tiles_arr, terrain_grass_int, 0)


func draw_object(OBJ: PackedScene, pos: Vector2 = Vector2i(0, 0), child_node: Node2D = self) -> void:
	var obj: Node2D = OBJ.instantiate()
	child_node.add_child(obj)
	obj.position = pos


func is_in_chunk(chunk: Vector2i, tile_pos: Vector2i) -> bool:
	chunk = chunk * 32
	var chunk_end: Vector2i = chunk + Vector2i(32, 32)
	return tile_pos.x >= chunk.x and tile_pos.x < chunk_end.x and tile_pos.y >= chunk.y and tile_pos.y < chunk_end.y


func clear_chunk(chunk: Vector2i) -> void:
	for _x: int in range(32):
		for _y: int in range(32):
			var x: int = _x + chunk.x * 32
			var y: int = _y + chunk.y * 32
			for layer: int in number_of_layers:
				set_cell(layer, Vector2i(x, y), -1, Vector2i(-1, -1))
	get_node(str(chunk)).queue_free()


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
	var chunk_node: Node2D = get_chunk_node(chunk)
	var task: TaskManager.Task = TaskManager.create_task(generate_chunk.bind(chunk, chunk_node))
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
