class_name AbstractItem
extends Sprite2D

@onready var collision = $Area2D/CollisionShape2D
@onready var player = get_tree().current_scene.find_child("player")

var stats : Item = null:
	set(value):
		stats = value
		
		if value != null:
			texture = value.icon
			stats.connect("item_used",use_item)
			
func use_item() -> void:
	pass

func _on_player_entered(body) -> void:
	if body is Player:
		body.add_item(stats)
		call_deferred("reparent",body)
