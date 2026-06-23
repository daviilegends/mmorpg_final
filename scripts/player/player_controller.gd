extends CharacterBody3D

@export var move_speed: float = 5.0
@export var run_speed: float = 9.0
@export var rotation_speed: float = 10.0
@export var gravity: float = 20.0
@export var jump_force: float = 8.0

@onready var model: Node3D = $Model
@onready var camera: Camera3D = $Camera3D

var _anim_player: AnimationPlayer = null
var _sprite_player: Node = null
var _current_anim: String = ""
var _is_jumping: bool = false
var _landing_timer: float = 0.0

func _physics_process(delta: float) -> void:
	if _landing_timer > 0.0:
		_landing_timer -= delta

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
				_play_anim("Jump_Land", "idle")
				_landing_timer = 0.2
			velocity.y = 0.0
	else:
		velocity.y -= gravity * delta

	move_and_slide()

	if move_dir.length() > 0.1 and model:
		var target_angle := atan2(move_dir.x, move_dir.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * delta)

	if _landing_timer <= 0.0:
		_update_animation(move_dir.length(), running)

func _update_animation(move_amount: float, running: bool) -> void:
	_find_anim_source()

	if _is_jumping:
		if velocity.y > 0:
			_play_anim("Jump_Start", "jump")
		else:
			_play_anim("Jump_Idle", "jump")
		return

	if move_amount > 0.1:
		if running:
			_play_anim("Running_A", "run")
		else:
			_play_anim("Walking_A", "walk")
	else:
		_play_anim("Idle_A", "idle")

func _find_anim_source() -> void:
	if _anim_player or _sprite_player:
		return
	if model and model.get("anim_player"):
		_anim_player = model.anim_player
	if not _anim_player and model:
		var sprite := model.find_child("Sprite", false)
		if sprite and sprite.has_method("play_anim"):
			_sprite_player = sprite

func _play_anim(anim_3d: String, anim_sprite: String) -> void:
	if _anim_player:
		if _current_anim == anim_3d:
			return
		if _anim_player.has_animation(anim_3d):
			_anim_player.play(anim_3d, 0.2)
			_current_anim = anim_3d
	elif _sprite_player:
		if _current_anim == anim_sprite:
			return
		_sprite_player.play_anim(anim_sprite)
		_current_anim = anim_sprite
