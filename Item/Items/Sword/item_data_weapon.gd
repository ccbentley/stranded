extends ItemData
class_name ItemDataWeapon

@export var attack_damage : int
@export var attack_knockback : int
@export var attack_cooldown : int
@export var attack_range : int

func use(target) -> void:
	if target.try_attack(attack_cooldown, attack_range):
		target.attack(attack_damage, attack_knockback)
