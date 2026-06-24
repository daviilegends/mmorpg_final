extends Node

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	var inventories := get_tree().get_nodes_in_group("inventory")
	if inventories.is_empty():
		return
	var inv: InventoryManager = inventories[0]

	var items_to_give: Array[Array] = [
		["res://resources/items/carrot_seed.tres", 10],
		["res://resources/items/carrot.tres", 5],
		["res://resources/items/potato.tres", 3],
		["res://resources/items/berry.tres", 8],
		["res://resources/items/carrot_soup.tres", 2],
	]

	for entry in items_to_give:
		var item: ItemResource = load(entry[0])
		if item:
			inv.add_item(item, entry[1])

	inv.add_bag()
	print("[Starter] Gave starter items + extra bag to player")
