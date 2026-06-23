extends AudioStreamPlayer3D

const FOOTSTEPS: Array[String] = [
	"res://assets/audio/sfx/footstep00.ogg",
	"res://assets/audio/sfx/footstep01.ogg",
	"res://assets/audio/sfx/footstep02.ogg",
	"res://assets/audio/sfx/footstep03.ogg",
	"res://assets/audio/sfx/footstep04.ogg",
	"res://assets/audio/sfx/footstep05.ogg",
	"res://assets/audio/sfx/footstep06.ogg",
	"res://assets/audio/sfx/footstep07.ogg",
	"res://assets/audio/sfx/footstep08.ogg",
	"res://assets/audio/sfx/footstep09.ogg",
]

var _streams: Array[AudioStream] = []
var _step_timer: float = 0.0
var _walk_interval: float = 0.45
var _run_interval: float = 0.28

func _ready() -> void:
	volume_db = -5.0
	max_distance = 20.0
	for path in FOOTSTEPS:
		var s: AudioStream = load(path)
		if s:
			_streams.append(s)

func _process(delta: float) -> void:
	var parent := get_parent() as CharacterBody3D
	if not parent:
		return

	var speed := Vector2(parent.velocity.x, parent.velocity.z).length()
	var on_floor := parent.is_on_floor()

	if speed < 0.5 or not on_floor:
		_step_timer = 0.0
		return

	var running := Input.is_key_pressed(KEY_SHIFT)
	var interval := _run_interval if running else _walk_interval

	_step_timer += delta
	if _step_timer >= interval:
		_step_timer -= interval
		_play_random_step()

func _play_random_step() -> void:
	if _streams.is_empty():
		return
	stream = _streams.pick_random()
	pitch_scale = randf_range(0.9, 1.1)
	play()
