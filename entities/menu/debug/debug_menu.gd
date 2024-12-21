extends Control

@onready var info: Label = $MarginContainer/Info
@onready var spawn: HBoxContainer = $MarginContainer/Spawn
@onready var spawn_list: VBoxContainer = $MarginContainer/Spawn/SpawnList

@onready var player: Player = PlayerManager.player
@onready var main: Node2D = player.main

var item_list: PackedStringArray = [
	"res://entities/items/consumable/health_potion/health_potion.tres",
	"res://entities/items/equip/iron_helmet/iron_helm.tres",
	"res://entities/items/materials/wood/wood.tres",
	"res://entities/items/materials/stick/stick.tres",
	"res://entities/items/melee/axe/wooden/wooden_axe.tres",
	"res://entities/items/melee/sword/wooden/wooden_sword.tres",
	"res://entities/items/placeable/boat/boat.tres",
	"res://entities/items/ranged/bow/bow.tres",
	"res://entities/items/fishing_rod/fishing_rod.tres",
	"res://entities/items/placeable/campfire/campfire.tres",
	"res://entities/items/melee/pickaxe/wooden/wooden_pickaxe.tres",
	"res://entities/items/placeable/crafting_bench/crafting_bench.tres",
]

var object_list: PackedStringArray = [
	"res://entities/chest/chest.tscn",
	"res://entities/boat/boat.tscn",
	"res://entities/environment/rocks/rock.tscn",
	"res://entities/environment/trees/tree.tscn",
]


func _on_info_button_pressed() -> void:
	info.visible = !info.visible


func _on_spawn_button_pressed() -> void:
	spawn.visible = !spawn.visible


func _process(_delta: float) -> void:
	if info.visible:
		update_info()


func update_info() -> void:
	info.text = ""
	info.text += " Player Info: "
	info.text += "\n Player Pos: " + str(player.global_position)
	info.text += "\n Player Tile Type: " + str(player.player_tile_type)
	info.text += "\n Player Tile Pos: " + str(player.player_tile_pos)
	info.text += "\n Player Chunk Pos: " + str(player.player_tile_pos / 32)
	info.text += "\n \n World Info: "
	info.text += "\n Save Slot: " + str(Global.world_data.save_slot)
	info.text += "\n World Seed: " + str(Global.world_data.world_seed)
	info.text += "\n Day Count: " + str(main.day_night_cycle.day_counter)
	info.text += "\n Time: " + str(int(main.day_night_cycle.minute_passed / 60) % 12) + " : " + str(int(main.day_night_cycle.minute_passed) % 60)


func clear_spawn_list() -> void:
	for child in spawn_list.get_children():
		child.queue_free()


func _on_spawn_item_pressed() -> void:
	clear_spawn_list()
	for item: String in item_list:
		var button: Button = Button.new()
		var filename: String = item.get_file()
		button.text = filename
		spawn_list.add_child(button)
		button.button_down.connect(spawn_item.bind(item))


func spawn_item(path: String) -> void:
	var slot_data: SlotData = SlotData.new()
	slot_data.item_data = load(path)
	WorldManager.spawn_pickup(slot_data, PlayerManager.get_global_position())


func spawn_object(path: String) -> void:
	var _obj: PackedScene = load(path)
	var obj: Node2D = _obj.instantiate()
	obj.position = PlayerManager.get_global_position()
	WorldManager.world.add_child(obj)


func _on_spawn_object_pressed() -> void:
	clear_spawn_list()
	for object: String in object_list:
		var button: Button = Button.new()
		var filename: String = object.get_file()
		button.text = filename
		spawn_list.add_child(button)
		button.button_down.connect(spawn_object.bind(object))
