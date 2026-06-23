extends Interactable

func _ready() -> void:
	display_name = "Door"
	interaction_prompt = "enter"
	interacted.connect(_on_interacted)

func _on_interacted() -> void:
	print("[House] Player entered the house!")
