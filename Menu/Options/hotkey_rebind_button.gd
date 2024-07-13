extends Control
class_name HotkeyRebindButton

@onready var label: Label = $HBoxContainer/Label
@onready var button: Button = $HBoxContainer/Button

@export var action_name : String = ""

func _ready() -> void:
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()
	load_keybinds()

func load_keybinds() -> void:
	rebind_action_key(SettingsSaveManager.get_keybind(action_name))

func set_action_name() -> void:
	label.text = "Unassigned"

	match action_name:
		"move_left":
			label.text = "Move Left"
		"move_right":
			label.text = "Move Right"
		"move_up":
			label.text = "Move Up"
		"move_down":
			label.text = "Move Down"
		"inventory":
			label.text = "Inventory"
		"use":
			label.text = "Use"
		"interact":
			label.text = "Interact"

func set_text_for_key() -> void:
	var action_keycode : String = OS.get_keycode_string(SettingsSaveManager.get_keybind(action_name).physical_keycode)
	button.text = "%s" % action_keycode

func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		button.text = "Press any key..."
		set_process_unhandled_key_input(toggled_on)
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
	else:
		set_process_unhandled_key_input(toggled_on)
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
		set_text_for_key()

func _unhandled_key_input(event: InputEvent) -> void:
	rebind_action_key(event)
	button.button_pressed = false

func rebind_action_key(event: InputEventKey) -> void:
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)

	SettingsSaveManager.set_keybind(action_name, event)

	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()
