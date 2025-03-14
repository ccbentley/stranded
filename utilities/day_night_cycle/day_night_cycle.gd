extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var day_counter_label: Label = $"../../UI/MarginContainer/VBoxContainer/DayCounter"

var day_counter: int = 0:
	set(value):
		day_counter = value
		day_counter_label.text = "Day " + str(value)
		Notification.show_top("Day " + str(value))

var current_time: float
var total_time: float
var minute_passed: float


func _ready() -> void:
	total_time = animation_player.current_animation_length
	animation_player.advance(8.5 / animation_player.speed_scale)


func _physics_process(_delta: float) -> void:
	current_time = animation_player.current_animation_position

	minute_passed = (current_time / total_time) * (24 * 60)


func next_day() -> void:
	day_counter += 1


func set_current_time(new_time: float) -> void:
	animation_player.advance(-8.5 / animation_player.speed_scale)
	animation_player.advance(new_time / animation_player.speed_scale)
