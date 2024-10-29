extends ItemData
class_name ItemDataPlaceable

@export var placeable_object_path: String
@export var max_placeable_distance: float = 50
@export_flags("Water", "Sand", "Grass") var placeable_tile_types: int = 0
