extends ItemData
class_name ItemDataMeleeWeapon

@export var attack_damage : float
@export var attack_knockback : float
@export var attack_cooldown : float
@export var attack_range : float
@export var attack_stun_time : float

func use(target) -> void:
	if target.try_attack():
		target.melee_attack(attack_range, attack_cooldown, attack_damage, attack_knockback, attack_stun_time, 0)
