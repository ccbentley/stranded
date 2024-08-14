extends Node

var player: Player


func use_slot_data(slot_data: SlotData, index: int) -> void:
	slot_data.item_data.use(player, index)


func get_global_position() -> Vector2:
	return player.global_position
