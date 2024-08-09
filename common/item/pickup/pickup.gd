extends StaticBody2D
class_name Pickup

@export var slot_data: SlotData

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	sprite_2d.texture = slot_data.item_data.texture
	animation_player.play("item_bob")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.inventory_data.pick_up_slot_data(slot_data):
		queue_free()
