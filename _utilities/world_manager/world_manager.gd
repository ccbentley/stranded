extends Node

var world: Node2D


func spawn_pickup(slot_data: SlotData, pos: Vector2) -> void:
	world.spawn_pickup(slot_data, pos)
