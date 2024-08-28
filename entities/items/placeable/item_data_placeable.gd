extends ItemData
class_name ItemDataPlaceable

@export var placeable_object_path: String
@export var max_placeable_distance: float = 50
@export_flags("Water", "Sand", "Grass") var placeable_tile_types: int = 0


func use(target: Node2D, index: int) -> void:
	var place_position: Vector2 = WorldManager.world.tile_map.local_to_map(target.get_global_mouse_position())
	var tile_type: int = target.get_tile_data(place_position)
	if placeable_tile_types & (1 << tile_type) > 0:
		place_position = WorldManager.world.tile_map.map_to_local(place_position) + Vector2(8, 8)
		if abs(place_position.x - target.global_position.x) < max_placeable_distance and abs(place_position.y - target.global_position.y) < max_placeable_distance:
			var placeable_object: PackedScene = load(placeable_object_path)
			target.place_object(placeable_object, place_position)

			# Decrement the quantity and remove the item if necessary
			var slot_data: SlotData = target.inventory_data.slot_datas[index]
			slot_data.quantity -= 1
			if slot_data.quantity < 1:
				target.inventory_data.slot_datas[index] = null

			target.inventory_data.inventory_updated.emit(target.inventory_data)
