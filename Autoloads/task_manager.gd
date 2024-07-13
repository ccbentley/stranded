extends Node

class Task:
	var id : int

	signal completed

	func _init(_id: int) -> void:
		self.id = _id

	func get_processed_element_count() -> int:
		return 1 if is_completed() else 0

	func is_completed() -> bool:
		return WorkerThreadPool.is_task_completed(self.id)

	func wait() -> void:
		WorkerThreadPool.wait_for_task_completion(self.id)

class GroupTask:
	extends Task

	func get_processed_element_count() -> int:
		return WorkerThreadPool.get_group_processed_element_count(self.id)

	func is_completed() -> bool:
		return WorkerThreadPool.is_group_task_completed(self.id)

	func wait() -> void:
		WorkerThreadPool.wait_for_group_task_completion(self.id)

var tasks : Array = []

func create_task(action : Callable, high_priority: bool = false, description: String = "") -> Task:
		var task_id : int = WorkerThreadPool.add_task(action, high_priority, description)
		var task : Task = Task.new(task_id)
		tasks.append(task)
		return task

func create_group_task(action : Callable, elements : int, tasks_needed: int = -1, high_priority: bool = false, description: String= "") -> GroupTask:
	var group_task_id : int = WorkerThreadPool.add_group_task(action, elements, tasks_needed, high_priority, description,)
	var group_task : GroupTask = GroupTask.new(group_task_id)
	tasks.append(group_task)
	return(group_task)

func _process(_delta: float) -> void:
	var completed_tasks : Array = tasks.filter(
		func completed(task: Task) -> bool:
			return task.is_completed()
	)

	for completed_task : Task in completed_tasks:
		var task : Task = completed_task
		task.completed.emit()
		tasks.erase(task)
