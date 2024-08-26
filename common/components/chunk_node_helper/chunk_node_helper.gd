extends Node2D
class_name ChunkNodeHelper

@onready var actor: Node2D = get_parent()
@onready var tile_map: Node2D = WorldManager.world.tile_map

var chunk_position: Vector2i:
	set(value):
		if chunk_position != value:
			chunk_position = value
			actor.reparent(tile_map.chunks_node.get_node(str(chunk_position)))


func _process(_delta: float) -> void:
	chunk_position = tile_map.local_to_map(global_position) / 32
