extends PanelContainer

@onready var texture_rect = $TextureRect

var stats : Item = null:
	set(value):
		stats = value
		
		if value != null:
			texture_rect.texture = value.icon
		else:
			texture_rect.texture = value
