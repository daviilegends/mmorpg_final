class_name BagResource
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var slot_count: int = 8
@export var color: String = "brown"
@export var icon: Texture2D

static func get_random_bag() -> BagResource:
	var colors: Array[String] = ["brown", "gold", "red", "green"]
	var slot_options: Array[int] = [6, 8, 12, 18]
	var weights: Array[float] = [40.0, 30.0, 20.0, 10.0]

	var total: float = 0.0
	for w in weights:
		total += w
	var roll: float = randf() * total
	var cumulative: float = 0.0
	var slot_idx: int = 0
	for i in range(weights.size()):
		cumulative += weights[i]
		if roll <= cumulative:
			slot_idx = i
			break

	var color: String = colors[randi() % colors.size()]
	var slots: int = slot_options[slot_idx]

	var bag := BagResource.new()
	bag.id = "bag_%s_%d" % [color, slots]
	bag.display_name = "%s Bag (%d slots)" % [color.capitalize(), slots]
	bag.slot_count = slots
	bag.color = color
	var icon_path: String = "res://assets/icons/bags/bag_%s_%d.png" % [color, slots]
	bag.icon = load(icon_path)
	return bag
