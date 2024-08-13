extends Control
class_name PauseMenu

var game_paused: bool = false

@onready var main: Node2D = $"../.."
@onready var options_menu: OptionsMenu = $OptionsMenu
@onready var margin_container: MarginContainer = $MarginContainer

const UI_CLICK_SOUND = preload("res://assets/sounds/ui_soundpack/WAV/Minimalist7.wav")


func _ready() -> void:
	set_process_input(true)  # Enable input handling


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()


func toggle_pause() -> void:
	game_paused = !game_paused
	get_tree().paused = game_paused
	self.visible = game_paused


func _on_resume_button_button_down() -> void:
	toggle_pause()
	AudioManager.play_sound(UI_CLICK_SOUND)


func _on_options_button_button_down() -> void:
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true
	AudioManager.play_sound(UI_CLICK_SOUND)


func _on_quit_button_button_down() -> void:
	get_tree().paused = false
	main.save_game()
	AudioManager.play_sound(UI_CLICK_SOUND)
	SceneTransition.change_scene(load("res://entities/menu/main/main_menu.tscn"), "fade")


func _on_options_menu_exit_options_menu() -> void:
	options_menu.visible = false
	margin_container.visible = true
	AudioManager.play_sound(UI_CLICK_SOUND)
