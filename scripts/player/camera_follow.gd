extends Camera3D

@export var target: NodePath
@export var offset: Vector3 = Vector3(0, 10, 8)
@export var smooth_speed: float = 5.0

var _target_node: Node3D

func _ready() -> void:
	if target:
		_target_node = get_node(target)
	top_level = true

func _physics_process(delta: float) -> void:
	if not _target_node:
		return

	var desired_position := _target_node.global_position + offset
	global_position = global_position.lerp(desired_position, smooth_speed * delta)
	look_at(_target_node.global_position, Vector3.UP)
