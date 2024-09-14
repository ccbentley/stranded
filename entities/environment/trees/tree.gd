extends EnvironmentObject

@onready var sprite_2d: Sprite2D = $Sprite2D
const green_tree_textures: Array = [
	"res://entities/environment/trees/art/green_tree_1.png",
	"res://entities/environment/trees/art/green_tree_2.png",
	"res://entities/environment/trees/art/green_tree_3.png",
]
const orange_tree_textures: Array = [
	"res://entities/environment/trees/art/orange_tree_1.png",
	"res://entities/environment/trees/art/orange_tree_2.png",
	"res://entities/environment/trees/art/pink_tree_1.png",
]
const snowy_tree_textures: Array = [
	"res://entities/environment/trees/art/snowy_tree_1.png",
	"res://entities/environment/trees/art/snowy_tree_2.png",
	"res://entities/environment/trees/art/snowy_tree_3.png",
]


func _ready() -> void:
	var random: float = randf()
	if random < 0.75:
		sprite_2d.texture = load(green_tree_textures.pick_random())
	else:
		sprite_2d.texture = load(orange_tree_textures.pick_random())
