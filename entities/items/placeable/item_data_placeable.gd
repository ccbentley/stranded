extends ItemData
class_name ItemDataPlaceable

@export var placeable_object_path: String


func use(target: Node2D) -> void:
	var placeable_object: PackedScene = load(placeable_object_path)
	target.place_object(placeable_object)
