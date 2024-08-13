extends Control

@onready var tab_container: TabContainer = $TabContainer
const UI_CLICK_SOUND = preload("res://assets/sounds/ui_soundpack/WAV/Minimalist7.wav")


func _ready() -> void:
	tab_container.tab_clicked.connect(on_tab_container_clicked)


func on_tab_container_clicked(_tab: int) -> void:
	AudioManager.play_sound(UI_CLICK_SOUND)
