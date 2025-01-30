extends Node

@onready var player: Player = PlayerManager.player
@onready var main: Node2D = get_tree().current_scene


func save_game() -> void:
	var player_data: PlayerData = PlayerData.new()
	player_data.inventory_data = player.inventory_data.duplicate()
	player_data.equip_inventory_data = player.equip_inventory_data.duplicate()
	player_data.position = player.global_position
	player_data.health = player.health_component.health
	player_data.is_facing_right = player.is_facing_right
	player_data.quests = main.quest_manager.save_quests()
	player_data.hunger = player.hunger
	player_data.saturation = player.saturation
	player_data.temp = player.temp
	ResourceSaver.save(player_data, Global.world_save_file_path + Global.player_save_file_name)

	Global.world_data.day_count = main.day_night_cycle.day_counter
	Global.world_data.current_time = main.day_night_cycle.current_time
	Global.world_data.weather = main.weather_manager.state
	Global.world_data.weather_timer = main.weather_manager.timer.time_left
	ResourceSaver.save(Global.world_data, Global.world_save_file_path + Global.world_save_file_name)

	for loaded_chunk: Vector2i in main.tile_map.loaded_chunks:
		main.tile_map.save_chunk_entities(loaded_chunk)


func load_game() -> bool:
	if not ResourceLoader.exists(Global.world_save_file_path + Global.player_save_file_name):
		return false
	var player_data: PlayerData = ResourceLoader.load(Global.world_save_file_path + Global.player_save_file_name).duplicate()
	player.inventory_data = player_data.inventory_data
	player.equip_inventory_data = player_data.equip_inventory_data
	main.load_inventory()
	main.teleport_player(player_data.position)
	player.health_component.set_health(player_data.health)
	player.health_component.damage(Attack.new())
	player.is_facing_right = player_data.is_facing_right
	main.quest_manager.load_quests(player_data.quests)
	player.hunger = player_data.hunger
	player.saturation = player_data.saturation
	player.temp = player_data.temp

	main.day_night_cycle.day_counter = Global.world_data.day_count
	main.day_night_cycle.set_current_time(Global.world_data.current_time)
	main.weather_manager.state = Global.world_data.weather
	main.weather_manager.set_timer(Global.world_data.weather_timer)

	return true
