extends CanvasLayer

const SIDE_LABEL = preload("res://utilities/notification_manager/side_label.tscn")

@onready var top: TextureRect = $Top
@onready var mid: Panel = $Mid
@onready var side: VBoxContainer = $Side

var mid_tween_reference: Tween = null
var top_tween_reference: Tween = null


func _ready() -> void:
	mid.modulate = Color(1, 1, 1, 0)
	top.modulate = Color(1, 1, 1, 0)


func show_side(message: String = "Item") -> void:
	var side_label: Label = SIDE_LABEL.instantiate()
	side_label.text = message
	side.add_child(side_label)

	var tween: Tween = side_label.create_tween()
	tween.tween_interval(3.5)
	tween.tween_property(side_label, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.tween_callback(side_label.queue_free)


func show_mid(message: String = "Message") -> void:
	if mid_tween_reference:
		mid_tween_reference.kill()

	mid.find_child("Label").text = message
	mid.modulate = Color(1, 1, 1, 1)

	mid_tween_reference = create_tween()
	mid_tween_reference.tween_interval(2)
	mid_tween_reference.tween_property(mid, "modulate", Color(1, 1, 1, 0), 0.5)


func show_top(message: String = "Area") -> void:
	if top_tween_reference:
		top_tween_reference.kill()

	top.find_child("Label").text = message
	top.scale = Vector2(0.8, 0.8)
	top.modulate = Color(1, 1, 1, 0)

	top_tween_reference = create_tween().set_parallel(true)
	top_tween_reference.tween_property(top, "scale", Vector2(1, 1), 0.5)
	top_tween_reference.tween_property(top, "modulate", Color(1, 1, 1, 1), 0.5)

	top_tween_reference.chain().tween_interval(3)
	top_tween_reference.chain().tween_property(top, "modulate", Color(1, 1, 1, 0), 0.5)
