extends StaticBody2D

signal toggle_inventory(external_inventory_owner: Node2D)

@export var inventory_data: InventoryData


func player_interact(_player: Player) -> void:
	toggle_inventory.emit(self)


func on_save_chunk(saved_data: Array[SavedData]) -> void:
	var entity_data: SavedInventoryData = SavedInventoryData.new()
	entity_data.position = global_position
	entity_data.scene_path = scene_file_path
	entity_data.inventory_data = inventory_data

	saved_data.append(entity_data)


func on_load_chunk(saved_data: SavedData) -> void:
	var entity_data: SavedInventoryData = saved_data as SavedInventoryData

	global_position = entity_data.position
	inventory_data = entity_data.inventory_data
	toggle_inventory.connect(WorldManager.world.toggle_inventory_interface)
