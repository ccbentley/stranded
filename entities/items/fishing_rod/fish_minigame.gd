extends CanvasLayer

@onready var target_area: Panel = $MarginContainer/VBoxContainer/Panel/TargetArea
@onready var line: Panel = $MarginContainer/VBoxContainer/Panel/Line
@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar

var start_position: Vector2 = Vector2(0, 0)
var middle_position: Vector2 = Vector2(225, 0)
var end_position: Vector2 = Vector2(450, 0)

signal caught_fish
signal lost_fish


func _ready() -> void:
	set_physics_process(false)
	set_process_unhandled_key_input(false)


func start_minigame() -> void:
	set_physics_process(true)
	set_process_unhandled_key_input(true)
	tween_end()


func end_minigame() -> void:
	set_physics_process(false)
	set_process_unhandled_key_input(false)
	progress_bar.value = 30
	target_area.position = middle_position


func _physics_process(delta: float) -> void:
	progress_bar.value -= delta * 4
	if progress_bar.value <= 0:
		lost_fish.emit()
		return
	if target_area.position <= start_position:
		tween_end()
	elif target_area.position >= end_position:
		tween_start()


func tween_start() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(target_area, "position", start_position, 1).set_ease(Tween.EASE_IN_OUT)


func tween_end() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(target_area, "position", end_position, 1).set_ease(Tween.EASE_IN_OUT)


func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		if is_in_target_area():
			progress_bar.value += 10
			if progress_bar.value >= 100:
				caught_fish.emit()
				return
			if randi_range(1, 2) == 1:
				tween_start()
			else:
				tween_end()
		else:
			progress_bar.value -= 10


func is_in_target_area() -> bool:
	if target_area.position.x < middle_position.x + 75 and target_area.position.x > middle_position.x - 75:
		return true
	return false
