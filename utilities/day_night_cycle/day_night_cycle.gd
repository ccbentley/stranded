extends CanvasLayer
class_name DayNightCycle

@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $MarginContainer/ColorRect

enum { DAY, NIGHT }
var state: int = DAY

var length_of_day: float = 120  # Seconds
var length_of_night: float = 120  # Seconds


func _ready() -> void:
	match state:
		DAY:
			timer.wait_time = length_of_day
			color_rect.color.a = 0
		NIGHT:
			timer.wait_time = length_of_night
			color_rect.color.a = 150
	timer.start()


func _on_timer_timeout() -> void:
	match state:
		DAY:
			change_to_night()
			state = NIGHT
		NIGHT:
			change_to_day()
			state = DAY
			Global.world_data.day_count += 1


func change_to_night() -> void:
	animation_player.play("day_to_night")
	timer.wait_time = length_of_night
	timer.start()


func change_to_day() -> void:
	animation_player.play("night_to_day")
	timer.wait_time = length_of_day
	timer.start()
