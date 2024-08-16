extends Control
class_name CreateWorldMenu

@onready var exit_button: Button = $MarginContainer/VBoxContainer/ExitButton
@onready var world_name: LineEdit = $MarginContainer/CenterContainer/VBoxContainer/WorldName
@onready var character_name: LineEdit = $MarginContainer/CenterContainer/VBoxContainer/CharacterName
@onready var world_seed: LineEdit = $MarginContainer/CenterContainer/VBoxContainer/Seed
@onready var create_world_button: Button = $MarginContainer/VBoxContainer2/CreateWorldButton

signal exit_create_world_menu

const UI_CLICK_SOUND = preload("res://assets/sounds/ui_soundpack/WAV/Minimalist7.wav")

var cached_world_names: PackedStringArray = []


func _ready() -> void:
	handle_connecting_signals()
	set_process(false)
	set_process_unhandled_key_input(false)


func handle_connecting_signals() -> void:
	exit_button.button_down.connect(on_exit_pressed)
	create_world_button.button_down.connect(on_create_world_pressed)
	world_name.text_changed.connect(func(_new_text: String) -> void: world_name.modulate = Color.WHITE)
	character_name.text_changed.connect(func(_new_text: String) -> void: character_name.modulate = Color.WHITE)


func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu_back"):
		on_exit_pressed()


func on_exit_pressed() -> void:
	world_name.text = ""
	character_name.text = ""
	world_seed.text = ""
	world_name.modulate = Color.WHITE
	character_name.modulate = Color.WHITE
	exit_create_world_menu.emit()
	set_process(false)
	set_process_unhandled_key_input(false)


func on_create_world_pressed() -> void:
	AudioManager.play_sound(UI_CLICK_SOUND)
	var world_data: WorldData = WorldData.new()
	if world_name.text != "" and character_name.text != "":
		cache_world_names()
		for file_name: String in cached_world_names:
			if world_name.text == file_name:
				world_name.modulate = Color.RED
				return
		world_data.world_name = world_name.text
		world_data.character_name = character_name.text
		if int(world_seed.text) == 0:
			world_data.world_seed = randi()
		else:
			world_data.world_seed = int(world_seed.text)
		var world_save_file_path: String = Global.save_file_path + world_data.world_name + "/"
		Global.verify_save_directory(world_save_file_path)
		ResourceSaver.save(world_data, world_save_file_path + Global.world_save_file_name)
		on_exit_pressed()
	else:
		if world_name.text == "":
			world_name.modulate = Color.RED
		if character_name.text == "":
			character_name.modulate = Color.RED


func cache_world_names() -> void:
	cached_world_names.clear()
	var dir := DirAccess.open(Global.save_file_path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if file_name != "." and file_name != ".." and dir.current_is_dir():
				cached_world_names.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
