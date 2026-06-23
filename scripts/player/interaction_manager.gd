extends Node3D

signal nearest_changed(interactable: Interactable)

var _nearby: Array[Interactable] = []
var nearest: Interactable = null

@onready var area: Area3D = $InteractionArea

func _ready() -> void:
	add_to_group("interaction_manager")
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)

func _process(_delta: float) -> void:
	_update_nearest()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and nearest:
		nearest.interact()

func _on_area_entered(area_node: Area3D) -> void:
	if area_node is Interactable:
		_nearby.append(area_node)

func _on_area_exited(area_node: Area3D) -> void:
	if area_node is Interactable:
		_nearby.erase(area_node)
		if nearest == area_node:
			nearest = null
			nearest_changed.emit(null)

func _update_nearest() -> void:
	var closest: Interactable = null
	var closest_dist := INF

	for inter in _nearby:
		if not is_instance_valid(inter):
			continue
		var dist := global_position.distance_to(inter.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = inter

	if closest != nearest:
		nearest = closest
		nearest_changed.emit(nearest)
