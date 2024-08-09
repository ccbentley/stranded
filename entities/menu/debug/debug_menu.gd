extends Control
class_name DebugMenu

@onready var info: Label = $MarginContainer/Info
@onready var spawn: HBoxContainer = $MarginContainer/Spawn
@onready var spawn_list: VBoxContainer = $MarginContainer/Spawn/SpawnList

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
	var player: Player = PlayerManager.player
	info.text = ""
	info.text += " Player Info: "
	info.text += "\n Player Pos: " + str(player.global_position)
	info.text += "\n Player Tile Pos: " + str(player.player_tile)
	info.text += "\n Player Chunk Pos: " + str(player.player_tile / 32)
	info.text += "\n \n World Info: "
	info.text += "\n World Name: " + str(Global.world_data.world_name)
	info.text += "\n World Seed: " + str(Global.world_data.world_seed)


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
