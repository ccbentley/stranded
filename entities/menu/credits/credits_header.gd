extends Control

@export var header: String = "Header"

@onready var header_label: Label = $Title


func _ready() -> void:
	header_label.text = header
