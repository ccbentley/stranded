extends StaticBody2D

signal toggle_inventory(external_inventory_owner: Node2D)

@export var inventory_data: InventoryData


func player_interact(_player: Player) -> void:
	toggle_inventory.emit(self)
