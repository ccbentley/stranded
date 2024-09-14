@icon("icon.svg")
extends Node2D
class_name HealthBarComponent

@export var health_component: HealthComponent

@onready var health_bar: ProgressBar = $HealthBar
@onready var damage_bar: ProgressBar = $HealthBar/DamageBar
@onready var timer: Timer = $HealthBar/Timer
var damage_bar_tween: Tween


func _ready() -> void:
	health_bar.visible = false
	if health_component:
		health_component.damaged.connect(self.damaged)
		health_bar.max_value = health_component.MAX_HEALTH
		damage_bar.max_value = health_component.MAX_HEALTH
		await get_tree().process_frame
		health_bar.value = health_component.health
		damage_bar.value = health_component.health
		if health_component.health < health_component.MAX_HEALTH:
			health_bar.visible = true


func damaged(prev_health: float, health: float) -> void:
	health_bar.value = health

	if health < health_component.MAX_HEALTH:
		health_bar.visible = true

	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health


func _on_timer_timeout() -> void:
	damage_bar_tween = get_tree().create_tween()
	damage_bar_tween.tween_property(damage_bar, "value", health_component.health, 0.2)
