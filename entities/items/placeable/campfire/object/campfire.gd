extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt_timer: Timer = $HurtTimer
@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("spawn")
	animated_sprite_2d.play("default")

func _on_hurt_timer_timeout() -> void:
	for area in area_2d.get_overlapping_areas():
		if area is HitboxComponent and area.owner != self:
			var attack: Attack = Attack.new()
			attack.attack_damage = 2
			area.damage(attack)


func on_save_chunk(saved_data: Array[SavedData]) -> void:
	if $HealthComponent.health <= 0:
		return
	var entity_data: SavedData = SavedData.new()
	entity_data.position = global_position
	entity_data.scene_path = scene_file_path

	saved_data.append(entity_data)


func on_load_chunk(saved_data: SavedData) -> void:
	global_position = saved_data.position
