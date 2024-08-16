extends Line2D

@export var MAX_LENGTH: int = 10
@export var sub_viewport: SubViewport

@export var distance_at_largest_width: float = 16 * 6
@export var smallest_tip_width: float
@export var largest_tip_width: float

var length: float
var queue: Array = []
var offset: Vector2i


func _ready() -> void:
	@warning_ignore("integer_division")
	offset = Vector2i(sub_viewport.size.x / 2, sub_viewport.size.y / 2)


func _process(_delta: float) -> void:
	length = 0

	var pos: Vector2 = owner.global_position + Vector2(offset)
	queue.append(pos)
	if queue.size() > MAX_LENGTH and queue.size() > 2:
		queue.pop_front()

	clear_points()

	var queue_array: Array = queue.duplicate()
	for i in range(queue.size() - 1):
		length += queue_array[i].distance_to(queue_array[i + 1])
		add_point(owner.to_local(queue_array[i]))
	add_point(owner.to_local(queue_array[queue.size() - 1]))

	var width_value: float = lerp(smallest_tip_width, largest_tip_width, inverse_lerp(0, distance_at_largest_width, length))
	width_curve.set_point_value(0, width_value)


func reset_line() -> void:
	clear_points()
	queue.clear()
