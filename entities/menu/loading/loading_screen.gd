extends Control

@onready var progress_number: Label = $MarginContainer2/HBoxContainer/VBoxContainer2/ProgressNumber
@onready var progress_bar: ProgressBar = $MarginContainer2/HBoxContainer/VBoxContainer2/ProgressBar
@onready var background: TextureRect = $MarginContainer/Background
@onready var scene_name: Label = $MarginContainer2/HBoxContainer/VBoxContainer/SceneName


func _ready() -> void:
	set_process(true)
	ResourceLoader.load_threaded_request(Global.next_scene)
	scene_name.text = Global.next_scene_name
	background.texture = Global.next_scene_background


func _process(_delta: float) -> void:
	var progress: Array = []
	ResourceLoader.load_threaded_get_status(Global.next_scene, progress)
	progress_bar.value = progress[0] * 100
	progress_number.text = str(int(progress[0] * 100)) + "%"

	if progress[0] == 1:
		set_process(false)
		var packed_scene: PackedScene = ResourceLoader.load_threaded_get(Global.next_scene)
		await get_tree().create_timer(2).timeout
		SceneTransition.change_scene(packed_scene, "fade")
		AudioManager.play_music(null)
