extends Node2D

const PickUp = preload("res://Item/Pickup/pickup.tscn")

@onready var player : CharacterBody2D = $Player
@onready var inventory_interface : Control = $UI/InventoryInterface
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

	generate_world()

func generate_world() -> void:
	if Global.worldData.world_seed:
		$NoiseGenerator.random_seed = false
		$NoiseGenerator.seed = Global.worldData.world_seed
	else:
		$NoiseGenerator.random_seed = true
	$NoiseGenerator.generate()
	Global.worldData.world_seed = $NoiseGenerator.seed
	ResourceSaver.save(Global.worldData, world_save_file_path + world_save_file_name)
	if FileAccess.file_exists(world_save_file_path + player_save_file_name):
		load_game()

func load_inventory():
	inventory_interface.set_player_inventory_data(player.inventory_data)
	inventory_interface.set_equip_inventory_data(player.equip_inventory_data)
	hot_bar_inventory.set_inventory_data(player.inventory_data)

func toggle_inventory_interface(external_inventory_owner = null) -> void:
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
	var pick_up = PickUp.instantiate()
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
	print("Player Data Saved To " + world_save_file_path)

func load_game() -> void:
	playerData = ResourceLoader.load(world_save_file_path + player_save_file_name).duplicate(true)
	player.inventory_data = playerData.inventory_data
	player.equip_inventory_data = playerData.equip_inventory_data
	load_inventory()

	player.global_position = playerData.position

	print("Player Data Loaded From " + world_save_file_path)
