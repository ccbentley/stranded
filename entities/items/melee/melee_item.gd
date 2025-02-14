extends Node2D

@onready var attack_cooldown_timer: Timer = $AttackCooldown
@onready var attack_component: AttackComponent = $Sprite2D/AttackComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func melee_attack(attack: Attack) -> void:
	if attack_cooldown_timer.time_left > 0:
		return
	attack_cooldown_timer.start(attack.attack_cooldown)
	attack.attack_position = global_position
	attack_component.attack(attack)
	animation_player.play("slash")
	AudioManager.play_sound(load("res://assets/sounds/woosh.wav"), 0, true)
