extends Control
class_name SaveSelectionMenu

@onready var exit_button: Button = $MarginContainer/VBoxContainer/ExitButton
@onready var create_world_button: Button = $MarginContainer/VBoxContainer2/CreateWorldButton

signal exit_save_selection_menu

@onready var v_box_container: VBoxContainer = $MarginContainer/SaveMenu/SelectionMenu/VBoxContainer

const SAVE_FILE_MENU: PackedScene = preload("res://entities/menu/play/save_file_menu.tscn")

@onready var save_selection_menu: SaveSelectionMenu = $"."
@onready var create_world_menu: CreateWorldMenu = $"../CreateWorldMenu"

const UI_CLICK_SOUND = preload("res://assets/sounds/ui_soundpack/WAV/Minimalist7.wav")


func _ready() -> void:
	handle_connecting_signals()
	set_process(false)
	set_process_unhandled_key_input(false)


func handle_connecting_signals() -> void:
	exit_button.button_down.connect(on_exit_pressed)
	create_world_button.button_down.connect(on_create_world_pressed)


func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu_back"):
		on_exit_pressed()


func on_exit_pressed() -> void:
	exit_save_selection_menu.emit()
	set_process(false)
	set_process_unhandled_key_input(false)


func on_create_world_pressed() -> void:
	self.visible = false
	create_world_menu.set_process(true)
	create_world_menu.set_process_unhandled_key_input(true)
	create_world_menu.visible = true
	AudioManager.play_sound(UI_CLICK_SOUND)


func on_exit_create_world_menu() -> void:
	self.visible = true
	save_selection_menu.set_process(false)
	save_selection_menu.set_process_unhandled_key_input(false)
	save_selection_menu.visible = false
	AudioManager.play_sound(UI_CLICK_SOUND)


func check_for_worlds() -> void:
	for child in v_box_container.get_children():
		child.queue_free()
	var dir := DirAccess.open(Global.save_file_path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if file_name != "." and file_name != ".." and dir.current_is_dir():
				add_world(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("Failed to open directory: ", Global.save_file_path)


func add_world(file_name: String) -> void:
	var world_data: WorldData = WorldData.new()
	var world_save_file_path: String = (
		Global.save_file_path + file_name + "/" + Global.world_save_file_name
	)
	world_data = ResourceLoader.load(world_save_file_path).duplicate()
	var save_file_menu: SaveFileMenu = SAVE_FILE_MENU.instantiate()
	v_box_container.add_child(save_file_menu)
	save_file_menu.world_data = world_data.duplicate()
	save_file_menu.world_name.text = world_data.world_name + "\n" + str(world_data.world_seed)
