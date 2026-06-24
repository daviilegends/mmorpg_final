class_name InventoryManager
extends Node

signal inventory_changed
signal item_added(item: ItemResource, amount: int)
signal bag_added(bag_index: int)

const SLOTS_PER_BAG := 8
const MAX_BAGS := 5

var bags: Array[Array] = []

func _ready() -> void:
	add_to_group("inventory")
	add_bag()

func add_bag() -> bool:
	if bags.size() >= MAX_BAGS:
		return false
	var bag: Array[Dictionary] = []
	for i in range(SLOTS_PER_BAG):
		bag.append({})
	bags.append(bag)
	bag_added.emit(bags.size() - 1)
	inventory_changed.emit()
	return true

func get_bag_count() -> int:
	return bags.size()

func get_total_slots() -> int:
	return bags.size() * SLOTS_PER_BAG

func get_slot(bag_idx: int, slot_idx: int) -> Dictionary:
	if bag_idx < 0 or bag_idx >= bags.size():
		return {}
	if slot_idx < 0 or slot_idx >= SLOTS_PER_BAG:
		return {}
	return bags[bag_idx][slot_idx]

func add_item(item: ItemResource, amount: int = 1) -> int:
	var remaining := amount

	for bag in bags:
		for i in range(SLOTS_PER_BAG):
			if remaining <= 0:
				break
			if bag[i].is_empty():
				continue
			if bag[i].item.id != item.id:
				continue
			var space: int = item.max_stack - bag[i].quantity
			if space <= 0:
				continue
			var to_add: int = mini(remaining, space)
			bag[i].quantity += to_add
			remaining -= to_add

	for bag in bags:
		for i in range(SLOTS_PER_BAG):
			if remaining <= 0:
				break
			if not bag[i].is_empty():
				continue
			var to_add: int = mini(remaining, item.max_stack)
			bag[i] = { "item": item, "quantity": to_add }
			remaining -= to_add

	var added := amount - remaining
	if added > 0:
		item_added.emit(item, added)
		inventory_changed.emit()
	return remaining

func remove_item(item_id: String, amount: int = 1) -> int:
	var remaining := amount

	for bag_idx in range(bags.size() - 1, -1, -1):
		for i in range(SLOTS_PER_BAG - 1, -1, -1):
			if remaining <= 0:
				break
			if bags[bag_idx][i].is_empty():
				continue
			if bags[bag_idx][i].item.id != item_id:
				continue
			var to_remove: int = mini(remaining, bags[bag_idx][i].quantity)
			bags[bag_idx][i].quantity -= to_remove
			remaining -= to_remove
			if bags[bag_idx][i].quantity <= 0:
				bags[bag_idx][i] = {}

	if remaining < amount:
		inventory_changed.emit()
	return remaining

func has_item(item_id: String, amount: int = 1) -> bool:
	return get_item_count(item_id) >= amount

func get_item_count(item_id: String) -> int:
	var total := 0
	for bag in bags:
		for slot in bag:
			if slot.is_empty():
				continue
			if slot.item.id == item_id:
				total += slot.quantity
	return total
