@icon("icon.svg")
extends Node2D
class_name HealthComponent

@export var anim: AnimationPlayer

@export var MAX_HEALTH: float = 10.0
var health: float
var dead: bool = false

@export var drop_data: Array[LootData]
var slot_datas: Array[SlotData]

@export var hit_sfx: AudioStream
@export var death_sfx: AudioStream

signal damaged(prev_health: float, health: float)
signal died
signal health_updated


func _ready() -> void:
	health = MAX_HEALTH

	if drop_data:
		for drop: LootData in drop_data:
			var slot_data: LootData = LootData.new()
			slot_data.item_data = drop.item_data
			slot_data.quantity = drop.quantity
			slot_data.drop_chance = drop.drop_chance
			slot_datas.append(slot_data)

func set_health(value: float) -> void:
	health = value
	health_updated.emit()

func damage(attack: Attack) -> void:
	var prev_health: float = health
	health -= attack.attack_damage
	health = min(MAX_HEALTH, health)

	damaged.emit(prev_health, health)

	if anim and anim.has_animation("hit"):
		anim.play("hit")

	if hit_sfx:
		AudioManager.play_sound_2d(hit_sfx, 0, global_position, true)

	if health <= 0 and not dead:
		dead = true
		died.emit()
		if death_sfx:
			AudioManager.play_sound_2d(death_sfx, 0, global_position, true)
		if slot_datas:
			for drop: LootData in slot_datas:
				var roll: float = randf()
				if roll < drop.drop_chance:
					WorldManager.spawn_pickup(drop, global_position)
		if anim and anim.has_animation("death"):
			anim.play("death")
			await anim.animation_finished
		if owner is not Player:
			owner.call_deferred("queue_free")
		else:
			Global.load_next_scene()
