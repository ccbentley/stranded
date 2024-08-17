extends Control

@export var title: String = "Title"
@export var author: String = "Author"
@export var link: String = "Link"

@onready var title_label: Label = $MarginContainer/Title/Title
@onready var author_label: Label = $MarginContainer/Title/Author/Author
@onready var link_button: LinkButton = $MarginContainer/Title/Author/LinkButton
@onready var dash: Label = $MarginContainer/Title/Author/Dash


func _ready() -> void:
	title_label.text = title
	author_label.text = author
	link_button.text = link
	link_button.uri = link
	if link == "":
		dash.visible = false
	else:
		dash.visible = true
