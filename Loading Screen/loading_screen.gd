extends Control
class_name LoadingScreen

@onready var label: Label = $MarginContainer/VBoxContainer/Label
@onready var progress_number: Label = $MarginContainer/VBoxContainer/ProgressNumber
@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar

func _ready():
	ResourceLoader.load_threaded_request(Global.next_scene)

func _process(delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(Global.next_scene, progress)
	progress_bar.value = progress[0] * 100
	progress_number.text = str(progress[0] * 100) + "%"

	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(Global.next_scene)
		get_tree().change_scene_to_packed(packed_scene)
