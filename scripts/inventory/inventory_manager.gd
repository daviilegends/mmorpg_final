class_name InventoryManager
extends Node

signal inventory_changed
signal item_added(item: ItemResource, amount: int)
signal bag_equipped(bag_idx: int, bag: BagResource)

const MAX_BAGS := 4
const DEFAULT_SLOTS := 8

var bag_data: Array[BagResource] = []
var bags: Array[Array] = []

func _ready() -> void:
	add_to_group("inventory")
	var default_bag := BagResource.new()
	default_bag.id = "bag_brown_8"
	default_bag.display_name = "Backpack (8 slots)"
	default_bag.slot_count = DEFAULT_SLOTS
	default_bag.color = "brown"
	default_bag.icon = load("res://assets/icons/bags/bag_brown_8.png")
	_add_bag(default_bag)

func _add_bag(bag: BagResource) -> void:
	bag_data.append(bag)
	var slots: Array[Dictionary] = []
	for i in range(bag.slot_count):
		slots.append({})
	bags.append(slots)

func equip_bag(slot_idx: int, bag: BagResource) -> bool:
	if slot_idx <= 0 or slot_idx >= MAX_BAGS:
		return false
	if slot_idx < bag_data.size():
		return false
	while bag_data.size() <= slot_idx:
		_add_bag_placeholder()
	bag_data[slot_idx] = bag
	bags[slot_idx] = []
	for i in range(bag.slot_count):
		bags[slot_idx].append({})
	bag_equipped.emit(slot_idx, bag)
	inventory_changed.emit()
	return true

func swap_bags(from_idx: int, to_idx: int) -> void:
	if from_idx == to_idx:
		return
	# Ensure both indices have entries
	var max_idx: int = maxi(from_idx, to_idx)
	while bag_data.size() <= max_idx:
		_add_bag_placeholder()
	while bags.size() <= max_idx:
		bags.append([])

	var temp_data := bag_data[from_idx]
	bag_data[from_idx] = bag_data[to_idx]
	bag_data[to_idx] = temp_data

	var temp_slots := bags[from_idx]
	bags[from_idx] = bags[to_idx]
	bags[to_idx] = temp_slots

	inventory_changed.emit()

func _add_bag_placeholder() -> void:
	var empty := BagResource.new()
	empty.id = ""
	empty.slot_count = 0
	bag_data.append(empty)
	bags.append([])

func get_bag_count() -> int:
	return bag_data.size()

func get_bag(bag_idx: int) -> BagResource:
	if bag_idx < 0 or bag_idx >= bag_data.size():
		return null
	return bag_data[bag_idx]

func get_bag_slot_count(bag_idx: int) -> int:
	if bag_idx < 0 or bag_idx >= bags.size():
		return 0
	return bags[bag_idx].size()

func get_slot(bag_idx: int, slot_idx: int) -> Dictionary:
	if bag_idx < 0 or bag_idx >= bags.size():
		return {}
	if slot_idx < 0 or slot_idx >= bags[bag_idx].size():
		return {}
	return bags[bag_idx][slot_idx]

func add_item(item: ItemResource, amount: int = 1) -> int:
	var remaining := amount

	for bag in bags:
		for i in range(bag.size()):
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
		for i in range(bag.size()):
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
		for i in range(bags[bag_idx].size() - 1, -1, -1):
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
