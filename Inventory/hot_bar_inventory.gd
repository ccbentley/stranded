extends PanelContainer

signal hot_bar_use(index: int)

const Slot = preload("res://Inventory/slot.tscn")

var selected_slot : int = 1

@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer
@onready var selected: Sprite2D = $MarginContainer/Selected

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_hot_bar)
	populate_hot_bar(inventory_data)
	hot_bar_use.connect(inventory_data.use_slot_data)

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.is_pressed():
		return

	if range(KEY_1, KEY_7).has(event.keycode):
		selected_slot = event.keycode - KEY_1

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				hot_bar_use.emit(selected_slot)
			MOUSE_BUTTON_RIGHT:
				pass

func populate_hot_bar(inventory_data: InventoryData) -> void:
	for child in h_box_container.get_children():
		child.queue_free()

	for slot_data in inventory_data.slot_datas.slice(0,6):
		var slot = Slot.instantiate()
		h_box_container.add_child(slot)

		if slot_data:
			slot.set_slot_data(slot_data)
