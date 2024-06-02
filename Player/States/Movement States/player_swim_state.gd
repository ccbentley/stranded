class_name PlayerSwimState
extends State

@export var actor : Player
@export var anim : AnimatedSprite2D

func _ready() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)

func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(delta) -> void:
	pass
