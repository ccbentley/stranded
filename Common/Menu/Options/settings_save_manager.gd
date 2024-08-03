extends Node

var settingsData: SettingsData
@onready var default_keybindData: KeybindData = preload("res://utilities/save_system/keybind_default.tres")

const save_file_path: String = Global.save_file_path
const save_file_name: String = Global.settings_save_file_name


func _ready() -> void:
	if ResourceLoader.exists(save_file_path + save_file_name):
		load_settings()
	else:
		settingsData = SettingsData.new()
		settingsData.keybindData = default_keybindData.duplicate()


func on_window_mode_selected(index: int) -> void:
	settingsData.window_mode_index = index


func on_resolution_selected(index: int) -> void:
	settingsData.resolution_index = index


func on_master_sound_set(index: float) -> void:
	settingsData.master_volume = index


func on_music_sound_set(index: float) -> void:
	settingsData.music_volume = index


func on_sfx_sound_set(index: float) -> void:
	settingsData.sfx_volume = index


func set_keybind(action: String, event: InputEventKey) -> void:
	match action:
		settingsData.keybindData.MOVE_LEFT:
			settingsData.keybindData.move_left_key = event
		settingsData.keybindData.MOVE_RIGHT:
			settingsData.keybindData.move_right_key = event
		settingsData.keybindData.MOVE_UP:
			settingsData.keybindData.move_up_key = event
		settingsData.keybindData.MOVE_DOWN:
			settingsData.keybindData.move_down_key = event
		settingsData.keybindData.INVENTORY:
			settingsData.keybindData.inventory_key = event
		settingsData.keybindData.INTERACT:
			settingsData.keybindData.interact_key = event


func get_window_mode_index() -> int:
	return settingsData.window_mode_index


func get_resolution_index() -> int:
	return settingsData.resolution_index


func get_master_volume() -> float:
	return settingsData.master_volume


func get_music_volume() -> float:
	return settingsData.music_volume


func get_sfx_volume() -> float:
	return settingsData.sfx_volume


func get_keybind(action: String) -> InputEventKey:
	match action:
		settingsData.keybindData.MOVE_LEFT:
			return settingsData.keybindData.move_left_key
		settingsData.keybindData.MOVE_RIGHT:
			return settingsData.keybindData.move_right_key
		settingsData.keybindData.MOVE_UP:
			return settingsData.keybindData.move_up_key
		settingsData.keybindData.MOVE_DOWN:
			return settingsData.keybindData.move_down_key
		settingsData.keybindData.INVENTORY:
			return settingsData.keybindData.inventory_key
		settingsData.keybindData.INTERACT:
			return settingsData.keybindData.interact_key
	return


func save_settings() -> void:
	verify_save_directory(save_file_path)
	ResourceSaver.save(settingsData, save_file_path + save_file_name)


func load_settings() -> void:
	settingsData = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)


func verify_save_directory(path: String) -> void:
	DirAccess.make_dir_absolute(path)
