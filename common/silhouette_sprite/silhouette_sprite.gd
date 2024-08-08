extends Sprite2D

@onready var silhouette_sprite: Sprite2D = $SilhouetteSprite


# Set the initial values of the relevant properties
func _ready() -> void:
	silhouette_sprite.texture = texture
	silhouette_sprite.offset = offset
	silhouette_sprite.flip_h = flip_h
	silhouette_sprite.flip_v = flip_v
	silhouette_sprite.hframes = hframes
	silhouette_sprite.vframes = vframes
	silhouette_sprite.frame = frame


# Set the silhouette sprite properties when they are changed
func _set(property: StringName, value: Variant) -> bool:
	if is_instance_valid(silhouette_sprite):
		match property:
			"texture":
				silhouette_sprite.texture = value
			"offset":
				silhouette_sprite.offset = value
			"flip_h":
				silhouette_sprite.flip_h = value
			"flip_v":
				silhouette_sprite.flip_v = value
			"hframes":
				silhouette_sprite.hframes = value
			"vframes":
				silhouette_sprite.vframes = value
			"frame":
				silhouette_sprite.frame = value
	return false
