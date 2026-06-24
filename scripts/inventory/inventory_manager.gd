class_name InventoryManager
extends Node

signal inventory_changed
signal item_added(item: ItemResource, amount: int)
signal item_removed(item: ItemResource, amount: int)

const MAX_SLOTS := 20

var slots: Array[Dictionary] = []

func _ready() -> void:
	add_to_group("inventory")
	for i in range(MAX_SLOTS):
		slots.append({})

func add_item(item: ItemResource, amount: int = 1) -> int:
	var remaining := amount

	for i in range(MAX_SLOTS):
		if remaining <= 0:
			break
		if slots[i].is_empty():
			continue
		if slots[i].item.id != item.id:
			continue
		var space: int = item.max_stack - slots[i].quantity
		if space <= 0:
			continue
		var to_add: int = mini(remaining, space)
		slots[i].quantity += to_add
		remaining -= to_add

	for i in range(MAX_SLOTS):
		if remaining <= 0:
			break
		if not slots[i].is_empty():
			continue
		var to_add: int = mini(remaining, item.max_stack)
		slots[i] = { "item": item, "quantity": to_add }
		remaining -= to_add

	var added := amount - remaining
	if added > 0:
		item_added.emit(item, added)
		inventory_changed.emit()
	return remaining

func remove_item(item_id: String, amount: int = 1) -> int:
	var remaining := amount

	for i in range(MAX_SLOTS - 1, -1, -1):
		if remaining <= 0:
			break
		if slots[i].is_empty():
			continue
		if slots[i].item.id != item_id:
			continue
		var to_remove: int = mini(remaining, slots[i].quantity)
		slots[i].quantity -= to_remove
		remaining -= to_remove
		if slots[i].quantity <= 0:
			slots[i] = {}

	var removed := amount - remaining
	if removed > 0:
		inventory_changed.emit()
	return remaining

func has_item(item_id: String, amount: int = 1) -> bool:
	var total := 0
	for slot in slots:
		if slot.is_empty():
			continue
		if slot.item.id == item_id:
			total += slot.quantity
	return total >= amount

func get_item_count(item_id: String) -> int:
	var total := 0
	for slot in slots:
		if slot.is_empty():
			continue
		if slot.item.id == item_id:
			total += slot.quantity
	return total

func get_slot(index: int) -> Dictionary:
	if index < 0 or index >= MAX_SLOTS:
		return {}
	return slots[index]
