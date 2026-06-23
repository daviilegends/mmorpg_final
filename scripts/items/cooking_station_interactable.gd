extends Interactable

func _ready() -> void:
	display_name = "Cooking Station"
	interaction_prompt = "use"
	interacted.connect(_on_interacted)

func _on_interacted() -> void:
	print("[Cooking] Player used the cooking station!")
