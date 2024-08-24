extends Control
class_name MainMenu

@onready var play_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/PlayButton
@onready var options_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/OptionsButton
@onready var quit_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/QuitButton
@onready var credits_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/CreditsButton
@onready var version_label: Label = $MarginContainer/Label

@onready var margin_container: MarginContainer = $MarginContainer
@onready var save_selection_menu: SaveSelectionMenu = $SaveSelectionMenu
@onready var create_world_menu: CreateWorldMenu = $CreateWorldMenu
@onready var options_menu: OptionsMenu = $OptionsMenu
@onready var credits_menu: CreditsMenu = $CreditsMenu

const UI_CLICK_SOUND = preload("res://assets/sounds/ui_soundpack/WAV/Minimalist7.wav")
const MENU_MUSIC = preload("res://assets/music/Cleyton RX - Underwater.wav")


func _ready() -> void:
	handle_connecting_signals()
	AudioManager.play_music(MENU_MUSIC)
	version_label.text += ProjectSettings.get_setting("application/config/version") + "."
	if OS.has_feature("debug"):
		version_label.text += "debug"
	else:
		version_label.text += "release"


func handle_connecting_signals() -> void:
	play_button.button_down.connect(on_play_pressed)
	options_button.button_down.connect(on_options_pressed)
	credits_button.button_down.connect(on_credits_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	save_selection_menu.exit_save_selection_menu.connect(on_exit_save_selection_menu)
	create_world_menu.exit_create_world_menu.connect(on_exit_create_world_menu)
	options_menu.exit_options_menu.connect(on_exit_options_menu)
	credits_menu.exit_credits_menu.connect(on_exit_credits_menu)


func on_play_pressed() -> void:
	margin_container.visible = false
	save_selection_menu.set_process(true)
	save_selection_menu.set_process_unhandled_key_input(true)
	save_selection_menu.visible = true
	AudioManager.play_sound(UI_CLICK_SOUND)
	save_selection_menu.check_for_saves()


func on_quit_pressed() -> void:
	AudioManager.play_sound(UI_CLICK_SOUND)
	get_tree().quit()


func on_options_pressed() -> void:
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.set_process_unhandled_key_input(true)
	options_menu.visible = true
	AudioManager.play_sound(UI_CLICK_SOUND)


func on_credits_pressed() -> void:
	margin_container.visible = false
	credits_menu.set_process(true)
	credits_menu.set_process_unhandled_key_input(true)
	credits_menu.visible = true
	AudioManager.play_sound(UI_CLICK_SOUND)


func on_exit_options_menu() -> void:
	margin_container.visible = true
	options_menu.set_process(false)
	options_menu.set_process_unhandled_key_input(false)
	options_menu.visible = false
	AudioManager.play_sound(UI_CLICK_SOUND)


func on_exit_save_selection_menu() -> void:
	margin_container.visible = true
	save_selection_menu.set_process(false)
	save_selection_menu.set_process_unhandled_key_input(false)
	save_selection_menu.visible = false
	AudioManager.play_sound(UI_CLICK_SOUND)


func on_exit_create_world_menu() -> void:
	create_world_menu.visible = false
	save_selection_menu.set_process(true)
	save_selection_menu.set_process_unhandled_key_input(true)
	save_selection_menu.visible = true
	save_selection_menu.check_for_saves()
	AudioManager.play_sound(UI_CLICK_SOUND)


func on_exit_credits_menu() -> void:
	margin_container.visible = true
	credits_menu.set_process(false)
	credits_menu.set_process_unhandled_key_input(false)
	credits_menu.visible = false
	AudioManager.play_sound(UI_CLICK_SOUND)
