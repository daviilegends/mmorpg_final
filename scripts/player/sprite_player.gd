extends Sprite3D

const SPRITE_DIR := "res://assets/textures/sprites/"

const ANIMS := {
	"idle": ["stand", "stand_sword"],
	"walk": ["run_1", "run_2", "run_3", "run_4"],
	"run": ["run_1", "run_2", "run_3", "run_4"],
	"jump": ["jump_1", "jump_2"],
	"attack": ["attack_ready", "attack_swing", "attack_end"],
	"hurt": ["hurt"],
}

const ANIM_SPEEDS := {
	"idle": 0.6,
	"walk": 0.15,
	"run": 0.1,
	"jump": 0.2,
	"attack": 0.12,
	"hurt": 0.3,
}

var _textures := {}
var _current_anim: String = "idle"
var _frame_index: int = 0
var _timer: float = 0.0

func _ready() -> void:
	for anim_name in ANIMS:
		for frame_name in ANIMS[anim_name]:
			if frame_name not in _textures:
				var path: String = SPRITE_DIR + frame_name + ".png"
				var tex: Texture2D = load(path)
				if tex:
					_textures[frame_name] = tex

	pixel_size = 0.007
	billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	shaded = false
	transparent = true
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	region_enabled = false
	_set_frame("stand")

func _process(delta: float) -> void:
	_timer += delta
	var spd: float = ANIM_SPEEDS.get(_current_anim, 0.15)
	if _timer >= spd:
		_timer -= spd
		_advance_frame()

func play_anim(anim_name: String) -> void:
	if anim_name == _current_anim:
		return
	if anim_name not in ANIMS:
		return
	_current_anim = anim_name
	_frame_index = 0
	_timer = 0.0
	_set_frame(ANIMS[_current_anim][0])

func _advance_frame() -> void:
	var frames: Array = ANIMS[_current_anim]
	_frame_index = (_frame_index + 1) % frames.size()
	_set_frame(frames[_frame_index])

func _set_frame(frame_name: String) -> void:
	if frame_name in _textures:
		texture = _textures[frame_name]
