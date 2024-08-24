extends Control
class_name CreateWorldMenu

@onready var exit_button: Button = $MarginContainer/VBoxContainer/ExitButton
@onready var character_name: LineEdit = $MarginContainer/CenterContainer/VBoxContainer/CharacterName
@onready var world_seed: LineEdit = $MarginContainer/CenterContainer/VBoxContainer/Seed
@onready var create_save_button: Button = $MarginContainer/VBoxContainer2/CreateSaveButton

signal exit_create_world_menu

const UI_CLICK_SOUND = preload("res://assets/sounds/ui/button_click.wav")

var save_slot: int


func _ready() -> void:
	handle_connecting_signals()
	set_process(false)
	set_process_unhandled_key_input(false)


func handle_connecting_signals() -> void:
	exit_button.button_down.connect(on_exit_pressed)
	create_save_button.button_down.connect(on_create_save_pressed)
	character_name.text_changed.connect(func(_new_text: String) -> void: character_name.modulate = Color.WHITE)


func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu_back"):
		on_exit_pressed()


func on_exit_pressed() -> void:
	character_name.text = ""
	world_seed.text = ""
	character_name.modulate = Color.WHITE
	exit_create_world_menu.emit()
	set_process(false)
	set_process_unhandled_key_input(false)


func on_create_save_pressed() -> void:
	var world_data: WorldData = WorldData.new()
	world_data.save_slot = save_slot
	if character_name.text != "":
		world_data.character_name = character_name.text
		if int(world_seed.text) == 0:
			world_data.world_seed = randi()
		else:
			world_data.world_seed = int(world_seed.text)
		var world_save_file_path: String = Global.save_file_path + str(world_data.save_slot) + "/"
		Global.verify_save_directory(world_save_file_path)
		ResourceSaver.save(world_data, world_save_file_path + Global.world_save_file_name)
		on_exit_pressed()
	else:
		AudioManager.play_sound(UI_CLICK_SOUND)
		if character_name.text == "":
			character_name.modulate = Color.RED
