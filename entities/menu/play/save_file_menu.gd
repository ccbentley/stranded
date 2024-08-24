extends Control

@export var slot_number: int
@export var world_data: WorldData

const UI_CLICK_SOUND = preload("res://assets/sounds/ui/button_click.wav")
@onready var slot_number_label: Label = $Button/HBoxContainer/SlotNumber
@onready var button: Button = $Button
@onready var slot_info: Label = $Button/SlotInfo

@onready var save_selection_menu: Control = get_parent().owner


func _ready() -> void:
	handle_connecting_signals()
	slot_number_label.text = str(slot_number)


func handle_connecting_signals() -> void:
	button.button_down.connect(on_button_pressed)


func on_button_pressed() -> void:
	AudioManager.play_sound(UI_CLICK_SOUND)
	if save_selection_menu.mode == save_selection_menu.PLAY:
		if world_data:
			AudioManager.play_sound(UI_CLICK_SOUND)
			Global.world_data = world_data.duplicate()
			Global.next_scene = "res://stages/main/world.tscn"
			Global.next_scene_name = "Main Land"
			Global.next_scene_background = load("res://assets/art/background/screenshot.png")
			Global.load_next_scene()
		else:
			get_parent().owner.create_save(slot_number)
	elif save_selection_menu.mode == save_selection_menu.DELETE:
		if world_data:
			delete_save()
		save_selection_menu.mode = save_selection_menu.PLAY


func delete_save() -> void:
	var world_save_file_path: String = Global.save_file_path + str(world_data.save_slot)
	DirAccess.remove_absolute(world_save_file_path + "/" + Global.world_save_file_name)
	DirAccess.remove_absolute(world_save_file_path + "/" + Global.player_save_file_name)
	DirAccess.remove_absolute(world_save_file_path)
	save_selection_menu.check_for_saves()
