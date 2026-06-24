class_name ItemResource
extends Resource

enum ItemType { MISC, SEED, CROP, FOOD, TOOL, MATERIAL }

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var item_type: ItemType = ItemType.MISC
@export var max_stack: int = 99
@export var heal_value: int = 0
@export var seed_crop_id: String = ""
