extends Interactable

func _ready() -> void:
	display_name = "Chest"
	interaction_prompt = "open"
	interacted.connect(_on_interacted)

func _on_interacted() -> void:
	print("[Chest] Player opened the chest!")
