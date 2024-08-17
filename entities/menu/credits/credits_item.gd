extends Control

@export var title: String = "Title"
@export var author: String = "Author"

@onready var title_label: Label = $HBoxContainer/Title
@onready var author_label: Label = $HBoxContainer/Author


func _ready() -> void:
	title_label.text = title
	author_label.text = author
