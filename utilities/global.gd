extends Node

const save_file_path: String = "user://save/"
const player_save_file_name: String = "player_save.res"
const settings_save_file_name: String = "settings_data.res"
const world_save_file_name: String = "world_data.res"
var world_save_file_path: String
const chunk_data_save_file_path: String = "chunk_data/"


func verify_save_directory(path: String) -> void:
	DirAccess.make_dir_absolute(path)


var world_data: WorldData:
	set(value):
		world_data = value
		world_save_file_path = save_file_path + str(world_data.save_slot) + "/"

const loading_screen: PackedScene = preload("res://entities/menu/loading/loading_screen.tscn")
var next_scene: String
var next_scene_name: String
var next_scene_background: Texture2D


func load_next_scene() -> void:
	SceneTransition.change_scene(loading_screen, "fade")
