extends Control

const MAIN_MENU = preload("res://entities/menu/main/main_menu.tscn")
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("splash_screen")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	SceneTransition.change_scene(MAIN_MENU, "fade")


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu_back"):
		get_tree().change_scene_to_packed(MAIN_MENU)
