extends Control
class_name SaveFileMenu

@onready var world_name: RichTextLabel = $BoxContainer/WorldNameButton
@onready var delete_world_button: TextureButton = $BoxContainer/DeleteWorldButton
@onready var world_icon: TextureButton = $BoxContainer/WorldIcon

@export var world_data: WorldData

const UI_CLICK_SOUND = preload("res://assets/sounds/ui_soundpack/WAV/Minimalist7.wav")


func _ready() -> void:
	handle_connecting_signals()


func handle_connecting_signals() -> void:
	delete_world_button.button_down.connect(on_delete_pressed)
	world_icon.button_down.connect(on_world_icon_pressed)


func on_world_icon_pressed() -> void:
	AudioManager.play_sound(UI_CLICK_SOUND)
	Global.world_data = world_data.duplicate()
	Global.next_scene = "res://stages/main/world.tscn"
	Global.next_scene_name = "Main Land"
	Global.next_scene_background = load("res://assets/art/background/screenshot.png")
	Global.load_next_scene()


func on_delete_pressed() -> void:
	AudioManager.play_sound(UI_CLICK_SOUND)
	var world_save_file_path: String = Global.save_file_path + world_data.world_name
	DirAccess.remove_absolute(world_save_file_path + "/" + Global.world_save_file_name)
	DirAccess.remove_absolute(world_save_file_path + "/" + Global.player_save_file_name)
	DirAccess.remove_absolute(world_save_file_path)
	queue_free()
