extends ItemData
class_name ItemDataRangedWeapon

@export var attack_damage: float
@export var attack_knockback: float
@export var attack_cooldown: float
@export var attack_stun_time: float


func use(target: Node2D, _index: int) -> void:
	if target.try_attack():
		var attack: Attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.attack_knockback = attack_knockback
		attack.attack_cooldown = attack_cooldown
		attack.attack_stun_time = attack_stun_time
		target.ranged_attack(attack)
