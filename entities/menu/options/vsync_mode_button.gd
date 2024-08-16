extends Control

@onready var option_button: OptionButton = $HBoxContainer/OptionButton


func _ready() -> void:
	add_vsync_mode_items()
	option_button.item_selected.connect(on_vsync_mode_selected)
	load_data()


func load_data() -> void:
	on_vsync_mode_selected(SettingsSaveManager.get_vsync_mode_index())
	option_button.select(SettingsSaveManager.get_vsync_mode_index())


func save_data(index: int) -> void:
	SettingsSaveManager.on_vsync_mode_selected(index)


func add_vsync_mode_items() -> void:
	option_button.add_item("Enabled")
	option_button.add_item("Adaptive")
	option_button.add_item("Disabled")


func on_vsync_mode_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		2:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	save_data(index)
