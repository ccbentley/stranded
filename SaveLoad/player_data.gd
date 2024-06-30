extends Resource
class_name PlayerData

@export var health: int = 100
@export var save_pos: Vector2

func change_health(value: int):
	health += value

func update_pos(value: Vector2):
	save_pos = value
