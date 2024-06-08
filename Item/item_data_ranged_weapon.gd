extends ItemData
class_name ItemDataRangedWeapon

@export var attack_damage : float
@export var attack_knockback : float
@export var attack_cooldown : float
@export var attack_stun_time : float

func use(target) -> void:
	if target.try_attack():
		target.ranged_attack(attack_cooldown, attack_damage, attack_knockback, attack_stun_time)
