extends Control
class_name CreateWorldMenu

@onready var exit_button: Button = $MarginContainer/VBoxContainer/ExitButton
@onready var world_name: LineEdit = $MarginContainer/CenterContainer/VBoxContainer/WorldName
@onready var character_name: LineEdit = $MarginContainer/CenterContainer/VBoxContainer/CharacterName
@onready var world_seed: LineEdit = $MarginContainer/CenterContainer/VBoxContainer/Seed
@onready var create_world_button: Button = $MarginContainer/VBoxContainer2/CreateWorldButton


signal exit_create_world_menu

const save_file_path: String = "user://save/"
const save_file_name: String = "WorldData.tres"

func _ready() -> void:
	handle_connecting_signals()
	set_process(false)

func handle_connecting_signals() -> void:
	exit_button.button_down.connect(on_exit_pressed)
	create_world_button.button_down.connect(on_create_world_pressed)

func on_exit_pressed():
	world_name.text = ""
	character_name.text = ""
	world_seed.text = ""
	exit_create_world_menu.emit()
	set_process(false)

func on_create_world_pressed() -> void:
	var worldData: WorldData = WorldData.new()
	if world_name.text != "" and character_name.text != "":
		worldData.world_name = world_name.text
		worldData.character_name = character_name.text
		if int(world_seed.text) == 0:
			worldData.world_seed = randi()
		else:
			worldData.world_seed = int(world_seed.text)
		var world_save_file_path: String = save_file_path + worldData.world_name + "/"
		verify_save_directory(world_save_file_path)
		ResourceSaver.save(worldData, world_save_file_path + save_file_name)
		print("World Data Saved To " + world_save_file_path + save_file_name)
		on_exit_pressed()

func verify_save_directory(path: String) -> void:
	DirAccess.make_dir_absolute(path)

