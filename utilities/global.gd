extends Node

const save_file_path: String = "user://save/"
const player_save_file_name: String = "player_save.tres"
const settings_save_file_name: String = "settings_data.tres"
const world_save_file_name: String = "world_data.tres"
var world_save_file_path: String

var world_data: WorldData:
	set(value):
		world_data = value
		world_save_file_path = save_file_path + world_data.world_name + "/"

const loading_screen: PackedScene = preload("res://entities/menu/loading/loading_screen.tscn")
var next_scene: String
var next_scene_name: String
var next_scene_background: Texture2D


func load_next_scene() -> void:
	get_tree().change_scene_to_packed(loading_screen)