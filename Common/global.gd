extends Node

const save_file_path: String = "user://save/"
const player_save_file_name: String = "PlayerSave.tres"
const settings_save_file_name: String = "SettingsData.tres"
const world_save_file_name: String = "WorldData.tres"
var world_save_file_path: String

var worldData: WorldData:
	set(value):
		worldData = value
		world_save_file_path = save_file_path + worldData.world_name + "/"

var loading_screen: PackedScene = preload("res://common/menu/loading/loading_screen.tscn")
var next_scene: String
