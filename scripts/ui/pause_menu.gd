extends CanvasLayer

const PANEL_BORDER := "res://assets/models/Assets/kenney_fantasy-ui-borders/PNG/Default/Border/panel-border-015.png"
const TEXT_COLOR := Color(0.9, 0.88, 0.8)
const BG_COLOR := Color(0.12, 0.1, 0.15, 0.95)
const ACCENT_COLOR := Color(0.7, 0.6, 0.4)

var _is_open := false
var _root: Control
var _music_slider: HSlider
var _sensitivity_slider: HSlider
var _music_label: Label
var _sensitivity_label: Label

func _ready() -> void:
	layer = 10
	_build_ui()
	_root.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle()

func _toggle() -> void:
	_is_open = not _is_open
	_root.visible = _is_open
	get_tree().paused = _is_open
	if _is_open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	# Dark overlay
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(overlay)

	# Panel background
	var panel_bg := ColorRect.new()
	panel_bg.color = BG_COLOR
	panel_bg.set_anchors_preset(Control.PRESET_CENTER)
	panel_bg.offset_left = -230
	panel_bg.offset_right = 230
	panel_bg.offset_top = -210
	panel_bg.offset_bottom = 210
	_root.add_child(panel_bg)

	# Decorative border
	var border := NinePatchRect.new()
	border.texture = load(PANEL_BORDER)
	border.patch_margin_left = 16
	border.patch_margin_right = 16
	border.patch_margin_top = 16
	border.patch_margin_bottom = 16
	border.set_anchors_preset(Control.PRESET_FULL_RECT)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border.modulate = ACCENT_COLOR
	panel_bg.add_child(border)

	# Content
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 35
	vbox.offset_right = -35
	vbox.offset_top = 30
	vbox.offset_bottom = -30
	vbox.add_theme_constant_override("separation", 10)
	panel_bg.add_child(vbox)

	# Title
	var title := _make_label("Settings", 30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", ACCENT_COLOR)
	vbox.add_child(title)

	vbox.add_child(_make_separator())

	# Music Volume
	vbox.add_child(_make_label("Music Volume", 20))

	_music_slider = _make_slider(0, 100, 70)
	_music_slider.value_changed.connect(_on_music_changed)
	vbox.add_child(_music_slider)

	_music_label = _make_label("70%", 16)
	_music_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_music_label)

	vbox.add_child(_make_separator())

	# Mouse Sensitivity
	vbox.add_child(_make_label("Mouse Sensitivity", 20))

	_sensitivity_slider = _make_slider(1, 10, 3, 0.1)
	_sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	vbox.add_child(_sensitivity_slider)

	_sensitivity_label = _make_label("3.0", 16)
	_sensitivity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_sensitivity_label)

	vbox.add_child(_make_separator())

	# Resume button
	var resume_btn := Button.new()
	resume_btn.text = "Resume"
	resume_btn.custom_minimum_size = Vector2(0, 45)
	resume_btn.pressed.connect(_toggle)
	resume_btn.add_theme_font_size_override("font_size", 20)
	vbox.add_child(resume_btn)

	_load_initial_values()

func _make_label(text: String, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", TEXT_COLOR)
	return label

func _make_slider(min_val: float, max_val: float, default: float, step: float = 1.0) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = default
	slider.step = step
	slider.custom_minimum_size.y = 30
	return slider

func _make_separator() -> HSeparator:
	var sep := HSeparator.new()
	sep.add_theme_color_override("separator", Color(1, 1, 1, 0.15))
	return sep

func _load_initial_values() -> void:
	var music_players := get_tree().get_nodes_in_group("background_music")
	if music_players.size() > 0:
		var player: AudioStreamPlayer = music_players[0]
		var linear := db_to_linear(player.volume_db)
		_music_slider.value = linear * 100.0
		_music_label.text = "%d%%" % int(_music_slider.value)

	var cameras := get_tree().get_nodes_in_group("player_camera")
	if cameras.size() > 0:
		var cam: Camera3D = cameras[0]
		if cam.has_method("get_sensitivity_scale"):
			_sensitivity_slider.value = cam.get_sensitivity_scale()

func _on_music_changed(value: float) -> void:
	_music_label.text = "%d%%" % int(value)
	var vol_db := linear_to_db(value / 100.0) if value > 0 else -80.0
	for player in get_tree().get_nodes_in_group("background_music"):
		(player as AudioStreamPlayer).volume_db = vol_db

func _on_sensitivity_changed(value: float) -> void:
	_sensitivity_label.text = "%.1f" % value
	for cam in get_tree().get_nodes_in_group("player_camera"):
		if cam.has_method("set_sensitivity_scale"):
			cam.set_sensitivity_scale(value)
