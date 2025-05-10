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
	if _attack:
		if area is HitboxComponent and area.type & _attack.material_type:
			if area.owner != self.owner.get_parent().owner:
				area.damage(_attack)
				var knockback_direction: Vector2 = (area.owner.global_position - self.owner.get_parent().owner.global_position).normalized()
				for child in area.owner.get_children():
					if child is KnockbackComponent:
						child.apply_knockback(knockback_direction, _attack.attack_knockback, 0.12)
				self.owner.get_parent().owner.knockback_component.apply_knockback(-knockback_direction, _attack.attack_knockback/2, 0.12)
				#WorldManager.freeze_engine()
