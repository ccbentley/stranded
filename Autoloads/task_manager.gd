extends Node

class Task:
	var id : int

	signal completed

	func _init(id: int) -> void:
		self.id = id

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

class WaitingTask:
	var action : Callable
	var high_priority := false
	var description := ""

	func _init(action : Callable, high_priority := false, description := "") -> void:
		self.action = action
		self.high_priority = high_priority
		self.description = description

var tasks := []
var waiting_tasks := []
var max_tasks := 1

func create_task(action : Callable, high_priority := false, description := "") -> Task:
	if tasks.size() > max_tasks:  # Check if the queue is full.
		var task := WaitingTask.new(action, high_priority, description)
		waiting_tasks.append(task)  # Add to the waiting list.
		return null
	else:
		var task_id := WorkerThreadPool.add_task(action, high_priority, description)
		var task := Task.new(task_id)
		tasks.append(task)
		return task

func create_group_task(action : Callable, elements : int, tasks_needed := -1, high_priority := false, description := "") -> GroupTask:
	var group_task_id := WorkerThreadPool.add_group_task(action, elements, tasks_needed, high_priority, description,)
	var group_task := GroupTask.new(group_task_id)
	tasks.append(group_task)
	return(group_task)

func _process(_delta: float) -> void:
	var completed_tasks := tasks.filter(
		func completed(task: Task):
			return task.is_completed()
	)

	for completed_task in completed_tasks:
		var task : Task = completed_task
		task.completed.emit()
		tasks.erase(task)

	while tasks.size() < max_tasks and waiting_tasks.size() > 0:
		var next_task = waiting_tasks.pop_front()
		create_task(next_task.action, next_task.high_priority, next_task.description)
