extends ItemData
class_name ItemDataFishingRod

const FISHING_ROD_HOOK = preload("res://entities/items/fishing_rod/hook/fishing_rod_hook.tscn")


func use(target: Node2D) -> void:
	var fishing_rod_hook: FishingRodHook = FISHING_ROD_HOOK.instantiate()
	fishing_rod_hook.global_position = target.get_global_mouse_position()
	target.main.add_child(fishing_rod_hook)
