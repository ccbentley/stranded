extends Control

@onready var exit_button: Button = $MarginContainer/VBoxContainer/ExitButton

signal exit_options_menu


func _ready() -> void:
	exit_button.button_down.connect(on_exit_pressed)
	set_process(false)


func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu_back"):
		on_exit_pressed()


func on_exit_pressed() -> void:
	SettingsSaveManager.save_settings()
	exit_options_menu.emit()
	set_process(false)
