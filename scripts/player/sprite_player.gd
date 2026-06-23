extends Sprite3D

const SHEET := "res://assets/textures/player_spritesheet.png"

# Frame regions in the sprite sheet (x, y, w, h) in pixels
# Row 1: idle1, idle2, run1, run2, run3, run4
# Row 2: jump1, jump2, attack_ready, attack_swing, attack_end
# Row 3: hurt, idle_standing, idle_sword
# Row 4: front, back, side
const FRAME_SIZE := 200
const FRAMES := {
	"idle_1": Rect2(20, 20, 180, 240),
	"idle_2": Rect2(230, 20, 180, 240),
	"run_1": Rect2(440, 20, 200, 240),
	"run_2": Rect2(640, 30, 200, 230),
	"run_3": Rect2(830, 20, 200, 240),
	"run_4": Rect2(1030, 20, 200, 240),
	"jump_1": Rect2(20, 290, 180, 240),
	"jump_2": Rect2(210, 290, 180, 240),
	"attack_1": Rect2(400, 280, 200, 250),
	"attack_2": Rect2(620, 280, 250, 250),
	"attack_3": Rect2(900, 280, 220, 250),
	"hurt": Rect2(20, 570, 230, 230),
	"stand_1": Rect2(310, 590, 180, 220),
	"stand_2": Rect2(570, 580, 200, 230),
	"front": Rect2(100, 850, 180, 250),
	"back": Rect2(430, 850, 180, 250),
	"side": Rect2(730, 850, 200, 250),
}

const ANIMS := {
	"idle": ["stand_1", "stand_2"],
	"walk": ["run_1", "run_2", "run_3", "run_4"],
	"run": ["run_1", "run_2", "run_3", "run_4"],
	"jump": ["jump_1", "jump_2"],
	"attack": ["attack_1", "attack_2", "attack_3"],
	"hurt": ["hurt"],
}

var _current_anim: String = "idle"
var _frame_index: int = 0
var _timer: float = 0.0
var _anim_speed: float = 0.15
var _texture_atlas: Texture2D

func _ready() -> void:
	_texture_atlas = load(SHEET)
	texture = _texture_atlas
	region_enabled = true
	pixel_size = 0.008
	billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	shaded = true
	transparent = true
	_set_frame("stand_1")

func _process(delta: float) -> void:
	_timer += delta
	var spd := _anim_speed
	if _current_anim == "run":
		spd = 0.1
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
	if _current_anim not in ANIMS:
		return
	var frames: Array = ANIMS[_current_anim]
	_frame_index = (_frame_index + 1) % frames.size()
	_set_frame(frames[_frame_index])

func _set_frame(frame_name: String) -> void:
	if frame_name in FRAMES:
		region_rect = FRAMES[frame_name]
