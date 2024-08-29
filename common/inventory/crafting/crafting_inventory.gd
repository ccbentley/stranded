extends Inventory
class_name CraftingInventory

const recipes: Dictionary = {
	"Stick": {
		"output": "res://entities/items/materials/stick/stick.tres",
		"materials": {
			"Wood": 1,
		}
	},
	"Boat": {
		"output": "res://entities/items/placeable/boat/boat.tres",
		"materials": {
			"Wood": 5,
		}
	},
	"Fishing Rod": {
		"output": "res://entities/items/fishing_rod/fishing_rod.tres",
		"materials": {
			"Stick": 2,
			"Wood": 2,
		}
	},
	"Wooden Pickaxe": {
		"output": "res://entities/items/melee/pickaxe/wooden/wooden_pickaxe.tres",
		"materials": {
			"Wood": 3,
			"Stick": 1,
		}
	}
}

@export var player: Player
var _inventory_data: InventoryData


func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory_data)
	_inventory_data = inventory_data


func connect_player_inventory_updated(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(discard_inventory_data)


func discard_inventory_data(__inventory_data: InventoryData) -> void:
	populate_item_grid(_inventory_data)


func populate_item_grid(inventory_data: InventoryData) -> void:
	for child in item_grid.get_children():
		child.queue_free()
		inventory_data.slot_datas.clear()

	var crafts_visible: bool = false

	for recipe_name: String in recipes:
		var recipe: Dictionary = recipes[recipe_name]
		var can_craft: bool = true
		for mat: String in recipe["materials"]:
			var required_amount: int = recipe["materials"][mat]
			if not player.inventory_data.get_amount(mat) >= required_amount:
				can_craft = false
		if can_craft:
			crafts_visible = true
			var slot: Slot = SLOT.instantiate()
			item_grid.add_child(slot)
			var slot_data: SlotData = SlotData.new()
			slot_data.item_data = load(recipe["output"])
			slot_data.set_quantity(1)
			slot.set_slot_data(slot_data)
			inventory_data.slot_datas.append(slot_data)
			slot.slot_clicked.connect(inventory_data.on_slot_clicked)
			slot.slot_clicked.connect(
				func(_index: int, button: int) -> void:
					if button == MOUSE_BUTTON_LEFT:
						for mat: String in recipe["materials"]:
							var required_amount: int =recipe ["materials"][mat]
							player.inventory_data.remove_item(mat, required_amount)
						AudioManager.play_sound(load("res://assets/sounds/pop.ogg"), 0, true)
			)
	if crafts_visible:
		self.visible = true
	else:
		self.visible = false
