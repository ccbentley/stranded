extends Node2D

@onready var player: Player = $Player
@onready var inventory_interface: InventoryInterface = $UI/MarginContainer/InventoryInterface
@onready var hot_bar_inventory: PanelContainer = $UI/MarginContainer/HotBarInventory
@onready var tile_map: Node2D = $TileMap
@onready var camera: Camera2D = $Camera2D
@onready var vignette: TextureRect = $UI/Vignette
@onready var entities: Node2D = $Entities
@onready var saver_loader: Node = $Utilities/SaverLoader
@onready var day_night_cycle: Node2D = $DayNightCycle
@onready var weather_manager: CanvasLayer = $WeatherManager
@onready var quest_manager: Control = $UI/MarginContainer/QuestManager

var player_data: PlayerData = PlayerData.new()


func _ready() -> void:
	WorldManager.world = self
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.force_close.connect(toggle_inventory_interface)
	load_inventory()

	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

	Global.verify_save_directory(Global.world_save_file_path)

	if not saver_loader.load_game():
		tile_map.find_spawn_location()
		saver_loader.save_game()


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
	WorldManager.spawn_pickup(slot_data, player.get_drop_position())


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


func display_death_screen() -> void:
	$UI/DeathScreen.display_screen()


func toggle_quests() -> void:
	quest_manager.visible = !quest_manager.visible
