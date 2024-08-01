class_name PlayerSitState
extends State

@export var actor: Player
@export var anim: AnimatedSprite2D

signal player_exited


func _ready() -> void:
	set_physics_process(false)


func _enter_state() -> void:
	set_physics_process(true)
	anim.play("idle")


func _exit_state() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("dismount"):
		player_exited.emit()
