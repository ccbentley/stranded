extends BTAction

@export var target_pos_var: StringName = &"pos"
@export var dir_var: StringName = &"dir"

@export var speed_var: int = 20
@export var tolerance: int = 10


func _tick(_delta: float) -> Status:
	var target_pos: Vector2 = blackboard.get_var(target_pos_var, Vector2.ZERO)
	var dir: Vector2 = blackboard.get_var(dir_var)

	if WorldManager.world.tile_map.get_tile_type(target_pos) == 0:
		agent.move(dir, 0)
		return SUCCESS

	if abs(agent.global_position.x - target_pos.x) < tolerance or abs(agent.global_position.y - target_pos.y) < tolerance:
		agent.move(dir, 0)
		return SUCCESS
	else:
		agent.move(dir, speed_var)
		return RUNNING
