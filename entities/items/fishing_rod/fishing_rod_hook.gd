extends Node2D
class_name FishingRodHook

var max_parabola_height: int = 60
signal casted
signal reeled_in


func cast(target_position: Vector2) -> void:
	var control_point: Vector2 = (position + target_position) / 2
	control_point.y -= 100  # Adjust this value to change the height of the parabola
	control_point.y = min(position.y - max_parabola_height, control_point.y)
	control_point.y = max(target_position.y - max_parabola_height, control_point.y)

	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", control_point, 0.4).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", target_position, 0.4).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func() -> void: casted.emit())


func reel_in(start_position: Vector2) -> void:
	var control_point: Vector2 = (position + start_position) / 2
	control_point.y -= 100  # Adjust this value to change the height of the parabola
	control_point.y = min(position.y - max_parabola_height, control_point.y)
	control_point.y = max(start_position.y - max_parabola_height, control_point.y)

	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", control_point, 0.4).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", start_position, 0.4).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func() -> void: reeled_in.emit())
