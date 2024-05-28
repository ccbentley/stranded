extends AbstractItem

func _ready() -> void:
	set_physics_process(false)
	stats = ItemDatabase.get_item("DefaultSword")
	
func use_item() -> void:
	set_physics_process(true)
