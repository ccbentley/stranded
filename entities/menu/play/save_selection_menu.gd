extends Control

@onready var exit_button: Button = $MarginContainer/VBoxContainer/ExitButton
@onready var delete_button: Button = $MarginContainer/DeleteButton

signal exit_save_selection_menu

@onready var v_box_container: VBoxContainer = $MarginContainer/SaveMenu/VBoxContainer

const SAVE_FILE_MENU: PackedScene = preload("res://entities/menu/play/save_file_menu.tscn")

@onready var save_selection_menu: Control = $"."
@onready var create_world_menu: Control = $"../CreateWorldMenu"

const UI_CLICK_SOUND = preload("res://assets/sounds/ui/button_click.wav")

var save_file_arr: Array = []

enum { PLAY, DELETE }
var mode: int = PLAY:
	set(value):
		mode = value
		if mode == DELETE:
			delete_button.text = "Cancel"
			for child: Control in save_file_arr:
				child.modulate = Color.RED
		else:
			delete_button.text = "Erase"
			for child: Control in save_file_arr:
				child.modulate = Color.WHITE


func _ready() -> void:
	handle_connecting_signals()
	set_process(false)
	set_process_unhandled_key_input(false)
	for child in $MarginContainer/SaveMenu/VBoxContainer.get_children():
		save_file_arr.append(child)


func handle_connecting_signals() -> void:
	exit_button.button_down.connect(on_exit_pressed)
	delete_button.button_down.connect(on_delete_pressed)


func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu_back"):
		on_exit_pressed()


func on_exit_pressed() -> void:
	mode = PLAY
	exit_save_selection_menu.emit()
	set_process(false)
	set_process_unhandled_key_input(false)


func on_delete_pressed() -> void:
	AudioManager.play_sound(UI_CLICK_SOUND)
	if mode == PLAY:
		mode = DELETE
	else:
		mode = PLAY


func create_save(save_slot: int) -> void:
	self.visible = false
	create_world_menu.set_process(true)
	create_world_menu.set_process_unhandled_key_input(true)
	create_world_menu.visible = true
	create_world_menu.save_slot = save_slot


func check_for_saves() -> void:
	for child: Control in save_file_arr:
		child.world_data = null
		child.slot_info.text = "<Empty>"
	var dir := DirAccess.open(Global.save_file_path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if file_name != "." and file_name != ".." and dir.current_is_dir():
				if int(file_name) >= 1 and int(file_name) <= save_file_arr.size():
					set_save(int(file_name))
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("Failed to open directory: ", Global.save_file_path)


func set_save(save_slot: int) -> void:
	var save_file: Control = save_file_arr[save_slot - 1]
	var world_save_file_path: String = Global.save_file_path + str(save_slot) + "/" + Global.world_save_file_name
	var world_data: WorldData = ResourceLoader.load(world_save_file_path).duplicate()
	save_file.world_data = world_data.duplicate()
	save_file.slot_info.text = world_data.character_name
