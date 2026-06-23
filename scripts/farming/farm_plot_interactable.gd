extends Interactable

func _ready() -> void:
	display_name = "Farm Plot"
	interaction_prompt = "use"
	interacted.connect(_on_interacted)

func _on_interacted() -> void:
	print("[Farm] Player interacted with the farm plot!")
