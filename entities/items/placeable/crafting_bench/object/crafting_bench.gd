extends StaticBody2D

@onready var player: Player = PlayerManager.player
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var grid_container: GridContainer = $CanvasLayer/PanelContainer/VBoxContainer/HBoxContainer/Crafts/GridContainer
const ITEM_BUTTON = preload("res://entities/items/placeable/crafting_bench/object/item_button.tscn")
const RESOURCE_REQUIREMENT = preload("res://entities/items/placeable/crafting_bench/object/resource_requirement.tscn")

@onready var item_label: Label = $CanvasLayer/PanelContainer/VBoxContainer/HBoxContainer/Resources/VBoxContainer/Label
@onready var materials: VBoxContainer = $CanvasLayer/PanelContainer/VBoxContainer/HBoxContainer/Resources/VBoxContainer/Materials
@onready var craft_button: Button = $CanvasLayer/PanelContainer/VBoxContainer/HBoxContainer/Resources/CraftButton

var recipes: Array[CraftingRecipe]

var selected_recipe: CraftingRecipe = null

func _ready() -> void:
	craft_button.button_down.connect(on_craft_button_down)
	var dir: DirAccess = DirAccess.open("res://utilities/crafting_system/recipes/")
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			recipes.append(ResourceLoader.load("res://utilities/crafting_system/recipes/" + file_name))
			file_name = dir.get_next()

func player_interact(_player: Player) -> void:
	canvas_layer.visible = !canvas_layer.visible
	if canvas_layer.visible:
		populate_grid()

func on_save_chunk(saved_data: Array[SavedData]) -> void:
	if $HealthComponent.health <= 0:
		return
	var entity_data: SavedData = SavedData.new()
	entity_data.position = global_position
	entity_data.scene_path = scene_file_path

	saved_data.append(entity_data)

func on_load_chunk(saved_data: SavedData) -> void:
	global_position = saved_data.position

func populate_grid() -> void:
	for child in grid_container.get_children():
		child.queue_free()
	for recipe in recipes:
		var item_button: TextureButton = ITEM_BUTTON.instantiate()
		item_button.crafting_recipe = recipe
		grid_container.add_child(item_button)

func update_screen(crafting_recipe: CraftingRecipe) -> void:
	item_label.text = crafting_recipe.item.name
	for child in materials.get_children():
		child.queue_free()
	for requirement in crafting_recipe.requirements:
		var resource_requirement: PanelContainer = RESOURCE_REQUIREMENT.instantiate()
		resource_requirement.crafting_recipe_requirement = requirement
		materials.add_child(resource_requirement)
	selected_recipe = crafting_recipe
	if can_craft(crafting_recipe):
		craft_button.visible = true
	else:
		craft_button.visible = false

func can_craft(crafting_recipe: CraftingRecipe) -> bool:
	var _can_craft: bool = true
	for requirement: CraftingRecipeRequirement in crafting_recipe.requirements:
		if not player.inventory_data.get_amount(requirement.item) >= requirement.quantity:
			_can_craft = false
	return _can_craft

func on_craft_button_down() -> void:
	if can_craft(selected_recipe):
		var slot_data: SlotData = SlotData.new()
		slot_data.item_data = selected_recipe.item
		slot_data.set_quantity(1)
		for requirement: CraftingRecipeRequirement in selected_recipe.requirements:
			player.inventory_data.remove_item(requirement.item, requirement.quantity)
		WorldManager.spawn_pickup(slot_data, player.global_position)
	update_screen(selected_recipe)
