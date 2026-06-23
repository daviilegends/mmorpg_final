extends Camera3D

@export var target: NodePath
@export var distance: float = 12.0
@export var min_distance: float = 3.0
@export var max_distance: float = 25.0
@export var zoom_speed: float = 1.5
@export var mouse_sensitivity: float = 0.003
@export var smooth_speed: float = 8.0
@export var pitch_min: float = -80.0
@export var pitch_max: float = -10.0

var _target_node: Node3D
var _yaw: float = 0.0
var _pitch: float = -35.0
var _rotating: bool = false
var _drag_threshold: float = 4.0
var _mouse_press_pos: Vector2 = Vector2.ZERO
var _dragged: bool = false
var _sensitivity_scale: float = 3.0

func _ready() -> void:
	add_to_group("player_camera")
	if target:
		_target_node = get_node(target)
	top_level = true

func set_sensitivity_scale(value: float) -> void:
	_sensitivity_scale = value

func get_sensitivity_scale() -> float:
	return _sensitivity_scale

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT:
			if mb.pressed:
				_rotating = true
				_dragged = false
				_mouse_press_pos = mb.position
			else:
				_rotating = false
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = clampf(distance - zoom_speed, min_distance, max_distance)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = clampf(distance + zoom_speed, min_distance, max_distance)

	if event is InputEventMouseMotion and _rotating:
		var mm := event as InputEventMouseMotion
		if not _dragged:
			if _mouse_press_pos.distance_to(mm.position) > _drag_threshold:
				_dragged = true
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if _dragged:
			var sens := mouse_sensitivity * _sensitivity_scale
			_yaw -= mm.relative.x * sens
			_pitch -= mm.relative.y * sens
			_pitch = clampf(_pitch, deg_to_rad(pitch_min), deg_to_rad(pitch_max))

func _physics_process(delta: float) -> void:
	if not _target_node:
		return

	var pivot := _target_node.global_position + Vector3(0, 1.2, 0)
	var offset := Vector3.ZERO
	offset.x = distance * cos(_pitch) * sin(_yaw)
	offset.y = distance * -sin(_pitch)
	offset.z = distance * cos(_pitch) * cos(_yaw)

	var desired := pivot + offset
	global_position = global_position.lerp(desired, smooth_speed * delta)
	look_at(pivot, Vector3.UP)

func was_drag() -> bool:
	return _dragged

func get_yaw() -> float:
	return _yaw
