extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

func get_place_position() -> Vector2:
	var place_position: Vector2 = WorldManager.world.tile_map.local_to_map(get_global_mouse_position())
	place_position = WorldManager.world.tile_map.map_to_local(place_position) + Vector2(8, 8)
	return place_position

func _ready() -> void:
	var hot_bar: PanelContainer = WorldManager.world.hot_bar_inventory
	sprite_2d.texture = hot_bar._slot_datas[hot_bar.selected_slot].item_data.texture
	sprite_2d.global_position = get_place_position()

func _physics_process(_delta: float) -> void:
	var place_position: Vector2 = get_place_position()
	sprite_2d.global_position = lerp(sprite_2d.global_position, place_position, 0.2)
