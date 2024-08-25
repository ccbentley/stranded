extends StaticBody2D

func on_save_chunk(saved_data: Array[SavedData]) -> void:
	if $HealthComponent.health <= 0:
		return
	var entity_data: SavedData = SavedData.new()
	entity_data.position = global_position
	entity_data.scene_path = scene_file_path

	saved_data.append(entity_data)


func on_load_chunk(saved_data: SavedData) -> void:
	global_position = saved_data.position
