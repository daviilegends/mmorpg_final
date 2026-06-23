extends CharacterBody3D

@export var move_speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var gravity: float = 20.0

@onready var model: Node3D = $Model
@onready var camera: Camera3D = $Camera3D

func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_forward", "move_backward")

	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()

	var cam_yaw: float = camera.get_yaw() if camera.has_method("get_yaw") else 0.0
	var forward := Vector3(sin(cam_yaw), 0, cos(cam_yaw))
	var right := Vector3(cos(cam_yaw), 0, -sin(cam_yaw))
	var move_dir := (forward * input_dir.y + right * input_dir.x)

	velocity.x = move_dir.x * move_speed
	velocity.z = move_dir.z * move_speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()

	if move_dir.length() > 0.1 and model:
		var target_angle := atan2(move_dir.x, move_dir.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * delta)
