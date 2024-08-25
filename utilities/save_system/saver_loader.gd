extends Node

@onready var player: Player = PlayerManager.player
@onready var main: Node2D = get_tree().current_scene


func save_game() -> void:
	var player_data: PlayerData = PlayerData.new()
	player_data.inventory_data = player.inventory_data.duplicate()
	player_data.equip_inventory_data = player.equip_inventory_data.duplicate()
	player_data.position = player.global_position
	player_data.health = player.health_component.health
	ResourceSaver.save(player_data, Global.world_save_file_path + Global.player_save_file_name)

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
	return true
