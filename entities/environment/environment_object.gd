extends Node2D
class_name EnvironmentObject

@onready var health_component: HealthComponent = $HealthComponent


func on_save_chunk(saved_data: Array[SavedData]) -> void:
	if health_component.health <= 0:
		return
	var entity_data: SavedData = SavedData.new()
	entity_data.position = global_position
	entity_data.scene_path = scene_file_path
	entity_data.health = health_component.health

	saved_data.append(entity_data)


func on_load_chunk(saved_data: SavedData) -> void:
	global_position = saved_data.position
	health_component.set_health(saved_data.health)
