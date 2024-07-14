@icon("res://Art/Material Icons/call_to_action_24dp_E8EAED_FILL1_wght400_GRAD0_opsz24.svg")
extends Node2D
class_name HealthBarComponent

@export var health_component : HealthComponent

@onready var health_bar: ProgressBar = $HealthBar
@onready var damage_bar: ProgressBar = $HealthBar/DamageBar
@onready var timer: Timer = $HealthBar/Timer

func _ready() -> void:
	health_component.damaged.connect(self.damaged)

	health_bar.max_value = health_component.MAX_HEALTH
	health_bar.value = health_component.health
	damage_bar.max_value = health_component.MAX_HEALTH
	damage_bar.value = health_component.health
	health_bar.visible = false

func damaged(prev_health: float, health: float) -> void:
	health_bar.value = health

	if health < health_component.MAX_HEALTH:
		health_bar.visible = true

	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health

func _on_timer_timeout() -> void:
	damage_bar.value = health_component.health
