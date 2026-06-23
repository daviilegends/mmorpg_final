extends Label

var _manager: Node = null

func _ready() -> void:
	text = ""
	await get_tree().process_frame
	var managers := get_tree().get_nodes_in_group("interaction_manager")
	if managers.size() > 0:
		_manager = managers[0]
		_manager.nearest_changed.connect(_on_nearest_changed)

func _on_nearest_changed(interactable: Interactable) -> void:
	if interactable:
		text = interactable.get_prompt_text()
	else:
		text = ""
