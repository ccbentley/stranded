extends Node2D

@onready var area_2d: Area2D = $Sprite2D/Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player: Player = PlayerManager.player
var max_placeable_distance: float = 0
var placeable_object_path: String
var placeable_tile_types: int = 0


func get_place_position() -> Vector2:
	var place_position: Vector2 = WorldManager.world.tile_map.local_to_map(get_global_mouse_position())
	place_position = WorldManager.world.tile_map.map_to_local(place_position) + Vector2(8, 8)
	return place_position


func can_place(place_position: Vector2) -> bool:
	if area_2d.get_overlapping_bodies():
		return false
	return abs(place_position.x - player.global_position.x) < max_placeable_distance and abs(place_position.y - player.global_position.y) < max_placeable_distance


func _ready() -> void:
	var hot_bar: PanelContainer = WorldManager.world.hot_bar_inventory
	var item_data: ItemData = hot_bar._slot_datas[hot_bar.selected_slot].item_data
	sprite_2d.texture = item_data.texture
	max_placeable_distance = item_data.max_placeable_distance
	placeable_object_path = item_data.placeable_object_path
	placeable_tile_types = item_data.placeable_tile_types
	sprite_2d.global_position = get_place_position()


func _physics_process(_delta: float) -> void:
	var place_position: Vector2 = get_place_position()
	sprite_2d.global_position = lerp(sprite_2d.global_position, place_position, 0.2)
	if can_place(place_position):
		sprite_2d.modulate = Color(1, 1, 1, 0.6)
	else:
		sprite_2d.modulate = Color(1, 0.2, 0.2, 0.6)


func use(index: int) -> void:
	var place_position: Vector2 = get_place_position()
	var tile_type: int = player.get_tile_data(WorldManager.world.tile_map.local_to_map(place_position))
	if placeable_tile_types & (1 << tile_type) > 0 and can_place(place_position):
		var placeable_object: PackedScene = load(placeable_object_path)
		player.place_object(placeable_object, place_position)

		# Decrement the quantity and remove the item if necessary
		var slot_data: SlotData = player.inventory_data.slot_datas[index]
		slot_data.quantity -= 1
		if slot_data.quantity < 1:
			player.inventory_data.slot_datas[index] = null

		player.inventory_data.inventory_updated.emit(player.inventory_data)
