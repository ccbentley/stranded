extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func change_scene(target: PackedScene, anim: String = "fade") -> void:
	animation_player.play(anim)
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(target)
	animation_player.play_backwards(anim)
