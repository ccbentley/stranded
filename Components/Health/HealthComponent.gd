@icon("res://Art/Icon Pack/potion_03a.png")
extends Node2D
class_name HealthComponent

@export var MAX_HEALTH : float = 10.0
var health : float

@export var loot_table: Array[SlotData] = []

@export var health_bar_enabled : bool = true

const PICKUP = preload("res://Item/Pickup/pickup.tscn")

@onready var health_bar: ProgressBar = $HealthBar
@onready var damage_bar: ProgressBar = $HealthBar/DamageBar
@onready var timer: Timer = $HealthBar/Timer

func _ready() -> void:
	health = MAX_HEALTH
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	damage_bar.max_value = MAX_HEALTH
	damage_bar.value = health
	health_bar.visible = false

func damage(attack: Attack) -> void:
	var prev_health = health
	health -= attack.attack_damage
	health = min(MAX_HEALTH, health)
	health_bar.value = health

	if health < MAX_HEALTH and health_bar_enabled:
		health_bar.visible = true

	if health <= 0:
		#TODO Drop based on random chance
		if loot_table:
			for drop in loot_table.size():
				var pick_up = PICKUP.instantiate()
				pick_up.slot_data = loot_table[drop]
				get_parent().get_parent().get_parent().call_deferred("add_child", pick_up)
				pick_up.call_deferred("set", "position", get_parent().global_position)
		get_parent().call_deferred("queue_free")


	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health

func _on_timer_timeout() -> void:
	damage_bar.value = health
