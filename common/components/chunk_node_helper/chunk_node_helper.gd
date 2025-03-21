@icon("icon.svg")
extends Node2D
class_name ChunkNodeHelper

@onready var actor: Node2D = get_parent()
@onready var tile_map: Node2D = WorldManager.world.tile_map

var chunk_position: Vector2i:
	set(value):
		if chunk_position != value:
			chunk_position = value
			if tile_map.chunks_node.get_node_or_null(str(chunk_position)):
				actor.reparent(tile_map.chunks_node.get_node(str(chunk_position)))


func _process(_delta: float) -> void:
	var _chunk_position: Vector2i = tile_map.local_to_map(global_position) / 32
	if global_position.x < 0:
		_chunk_position.x -= 1
	if global_position.y < 0:
		_chunk_position.y -= 1
	chunk_position = _chunk_position
