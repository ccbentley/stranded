extends Node2D

const PickUp = preload("res://Item/Pickup/pickup.tscn")

@onready var player : CharacterBody2D = $Player
@onready var inventory_interface : InventoryInterface = $UI/InventoryInterface
@onready var hot_bar_inventory: PanelContainer = $UI/HotBarInventory

const save_file_path: String = "user://save/"
const player_save_file_name: String = "PlayerSave.tres"
const world_save_file_name: String = "WorldData.tres"
var world_save_file_path: String = save_file_path + Global.worldData.world_name + "/"
var playerData: PlayerData = PlayerData.new()

func _ready() -> void:
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.force_close.connect(toggle_inventory_interface)

	load_inventory()

	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

	verify_save_directory(world_save_file_path)

	if not load_game():
		save_game()

func load_inventory() -> void:
	inventory_interface.set_player_inventory_data(player.inventory_data)
	inventory_interface.set_equip_inventory_data(player.equip_inventory_data)
	hot_bar_inventory.set_inventory_data(player.inventory_data)

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
	var pick_up : Pickup = PickUp.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = player.get_drop_position()
	add_child(pick_up)

func verify_save_directory(path: String) -> void:
	DirAccess.make_dir_absolute(path)

func save_game() -> void:
	playerData.inventory_data = player.inventory_data.duplicate()
	playerData.equip_inventory_data = player.equip_inventory_data.duplicate()
	playerData.position = player.global_position
	ResourceSaver.save(playerData, world_save_file_path + player_save_file_name)

func load_game() -> bool:
	if not ResourceLoader.exists(world_save_file_path + player_save_file_name):
		return false
	playerData = ResourceLoader.load(world_save_file_path + player_save_file_name).duplicate(true)
	player.inventory_data = playerData.inventory_data
	player.equip_inventory_data = playerData.equip_inventory_data
	load_inventory()
	player.global_position = playerData.position
	return true

func zoom_in() -> void:
	$Camera2D.zoom += Vector2(0.5, 0.5)
func zoom_out() -> void:
	$Camera2D.zoom -= Vector2(0.5, 0.5)
