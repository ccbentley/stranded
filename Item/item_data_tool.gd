extends ItemData
class_name ItemDataTool

@export var attack_damage : float
@export var attack_cooldown : float
@export var attack_range : float

@export_flags("Enemy", "Wood", "Stone", "Grass") var break_material = 0

func use(target) -> void:
	target.melee_attack(attack_range, attack_cooldown, attack_damage, 0, 0, break_material)
