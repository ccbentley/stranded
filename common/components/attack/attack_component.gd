@icon("icon.svg")
extends Area2D
class_name AttackComponent

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _attack: Attack


func _ready() -> void:
	collision_shape.disabled = true


func attack(attack_stats: Attack) -> void:
	_attack = attack_stats
	collision_shape.disabled = false
	await get_tree().create_timer(0.1).timeout
	collision_shape.disabled = true


func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent and area.type & _attack.material_type:
		if not area.owner == self.owner:
			area.damage(_attack)
			WorldManager.freeze_engine()
