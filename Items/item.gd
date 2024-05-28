class_name Item
extends Resource

@export var icon : Texture2D
@export var name : String

@export_enum("Weapon", "Armor", "Potion", "Material")
var type : String = "Weapon"

@export_enum("Common", "Uncommon", "Rare", "Epic", "Legendary")
var rarity : String = "Common"

@export_multiline var description : String

signal item_used

func use_item() -> void:
	item_used.emit()
