@icon("res://Art/Material Icons/pageless_24dp_E8EAED_FILL1_wght400_GRAD0_opsz24.svg")
extends Area2D
class_name HitboxComponent

@export var health_component: HealthComponent

@export_flags("Enemy", "Wood", "Stone", "Grass") var type: int = 0

func damage(attack: Attack) -> void:
	if health_component:
		health_component.damage(attack)
