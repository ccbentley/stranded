extends Control
class_name MainMenu

@onready var play_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/PlayButton
@onready var settings_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/QuitButton

@onready var margin_container: MarginContainer = $MarginContainer
@onready var save_selection_menu: SaveSelectionMenu = $SaveSelectionMenu
@onready var create_world_menu: CreateWorldMenu = $CreateWorldMenu

func _ready() -> void:
	handle_connecting_signals()

func handle_connecting_signals() -> void:
	play_button.button_down.connect(on_play_pressed)
	settings_button.button_down.connect(on_settings_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	save_selection_menu.exit_save_selection_menu.connect(on_exit_save_selection_menu)
	create_world_menu.exit_create_world_menu.connect(on_exit_create_world_menu)

func on_play_pressed() -> void:
	margin_container.visible = false
	save_selection_menu.set_process(true)
	save_selection_menu.visible = true
	save_selection_menu.check_for_worlds()

func on_quit_pressed() -> void:
	get_tree().quit()

func on_settings_pressed() -> void:
	pass

func on_exit_save_selection_menu() -> void:
	margin_container.visible = true
	save_selection_menu.set_process(false)
	save_selection_menu.visible = false

func on_exit_create_world_menu() -> void:
	create_world_menu.visible = false
	save_selection_menu.set_process(true)
	save_selection_menu.visible = true
	save_selection_menu.check_for_worlds()
