extends Node

var settings_data: SettingsData
@onready var default_keybind_data: KeybindData = preload("res://utilities/save_system/keybind_default.tres")


func _ready() -> void:
	if ResourceLoader.exists(Global.save_file_path + Global.settings_save_file_name):
		load_settings()
	else:
		settings_data = SettingsData.new()
		settings_data.keybind_data = default_keybind_data.duplicate()
	set_custom_cursors()


func on_window_mode_selected(index: int) -> void:
	settings_data.window_mode_index = index


func on_resolution_selected(index: int) -> void:
	settings_data.resolution_index = index


func on_vsync_mode_selected(index: int) -> void:
	settings_data.vsync_mode_index = index


func on_master_sound_set(index: float) -> void:
	settings_data.master_volume = index


func on_music_sound_set(index: float) -> void:
	settings_data.music_volume = index


func on_sfx_sound_set(index: float) -> void:
	settings_data.sfx_volume = index


func set_keybind(action: String, event: InputEventKey) -> void:
	match action:
		settings_data.keybind_data.MOVE_LEFT:
			settings_data.keybind_data.move_left_key = event
		settings_data.keybind_data.MOVE_RIGHT:
			settings_data.keybind_data.move_right_key = event
		settings_data.keybind_data.MOVE_UP:
			settings_data.keybind_data.move_up_key = event
		settings_data.keybind_data.MOVE_DOWN:
			settings_data.keybind_data.move_down_key = event
		settings_data.keybind_data.INVENTORY:
			settings_data.keybind_data.inventory_key = event
		settings_data.keybind_data.INTERACT:
			settings_data.keybind_data.interact_key = event
		settings_data.keybind_data.DISMOUNT:
			settings_data.keybind_data.dismount_key = event


func get_window_mode_index() -> int:
	return settings_data.window_mode_index


func get_resolution_index() -> int:
	return settings_data.resolution_index


func get_vsync_mode_index() -> int:
	return settings_data.vsync_mode_index


func get_master_volume() -> float:
	return settings_data.master_volume


func get_music_volume() -> float:
	return settings_data.music_volume


func get_sfx_volume() -> float:
	return settings_data.sfx_volume


func get_keybind(action: String) -> InputEventKey:
	match action:
		settings_data.keybind_data.MOVE_LEFT:
			return settings_data.keybind_data.move_left_key
		settings_data.keybind_data.MOVE_RIGHT:
			return settings_data.keybind_data.move_right_key
		settings_data.keybind_data.MOVE_UP:
			return settings_data.keybind_data.move_up_key
		settings_data.keybind_data.MOVE_DOWN:
			return settings_data.keybind_data.move_down_key
		settings_data.keybind_data.INVENTORY:
			return settings_data.keybind_data.inventory_key
		settings_data.keybind_data.INTERACT:
			return settings_data.keybind_data.interact_key
		settings_data.keybind_data.DISMOUNT:
			return settings_data.keybind_data.dismount_key
	return


# Mouse cursors
const CANCEL = preload("res://assets/art/cursors/cancel.png")
const HAND_POINTER = preload("res://assets/art/cursors/hand_pointer.png")
const MOVE = preload("res://assets/art/cursors/move.png")
const POINTER = preload("res://assets/art/cursors/pointer.png")
const TYPE = preload("res://assets/art/cursors/type.png")


func set_custom_cursors() -> void:
	Input.set_custom_mouse_cursor(POINTER, Input.CURSOR_ARROW, Vector2(12, 12))
	Input.set_custom_mouse_cursor(HAND_POINTER, Input.CURSOR_POINTING_HAND, Vector2(12, 12))
	Input.set_custom_mouse_cursor(TYPE, Input.CURSOR_IBEAM, Vector2(12, 12))
	Input.set_custom_mouse_cursor(CANCEL, Input.CURSOR_FORBIDDEN, Vector2(12, 12))
	Input.set_custom_mouse_cursor(MOVE, Input.CURSOR_MOVE, Vector2(12, 12))


func save_settings() -> void:
	Global.verify_save_directory(Global.save_file_path)
	ResourceSaver.save(settings_data, Global.save_file_path + Global.settings_save_file_name)


func load_settings() -> void:
	settings_data = (ResourceLoader.load(Global.save_file_path + Global.settings_save_file_name).duplicate())
