extends ItemData
class_name ItemDataFishingRod

const FISHING_ROD_HOOK = preload("res://entities/items/fishing_rod/hook/fishing_rod_hook.tscn")
var fishing_rod_hook: FishingRodHook = null
@export var max_line_cast_distance: float = 100


func use(target: Node2D) -> void:
	if fishing_rod_hook and not is_instance_valid(fishing_rod_hook):
		target.main.hot_bar_inventory.hot_bar_slot_changed.disconnect(on_hot_bar_slot_changed)
		fishing_rod_hook = null
	if fishing_rod_hook:
		if fishing_rod_hook.animated:
			fishing_rod_hook.animate_fish_line_in()
			target.main.hot_bar_inventory.hot_bar_slot_changed.disconnect(on_hot_bar_slot_changed)
			fishing_rod_hook = null
			return
	else:
		var distance: Vector2 = target.get_global_mouse_position() - target.global_position
		distance.x = clamp(distance.x, -max_line_cast_distance, max_line_cast_distance)
		distance.y = clamp(distance.y, -max_line_cast_distance, max_line_cast_distance)
		fishing_rod_hook = FISHING_ROD_HOOK.instantiate()
		fishing_rod_hook.global_position = distance + target.global_position
		target.main.add_child(fishing_rod_hook)
		target.main.hot_bar_inventory.hot_bar_slot_changed.connect(on_hot_bar_slot_changed.bind(target))
		return


func on_hot_bar_slot_changed(target: Node2D) -> void:
	fishing_rod_hook.animate_fish_line_in()
	fishing_rod_hook = null
	target.main.hot_bar_inventory.hot_bar_slot_changed.disconnect(on_hot_bar_slot_changed)
