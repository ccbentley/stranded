extends Node2D
class_name FishingRodHook

@onready var line_2d: Line2D = $Line2D
@onready var path_2d: Path2D = $Path2D


func draw_curve() -> void:
	path_2d.curve.set_point_position(0, Vector2(0, 0))
	var outX: float = get_mouse_pos().x / 4
	path_2d.curve.set_point_out(0, Vector2(outX, -outX))
	path_2d.curve.set_point_position(1, get_mouse_pos())
	path_2d.curve.set_point_in(1, Vector2(-outX, -outX))


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		draw_curve()


func get_mouse_pos() -> Vector2:
	return get_global_mouse_position() - self.position
