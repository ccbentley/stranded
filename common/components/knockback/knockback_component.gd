@icon("icon.svg")
extends Node2D
class_name KnockbackComponent

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0


func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration


func _physics_process(delta: float) -> void:
	if knockback_timer > 0.0:
		owner.can_move = false
		owner.velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
			owner.velocity = knockback
	else:
		owner.can_move = true
