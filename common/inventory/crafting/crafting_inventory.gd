extends Inventory
class_name CraftingInventory

var recipes: Array[CraftingRecipe]

func _ready() -> void:
	var dir: DirAccess = DirAccess.open("res://utilities/crafting_system/recipes/")
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			recipes.append(ResourceLoader.load("res://utilities/crafting_system/recipes/" + file_name))
			file_name = dir.get_next()

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

	for recipe: CraftingRecipe in recipes:
		var can_craft: bool = true
		for requirement: CraftingRecipeRequirement in recipe.requirements:
			if not player.inventory_data.get_amount(requirement.item) >= requirement.quantity:
				can_craft = false
		if can_craft:
			crafts_visible = true
			var slot: Slot = SLOT.instantiate()
			item_grid.add_child(slot)
			var slot_data: SlotData = SlotData.new()
			slot_data.item_data = recipe.item
			slot_data.set_quantity(1)
			slot.set_slot_data(slot_data)
			inventory_data.slot_datas.append(slot_data)
			slot.slot_clicked.connect(inventory_data.on_slot_clicked)
			slot.slot_clicked.connect(
				func(_index: int, button: int) -> void:
					if button == MOUSE_BUTTON_LEFT:
						for requirement: CraftingRecipeRequirement in recipe.requirements:
							player.inventory_data.remove_item(requirement.item, requirement.quantity)
						AudioManager.play_sound(load("res://assets/sounds/pop.ogg"), 0, true)
			)
	if crafts_visible:
		self.visible = true
	else:
		self.visible = false
