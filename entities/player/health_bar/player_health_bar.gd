extends ProgressBar

@onready var player: Player = PlayerManager.player
@onready var health_component: HealthComponent = player.health_component

@onready var health_bar: ProgressBar = $"."
@onready var damage_bar: ProgressBar = $DamageBar
@onready var timer: Timer = $Timer
var damage_bar_tween: Tween


func _ready() -> void:
	health_component.damaged.connect(self.damaged)
	health_bar.max_value = health_component.MAX_HEALTH
	health_bar.value = health_component.health
	damage_bar.max_value = health_component.MAX_HEALTH
	damage_bar.value = health_component.health


func damaged(prev_health: float, health: float) -> void:
	health_bar.value = health

	if health < health_component.MAX_HEALTH:
		health_bar.visible = true

	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health


func _on_timer_timeout() -> void:
	damage_bar_tween = get_tree().create_tween()
	damage_bar_tween.tween_property(damage_bar, "value", health_component.health, 0.2)