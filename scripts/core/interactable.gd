class_name Interactable
extends Area3D

@export var display_name: String = "Object"
@export var interaction_prompt: String = "interact"

signal interacted

func get_prompt_text() -> String:
	return "Press E to %s %s" % [interaction_prompt, display_name]

func interact() -> void:
	interacted.emit()
