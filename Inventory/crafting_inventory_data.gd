extends InventoryData
class_name CraftingInventoryData


#Override for drop_slot_data to add amount to grabbed slot instead of actaully dropping it
func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data: SlotData = slot_datas[index]
	if slot_data:
		if slot_data.item_data == grabbed_slot_data.item_data:
			grabbed_slot_data.set_quantity(grabbed_slot_data.quantity + slot_data.quantity)
	inventory_updated.emit(self)
	return grabbed_slot_data
