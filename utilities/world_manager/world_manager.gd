extends Node

var world: Node2D

const PICKUP: PackedScene = preload("res://common/item/pickup/pickup.tscn")

const freeze_slow: float = 0.07
const freeze_time: float = 0.15


func spawn_pickup(slot_data: SlotData, pos: Vector2) -> void:
	var pickup_instance: Pickup = PICKUP.instantiate()
	pickup_instance.slot_data = slot_data
	world.entities.call_deferred("add_child", pickup_instance)
	pickup_instance.position = pos


func spawn_entity(packed_scene: PackedScene, pos: Vector2) -> Node2D:
	var entity_instance: Node2D = packed_scene.instantiate()
	world.entities.add_child(entity_instance)
	entity_instance.position = pos
	return entity_instance


func freeze_engine() -> void:
	Engine.time_scale = freeze_slow
	await get_tree().create_timer(freeze_time * freeze_slow).timeout
	Engine.time_scale = 1
