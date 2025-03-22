extends StaticBody2D
class_name Pickup

@export var slot_data: SlotData

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	await get_tree().process_frame
	sprite_2d.texture = slot_data.item_data.texture
	animation_player.play("item_spawn")
	await animation_player.animation_finished
	animation_player.play("item_bob")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.inventory_data.pick_up_slot_data(slot_data):
		AudioManager.play_sound(load("res://assets/sounds/pop.ogg"), 0, true)
		Notification.show_side(slot_data.item_data.name + " x" + str(slot_data.quantity))
		queue_free()


func on_save_chunk(saved_data: Array[SavedData]) -> void:
	var entity_data: SavedPickupData = SavedPickupData.new()
	entity_data.position = global_position
	entity_data.scene_path = scene_file_path
	entity_data.slot_data = slot_data

	saved_data.append(entity_data)


func on_load_chunk(saved_data: SavedData) -> void:
	var entity_data: SavedPickupData = saved_data as SavedPickupData

	global_position = entity_data.position
	slot_data = entity_data.slot_data
