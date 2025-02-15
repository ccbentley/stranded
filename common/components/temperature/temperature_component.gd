@icon("icon.svg")
class_name TemperatureComponent
extends Area2D

@onready var player: Player = PlayerManager.player
@onready var timer: Timer = $Timer

@export var value: int = 1
@export var timer_wait_time: float = 1
@export var max_option: bool = false
@export var min_option: bool = false
@export var max_value: int = 0
@export var min_value: int = 0


func _ready() -> void:
	timer.wait_time = timer_wait_time


func _on_timer_timeout() -> void:
	if (max_option and player.temp + value > max_value) or (min_option and player.temp + value < min_value):
		return
	player.increase_temp(value)


func _on_area_entered(area: Node2D) -> void:
	if area is HitboxComponent and area.owner is Player:
		timer.start()


func _on_area_exited(area: Node2D) -> void:
	if area is HitboxComponent and area.owner is Player:
		timer.stop()
