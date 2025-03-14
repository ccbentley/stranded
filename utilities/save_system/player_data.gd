extends Resource
class_name PlayerData

@export var health: float
@export var position: Vector2
@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip
@export var is_facing_right: bool
@export var hunger: float
@export var saturation: float
@export var temp: int

@export var quests: Array[QuestData]
