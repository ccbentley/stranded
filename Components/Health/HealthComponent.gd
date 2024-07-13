@icon("res://Art/Icon Pack/potion_03a.png")
extends Node2D
class_name HealthComponent

@export var MAX_HEALTH : float = 10.0
var health : float

@export var drop_data: Array[LootData]
var slot_datas: Array[SlotData]
const WOOD = preload("res://Item/Items/Materials/wood.tres")

@export var health_bar_enabled : bool = true

@onready var health_bar: ProgressBar = $HealthBar
@onready var damage_bar: ProgressBar = $HealthBar/DamageBar
@onready var timer: Timer = $HealthBar/Timer

func _ready() -> void:
	if drop_data:
		for drop: LootData in drop_data:
			var slot_data : LootData = LootData.new()
			slot_data.item_data = drop.item_data
			slot_data.quantity = drop.quantity
			slot_data.drop_chance = drop.drop_chance
			slot_datas.append(slot_data)

	health = MAX_HEALTH

	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	damage_bar.max_value = MAX_HEALTH
	damage_bar.value = health
	health_bar.visible = false

func damage(attack: Attack) -> void:
	var prev_health : float = health
	health -= attack.attack_damage
	health = min(MAX_HEALTH, health)
	health_bar.value = health

	if health < MAX_HEALTH and health_bar_enabled:
		health_bar.visible = true

	if health <= 0:
		if slot_datas:
			for drop : LootData in slot_datas:
				var roll : float = randf()
				if roll < drop.drop_chance:
					WorldManager.spawn_pickup(drop, global_position)
		owner.call_deferred("queue_free")

	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health

func _on_timer_timeout() -> void:
	damage_bar.value = health
