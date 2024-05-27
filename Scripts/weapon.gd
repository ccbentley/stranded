extends Node2D

var attack_damage : float = 10.0
var knockback_force : float = 100.0
var stun_time : float = 1.5

func _on_area_2d_area_entered(area):
	if area.has_method("damage"):
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.knockback_force = knockback_force
		attack.attack_position = global_position
		attack.stun_time = stun_time
		 
		area.damage(attack)
