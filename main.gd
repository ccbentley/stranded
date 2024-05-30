extends Node2D

@onready var player : CharacterBody2D = $Player
@onready var inventory_interface : Control = $Player/UI/InventoryInterface

func _ready() -> void:
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)

func toggle_inventory_interface() -> void:
	inventory_interface.visible = not inventory_interface.visible
