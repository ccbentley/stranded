extends Control

@onready var option_button: OptionButton = $HBoxContainer/OptionButton

const RESOLUTION_DICTONARY: Dictionary = {
	"1152 x 648" : Vector2i(1152, 648),
	"1280 x 720" : Vector2i(1280, 720),
	"1920 x 1080" : Vector2i(1920, 1080)
}

func _ready() -> void:
	add_resolution_items()
	option_button.item_selected.connect(on_resolution_selected)
	load_data()


func load_data() -> void:
	on_resolution_selected(SettingsSaveManager.get_resolution_index())
	option_button.select(SettingsSaveManager.get_resolution_index())

func save_data(index: int) -> void:
	SettingsSaveManager.on_resolution_selected(index)

func add_resolution_items() -> void:
	for resolution_size_text : String in RESOLUTION_DICTONARY:
		option_button.add_item(resolution_size_text)

func on_resolution_selected(index: int) -> void:
	DisplayServer.window_set_size(RESOLUTION_DICTONARY.values()[index])

	save_data(index)
