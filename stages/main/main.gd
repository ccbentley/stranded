extends Node2D

@onready var player: Player = $Player
@onready var inventory_interface: InventoryInterface = $UI/MarginContainer/InventoryInterface
@onready var hot_bar_inventory: PanelContainer = $UI/MarginContainer/HotBarInventory
@onready var tile_map: Node2D = $TileMap
@onready var camera: Camera2D = $Camera2D
@onready var vignette: TextureRect = $UI/Vignette

var player_data: PlayerData = PlayerData.new()

const PICKUP: PackedScene = preload("res://common/item/pickup/pickup.tscn")


func _ready() -> void:
	WorldManager.world = self
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.force_close.connect(toggle_inventory_interface)
	load_inventory()

	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

	Global.verify_save_directory(Global.world_save_file_path)

	if not load_game():
		tile_map.find_spawn_location()
		save_game()


func load_inventory() -> void:
	inventory_interface.set_player_inventory_data(player.inventory_data)
	inventory_interface.set_equip_inventory_data(player.equip_inventory_data)
	hot_bar_inventory.set_inventory_data(player.inventory_data)
	inventory_interface.set_crafting_inventory_data(CraftingInventoryData.new())


func toggle_inventory_interface(external_inventory_owner: Node2D = null) -> void:
	inventory_interface.visible = not inventory_interface.visible

	if inventory_interface.visible:
		hot_bar_inventory.hide()
	else:
		hot_bar_inventory.show()

	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()


func _on_inventory_interface_drop_slot_data(slot_data: SlotData) -> void:
	var pick_up: Pickup = PICKUP.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = player.get_drop_position()
	add_child(pick_up)


func save_game() -> void:
	player_data.inventory_data = player.inventory_data.duplicate()
	player_data.equip_inventory_data = player.equip_inventory_data.duplicate()
	player_data.position = player.global_position
	ResourceSaver.save(player_data, Global.world_save_file_path + Global.player_save_file_name)


func load_game() -> bool:
	if not ResourceLoader.exists(Global.world_save_file_path + Global.player_save_file_name):
		return false
	player_data = (ResourceLoader.load(Global.world_save_file_path + Global.player_save_file_name).duplicate())
	player.inventory_data = player_data.inventory_data
	player.equip_inventory_data = player_data.equip_inventory_data
	load_inventory()
	teleport_player(player_data.position)
	$Chest.global_position = player_data.position
	return true


func teleport_player(pos: Vector2, smooth_cam: bool = false) -> void:
	player.global_position = pos
	camera.position = pos
	if not smooth_cam:
		camera.reset_smoothing()


func zoom_in() -> void:
	var new_zoom: Vector2 = camera.zoom + Vector2(0.5, 0.5)
	if new_zoom > Vector2.ZERO:
		camera.zoom = new_zoom


func zoom_out() -> void:
	var new_zoom: Vector2 = camera.zoom - Vector2(0.5, 0.5)
	if new_zoom > Vector2.ZERO:
		camera.zoom = new_zoom


func toggle_debug_menu() -> void:
	$UI/DebugMenu.visible = !$UI/DebugMenu.visible


func spawn_pickup(slot_data: SlotData, pos: Vector2) -> void:
	var pickup_instance: Pickup = PICKUP.instantiate()
	pickup_instance.slot_data = slot_data
	call_deferred("add_child", pickup_instance)
	pickup_instance.global_position = pos


var vignette_displayed: bool = false
var vignette_displayed_color: Color


func display_vignette(color: Color) -> void:
	vignette.material.set_shader_parameter("color", color)
	var vignette_tween: Tween
	vignette_tween = get_tree().create_tween()
	vignette_tween.tween_method(set_vignette_alpha, 0.0, 0.2, 0.3)
	vignette_displayed = true
	vignette_displayed_color = color


func remove_vignette() -> void:
	var vignette_tween: Tween
	vignette_tween = get_tree().create_tween()
	vignette_tween.tween_method(set_vignette_alpha, 0.2, 0.0, 0.3)
	vignette_displayed = false


func pulse_vignette(color: Color) -> void:
	vignette.material.set_shader_parameter("color", color)
	var pulse_vignette_tween: Tween
	pulse_vignette_tween = get_tree().create_tween()
	pulse_vignette_tween.tween_method(set_vignette_alpha, 0.0, 0.2, 0.3)
	pulse_vignette_tween.tween_method(set_vignette_alpha, 0.2, 0.0, 0.3)
	await pulse_vignette_tween.finished
	if vignette_displayed:
		display_vignette(vignette_displayed_color)


func set_vignette_alpha(value: float) -> void:
	vignette.material.set_shader_parameter("alpha", value)
