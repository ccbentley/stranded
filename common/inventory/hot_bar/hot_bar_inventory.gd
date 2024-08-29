extends PanelContainer

signal hot_bar_use(index: int)
signal hot_bar_slot_changed

const SLOT = preload("res://common/inventory/slot.tscn")

var selected_slot: int = 0:
	set(value):
		if selected_slot != value:
			selected_slot = value
			var slots: Array = h_box_container.get_children()
			if selected_slot > slots.size() - 1:
				selected_slot = 0
			elif selected_slot < 0:
				selected_slot = slots.size() - 1
			selected.position = Vector2(68 * selected_slot, 0) + Vector2(40, 40)
			cached_slot_data = _slot_datas[selected_slot]

var cached_slot_data: SlotData = null:
	set(value):
		if not value or cached_slot_data != value:
			cached_slot_data = value
			player.hold_item(null)
			if _slot_datas[selected_slot]:
				player.hold_item(_slot_datas[selected_slot].item_data.scene)

var _slot_datas: Array[SlotData] = []

@export var player: CharacterBody2D

@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer
@onready var selected: Sprite2D = $MarginContainer/Selected


func _ready() -> void:
	await get_tree().process_frame
	selected_slot = -1
	selected_slot = 0


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
	if event.is_action_pressed("use"):
		hot_bar_use.emit(selected_slot)

	if event.is_action_pressed("scroll_down"):
		selected_slot += 1
		hot_bar_slot_changed.emit()
	elif event.is_action_pressed("scroll_up"):
		selected_slot -= 1
		hot_bar_slot_changed.emit()


func populate_hot_bar(inventory_data: InventoryData) -> void:
	for child in h_box_container.get_children():
		child.queue_free()

	for slot_data: SlotData in inventory_data.slot_datas.slice(0, 6):
		var slot: Slot = SLOT.instantiate()
		h_box_container.add_child(slot)

		if slot_data:
			slot.set_slot_data(slot_data)

	_slot_datas = inventory_data.slot_datas.slice(0, 6)

	cached_slot_data = _slot_datas[selected_slot]
