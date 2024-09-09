extends BTAction

@export var min_range: int = 40
@export var max_range: int = 100

@export var pos_var: StringName = &"pos"
@export var dir_var: StringName = &"dir"


func _tick(_delta: float) -> Status:
	var pos: Vector2
	var dir: Vector2 = random_dir()

	pos = random_pos(dir)
	blackboard.set_var(pos_var, pos)
	return SUCCESS


func random_pos(dir: Vector2) -> Vector2:
	var distance: Vector2
	distance.x = randi_range(min_range, max_range) * dir.x
	distance.y = randi_range(min_range, max_range) * dir.y
	var final_pos: Vector2 = distance + agent.global_position
	return final_pos


func random_dir() -> Vector2:
	var dir: Vector2
	dir.x = randi_range(-2, 1)
	dir.y = randi_range(-2, 1)
	if abs(dir.x) != dir.x:
		dir.x = -1
	else:
		dir.x = 1
	if abs(dir.y) != dir.y:
		dir.y = -1
	else:
		dir.y = 1
	blackboard.set_var(dir_var, dir)
	return dir
