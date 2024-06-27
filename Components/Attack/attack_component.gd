extends Area2D
class_name AttackComponent

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _attack : Attack

func _ready() -> void:
	collision_shape.disabled = true

func attack(attack_stats: Attack) -> void:
	_attack = attack_stats
	collision_shape.disabled = false
	await get_tree().create_timer(0.1).timeout
	collision_shape.disabled = true

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent and area.type & _attack.material_type:
		area.damage(_attack)

func set_attack_range(attack_range: float, facing_right: bool) -> void:
	collision_shape.shape.size = Vector2(attack_range, 20)
	if facing_right:
		collision_shape.position = Vector2(attack_range, 0)
	else:
		collision_shape.position = Vector2(-attack_range, 0)
