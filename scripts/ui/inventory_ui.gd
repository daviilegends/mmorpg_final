extends CanvasLayer

const SLOT_SIZE := 64
const SLOT_MARGIN := 4
const COLS := 5
const ROWS := 4
const BG_COLOR := Color(0.12, 0.1, 0.15, 0.92)
const SLOT_COLOR := Color(0.2, 0.18, 0.25, 0.9)
const SLOT_HOVER := Color(0.35, 0.3, 0.4, 0.9)
const SLOT_EMPTY := Color(0.15, 0.13, 0.18, 0.7)
const TEXT_COLOR := Color(0.9, 0.88, 0.8)
const ACCENT := Color(0.7, 0.6, 0.4)
const FONT_PATH := "res://assets/fonts/MedievalSharp-Regular.ttf"

var _is_open := false
var _root: Control
var _slot_panels: Array[Panel] = []
var _slot_icons: Array[TextureRect] = []
var _slot_labels: Array[Label] = []
var _tooltip: Label
var _inventory: InventoryManager
var _font: Font

func _ready() -> void:
	layer = 9
	_font = load(FONT_PATH)
	_build_ui()
	_root.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		_toggle()

func _toggle() -> void:
	_is_open = not _is_open
	_root.visible = _is_open
	if _is_open:
		_find_inventory()
		_refresh()

func _find_inventory() -> void:
	if _inventory:
		return
	var nodes := get_tree().get_nodes_in_group("inventory")
	if nodes.size() > 0:
		_inventory = nodes[0] as InventoryManager
		_inventory.inventory_changed.connect(_refresh)

func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.3)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(overlay)

	var grid_w: float = COLS * (SLOT_SIZE + SLOT_MARGIN) + SLOT_MARGIN
	var grid_h: float = ROWS * (SLOT_SIZE + SLOT_MARGIN) + SLOT_MARGIN
	var panel_w: float = grid_w + 40
	var panel_h: float = grid_h + 80

	var panel := ColorRect.new()
	panel.color = BG_COLOR
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -panel_w / 2
	panel.offset_right = panel_w / 2
	panel.offset_top = -panel_h / 2
	panel.offset_bottom = panel_h / 2
	_root.add_child(panel)

	# Title
	var title := Label.new()
	title.text = "Inventory"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font:
		title.add_theme_font_override("font", _font)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", ACCENT)
	title.position = Vector2(0, 10)
	title.size = Vector2(panel_w, 30)
	panel.add_child(title)

	# Grid container
	var grid_offset := Vector2(20, 50)
	for i in range(COLS * ROWS):
		var col: int = i % COLS
		var row: int = i / COLS
		var x: float = grid_offset.x + col * (SLOT_SIZE + SLOT_MARGIN)
		var y: float = grid_offset.y + row * (SLOT_SIZE + SLOT_MARGIN)

		var slot := Panel.new()
		var style := StyleBoxFlat.new()
		style.bg_color = SLOT_EMPTY
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		style.border_color = Color(1, 1, 1, 0.1)
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		slot.add_theme_stylebox_override("panel", style)
		slot.position = Vector2(x, y)
		slot.size = Vector2(SLOT_SIZE, SLOT_SIZE)
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		var idx := i
		slot.mouse_entered.connect(func() -> void: _on_slot_hover(idx, true))
		slot.mouse_exited.connect(func() -> void: _on_slot_hover(idx, false))
		panel.add_child(slot)
		_slot_panels.append(slot)

		var icon := TextureRect.new()
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.position = Vector2(4, 4)
		icon.size = Vector2(SLOT_SIZE - 8, SLOT_SIZE - 8)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(icon)
		_slot_icons.append(icon)

		var qty := Label.new()
		qty.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		qty.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		qty.position = Vector2(0, 0)
		qty.size = Vector2(SLOT_SIZE - 4, SLOT_SIZE - 2)
		qty.add_theme_font_size_override("font_size", 14)
		qty.add_theme_color_override("font_color", TEXT_COLOR)
		qty.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(qty)
		_slot_labels.append(qty)

	# Tooltip
	_tooltip = Label.new()
	_tooltip.add_theme_font_size_override("font_size", 16)
	_tooltip.add_theme_color_override("font_color", TEXT_COLOR)
	_tooltip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tooltip.position = Vector2(0, panel_h - 28)
	_tooltip.size = Vector2(panel_w, 25)
	_tooltip.text = ""
	panel.add_child(_tooltip)

func _refresh() -> void:
	if not _inventory:
		return
	for i in range(COLS * ROWS):
		var slot := _inventory.get_slot(i)
		if slot.is_empty():
			_slot_icons[i].texture = null
			_slot_labels[i].text = ""
		else:
			var item: ItemResource = slot.item
			_slot_icons[i].texture = item.icon
			var qty: int = slot.quantity
			_slot_labels[i].text = str(qty) if qty > 1 else ""

func _on_slot_hover(index: int, hovering: bool) -> void:
	var style: StyleBoxFlat = _slot_panels[index].get_theme_stylebox("panel").duplicate()
	if not _inventory:
		return
	var slot := _inventory.get_slot(index)
	if hovering and not slot.is_empty():
		style.bg_color = SLOT_HOVER
		var item: ItemResource = slot.item
		_tooltip.text = "%s — %s" % [item.display_name, item.description]
	else:
		style.bg_color = SLOT_EMPTY if slot.is_empty() else SLOT_COLOR
		_tooltip.text = ""
	_slot_panels[index].add_theme_stylebox_override("panel", style)
