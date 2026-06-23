extends Node3D

signal nearest_changed(interactable: Interactable)

var _nearby: Array[Interactable] = []
var nearest: Interactable = null

@onready var area: Area3D = $InteractionArea
@onready var camera: Camera3D = get_parent().get_node("Camera3D")

func _ready() -> void:
	add_to_group("interaction_manager")
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)

func _process(_delta: float) -> void:
	_update_nearest()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and not mb.pressed:
			if camera.has_method("was_drag") and camera.was_drag():
				return
			_try_interact_at(mb.position)

func _try_interact_at(screen_pos: Vector2) -> void:
	if not camera:
		return

	var from := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	var to := from + dir * 100.0

	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to, 2)
	var result := space.intersect_ray(query)

	if result.is_empty():
		return

	var collider: Object = result.get("collider")
	if collider is Interactable and collider in _nearby:
		(collider as Interactable).interact()

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
