extends PanelContainer

@onready var player: Player = PlayerManager.player

@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect
@onready var label: Label = $HBoxContainer/Label
@onready var quantity_label: Label = $Label2

var crafting_recipe_requirement: CraftingRecipeRequirement

func _ready() -> void:
	if crafting_recipe_requirement:
		texture_rect.texture = crafting_recipe_requirement.item.texture
		label.text = crafting_recipe_requirement.item.name
		var player_amount: int = player.inventory_data.get_amount(crafting_recipe_requirement.item)
		var required_amount: int = crafting_recipe_requirement.quantity
		quantity_label.text = str(player_amount) + " / " + str(required_amount)
		if player_amount >= required_amount:
			quantity_label.modulate = Color.GREEN
