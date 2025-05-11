extends CharacterBody2D

@onready var sprite: Sprite2D = $CharacterSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent
var is_facing_right: bool = true:
	set(value):
		if value and is_facing_right != value:
			# Turn right
			var turn_tween: Tween = get_tree().create_tween()
			turn_tween.tween_property(sprite, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		elif not value and is_facing_right != value:
			# Turn left
			var turn_tween: Tween = get_tree().create_tween()
			turn_tween.tween_property(sprite, "scale", Vector2(-1, 1), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		is_facing_right = value
var can_move: bool = true


func on_save_chunk(saved_data: Array[SavedData]) -> void:
	if $HealthComponent.health <= 0:
		return
	var entity_data: SavedData = SavedData.new()
	entity_data.position = global_position
	entity_data.scene_path = scene_file_path
	entity_data.health = health_component.health

	saved_data.append(entity_data)


func on_load_chunk(saved_data: SavedData) -> void:
	global_position = saved_data.position
	health_component.set_health(saved_data.health)


func move(dir: Vector2, speed: float) -> void:
	if can_move:
		velocity = (dir.normalized() * speed)
		if dir.x < 0:
			is_facing_right = false
		else:
			is_facing_right = true


func _physics_process(_delta: float) -> void:
	move_and_slide()
	play_anim()


func play_anim() -> void:
	if animation_player.is_playing() and (animation_player.current_animation == "hit" or animation_player.current_animation == "death"):
		return
	if velocity != Vector2.ZERO:
		animation_player.play("walk")
	else:
		animation_player.play("idle")
