extends Node2D
class_name HealthComponent

@export var MAX_HEALTH : float = 10.0
var health : float

@export var loot_table: Array[LootData] = []

const PICKUP = preload("res://Item/Pickup/pickup.tscn")

func _ready() -> void:
	health = MAX_HEALTH

func damage(attack: Attack) -> void:
	health -= attack.attack_damage

	if health <= 0:
		#TODO Drop based on random chance
		if loot_table:
			for drop in loot_table.size():
				var pick_up = PICKUP.instantiate()
				pick_up.slot_data = loot_table[drop]
				call_deferred("add_child", pick_up)
				pick_up.call_deferred("set", "global_position", get_parent().global_position)
				pick_up.call_deferred("reparent", $"../..")
			get_parent().call_deferred("queue_free")
