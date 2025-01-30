extends VBoxContainer

@onready var player: Player = PlayerManager.player

const TEMP_WARM = preload("res://entities/player/temperature/art/temp_warm.png")
const TEMP_HOT = preload("res://entities/player/temperature/art/temp_hot.png")
const TEMP_COLD = preload("res://entities/player/temperature/art/temp_cold.png")

@onready var icon: TextureRect = $Temperature
@onready var label: Label = $Label


func _ready() -> void:
	player.temp_changed.connect(on_temp_changed)


func on_temp_changed() -> void:
	label.text = str(player.temp) + "°"
	if player.temp > 30:
		icon.texture = TEMP_HOT
	elif player.temp > 15:
		icon.texture = TEMP_WARM
	else:
		icon.texture = TEMP_COLD
