extends Control
class_name SaveSelectionMenu

@onready var exit_button: Button = $MarginContainer/VBoxContainer/ExitButton
@onready var create_world_button: Button = $MarginContainer/VBoxContainer2/CreateWorldButton

signal exit_save_selection_menu

@onready var v_box_container: VBoxContainer = $MarginContainer/SaveMenu/SelectionMenu/VBoxContainer

const save_file_path: String = Global.save_file_path
const save_file_name: String = Global.world_save_file_name

const SAVE_FILE_MENU: PackedScene = preload("res://Common/Menu/Play/save_file_menu.tscn")

@onready var save_selection_menu: SaveSelectionMenu = $"."
@onready var create_world_menu: CreateWorldMenu = $"../CreateWorldMenu"


func _ready() -> void:
	handle_connecting_signals()
	set_process(false)


func handle_connecting_signals() -> void:
	exit_button.button_down.connect(on_exit_pressed)
	create_world_button.button_down.connect(on_create_world_pressed)


func on_exit_pressed() -> void:
	exit_save_selection_menu.emit()
	set_process(false)


func on_create_world_pressed() -> void:
	self.visible = false
	create_world_menu.set_process(true)
	create_world_menu.visible = true


func on_exit_create_world_menu() -> void:
	self.visible = true
	save_selection_menu.set_process(false)
	save_selection_menu.visible = false


func check_for_worlds() -> void:
	for child in v_box_container.get_children():
		child.queue_free()
	var dir := DirAccess.open(save_file_path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if file_name != "." and file_name != ".." and dir.current_is_dir():
				add_world(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open directory: ", save_file_path)


func add_world(file_name: String) -> void:
	var worldData: WorldData = WorldData.new()
	var world_save_file_path: String = save_file_path + file_name + "/" + save_file_name
	worldData = ResourceLoader.load(world_save_file_path).duplicate(true)
	var save_file_menu: SaveFileMenu = SAVE_FILE_MENU.instantiate()
	v_box_container.add_child(save_file_menu)
	save_file_menu.worldData = worldData.duplicate()
	save_file_menu.world_name.text = worldData.world_name + "\n" + str(worldData.world_seed)
