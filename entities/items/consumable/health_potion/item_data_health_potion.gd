extends ItemDataConsumable
class_name ItemDataHealthPotion

@export var heal_value: int


func use(target: Node2D, _index: int) -> void:
	if heal_value != 0:
		target.heal(heal_value)
