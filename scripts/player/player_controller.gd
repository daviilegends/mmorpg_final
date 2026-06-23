extends CharacterBody3D

@export var move_speed: float = 5.0
@export var run_speed: float = 9.0
@export var rotation_speed: float = 10.0
@export var gravity: float = 20.0
@export var jump_force: float = 8.0

@onready var model: Node3D = $Model
@onready var camera: Camera3D = $Camera3D

var _anim_player: AnimationPlayer = null
var _current_anim: String = ""
var _is_jumping: bool = false

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	if model and model.has_method("_find_animation_player"):
		_anim_player = model.anim_player

func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_forward", "move_backward")

	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()

	var running := Input.is_key_pressed(KEY_SHIFT)
	var speed := run_speed if running else move_speed

	var cam_yaw: float = camera.get_yaw() if camera.has_method("get_yaw") else 0.0
	var forward := Vector3(sin(cam_yaw), 0, cos(cam_yaw))
	var right := Vector3(cos(cam_yaw), 0, -sin(cam_yaw))
	var move_dir := (forward * input_dir.y + right * input_dir.x)

	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_force
			_is_jumping = true
		else:
			if _is_jumping:
				_is_jumping = false
				_play_anim("Jump_Land")
				await get_tree().create_timer(0.15).timeout
			velocity.y = 0.0
	else:
		velocity.y -= gravity * delta

	move_and_slide()

	if move_dir.length() > 0.1 and model:
		var target_angle := atan2(move_dir.x, move_dir.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * delta)

	_update_animation(move_dir.length(), running)

func _update_animation(move_amount: float, running: bool) -> void:
	if not _anim_player:
		if model and model.get("anim_player"):
			_anim_player = model.anim_player
		if not _anim_player:
			return

	if _is_jumping:
		if velocity.y > 0:
			_play_anim("Jump_Start")
		else:
			_play_anim("Jump_Idle")
		return

	if move_amount > 0.1:
		if running:
			_play_anim("Running_A")
		else:
			_play_anim("Walking_A")
	else:
		_play_anim("Idle_A")

func _play_anim(anim_name: String) -> void:
	if not _anim_player:
		return
	if _current_anim == anim_name:
		return
	if _anim_player.has_animation(anim_name):
		_anim_player.play(anim_name, 0.2)
		_current_anim = anim_name
