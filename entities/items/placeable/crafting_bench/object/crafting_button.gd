extends TextureButton

@export var crafting_recipe: CraftingRecipe

func _ready() -> void:
	if crafting_recipe:
		self.button_down.connect(on_button_down)
		self.texture_normal = crafting_recipe.item.texture
	
func on_button_down() -> void:
	get_parent().owner.update_screen(crafting_recipe)
	AudioManager.play_sound(load("res://assets/sounds/ui/button_click.wav"), 0, true)
