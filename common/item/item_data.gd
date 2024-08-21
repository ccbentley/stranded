extends Resource
class_name ItemData

@export var scene: PackedScene
@export var useable: bool = false

@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var texture: Texture2D


func use(target: Node2D, index: int) -> void:
	if useable:
		target.use_item(index)
