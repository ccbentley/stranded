extends Resource
class_name ItemData

@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var texture: Texture2D
@export var held_offset: Vector2 = Vector2(0,0)

func use(_target : Node2D) -> void:
	pass
