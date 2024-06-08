extends Node2D
class_name HealthComponent

@export var MAX_HEALTH : float = 10.0
var health : float

@export var pickup_data : SlotData

const PICKUP = preload("res://Item/Pickup/pickup.tscn")

func _ready() -> void:
	health = MAX_HEALTH

func damage(attack: Attack) -> void:
	health -= attack.attack_damage

	if health <= 0:
		if pickup_data:
			var pick_up = PICKUP.instantiate()
			pick_up.slot_data = pickup_data
			add_child(pick_up)
			pick_up.global_position = get_parent().global_position
			pick_up.reparent($"../..")
		get_parent().queue_free()
