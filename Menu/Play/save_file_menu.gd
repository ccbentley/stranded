extends Control
class_name SaveFileMenu

@onready var world_name: RichTextLabel = $BoxContainer/WorldNameButton
@onready var delete_world_button: TextureButton = $BoxContainer/DeleteWorldButton
@onready var world_icon: TextureButton = $BoxContainer/WorldIcon

@export var worldData: WorldData
const save_file_path: String = "user://save/"
const world_save_file_name: String = "WorldData.tres"
const player_save_file_name: String = "PlayerSave.tres"

func _ready() -> void:
	handle_connecting_signals()

func handle_connecting_signals() -> void:
	delete_world_button.button_down.connect(on_delete_pressed)
	world_icon.button_down.connect(on_world_icon_pressed)

func on_world_icon_pressed() -> void:
	Global.worldData = worldData.duplicate()
	get_tree().change_scene_to_file("res://Scenes/Worlds/world.tscn")

func on_delete_pressed() -> void:
	var world_save_file_path: String = save_file_path + worldData.world_name
	DirAccess.remove_absolute(world_save_file_path + "/" + world_save_file_name)
	DirAccess.remove_absolute(world_save_file_path + "/" + player_save_file_name)
	DirAccess.remove_absolute(world_save_file_path)
	get_parent().get_parent().get_parent().get_parent().get_parent().check_for_worlds()
