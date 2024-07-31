extends Control
class_name SaveFileMenu

@onready var world_name: RichTextLabel = $BoxContainer/WorldNameButton
@onready var delete_world_button: TextureButton = $BoxContainer/DeleteWorldButton
@onready var world_icon: TextureButton = $BoxContainer/WorldIcon

@export var worldData: WorldData
const save_file_path: String = Global.save_file_path
const world_save_file_name: String = Global.world_save_file_name
const player_save_file_name: String = Global.player_save_file_name


func _ready() -> void:
	handle_connecting_signals()


func handle_connecting_signals() -> void:
	delete_world_button.button_down.connect(on_delete_pressed)
	world_icon.button_down.connect(on_world_icon_pressed)


func on_world_icon_pressed() -> void:
	Global.worldData = worldData.duplicate()
	Global.next_scene = "res://Scenes/Worlds/world.tscn"
	get_tree().change_scene_to_packed(Global.loading_screen)


func on_delete_pressed() -> void:
	var world_save_file_path: String = save_file_path + worldData.world_name
	DirAccess.remove_absolute(world_save_file_path + "/" + world_save_file_name)
	DirAccess.remove_absolute(world_save_file_path + "/" + player_save_file_name)
	DirAccess.remove_absolute(world_save_file_path)
	get_parent().get_parent().get_parent().get_parent().get_parent().check_for_worlds()
