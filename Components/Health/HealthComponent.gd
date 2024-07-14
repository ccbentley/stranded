@icon("res://Art/Material Icons/favorite_24dp_E8EAED_FILL1_wght400_GRAD0_opsz24.svg")
extends Node2D
class_name HealthComponent

@export var MAX_HEALTH : float = 10.0
var health : float

@export var drop_data: Array[LootData]
var slot_datas: Array[SlotData]
const WOOD = preload("res://Item/Items/Materials/wood.tres")

signal damaged(prev_health: float, health: float)

func _ready() -> void:
	health = MAX_HEALTH

	if drop_data:
		for drop: LootData in drop_data:
			var slot_data : LootData = LootData.new()
			slot_data.item_data = drop.item_data
			slot_data.quantity = drop.quantity
			slot_data.drop_chance = drop.drop_chance
			slot_datas.append(slot_data)

func damage(attack: Attack) -> void:
	var prev_health : float = health
	health -= attack.attack_damage
	health = min(MAX_HEALTH, health)

	damaged.emit(prev_health, health)

	if health <= 0:
		if slot_datas:
			for drop : LootData in slot_datas:
				var roll : float = randf()
				if roll < drop.drop_chance:
					WorldManager.spawn_pickup(drop, global_position)
		owner.call_deferred("queue_free")

