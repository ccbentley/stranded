extends Control

@onready var player: Player = PlayerManager.player


func display_screen() -> void:
	self.visible = true
	get_tree().paused = true
	set_process(true)


func _on_button_button_down() -> void:
	self.visible = false
	get_tree().paused = false
	set_process(false)
	player.health_component.set_health(player.health_component.MAX_HEALTH)
	player.hunger = player.MAX_HUNGER
	player.saturation = player.MAX_SATURATION
	player.temp = player.STARTING_TEMP
	player.health_component.dead = false
	WorldManager.world.tile_map.find_spawn_location()
