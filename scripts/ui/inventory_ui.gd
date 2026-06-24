extends CanvasLayer

const SLOT_SIZE := 52
const SLOT_MARGIN := 3
const COLS := 4
const BAG_PADDING := 10
const BG_COLOR := Color(0.12, 0.1, 0.15, 0.92)
const SLOT_COLOR := Color(0.22, 0.2, 0.28, 0.9)
const SLOT_HOVER := Color(0.4, 0.35, 0.5, 0.9)
const SLOT_EMPTY := Color(0.15, 0.13, 0.18, 0.7)
const TEXT_COLOR := Color(0.9, 0.88, 0.8)
const ACCENT := Color(0.7, 0.6, 0.4)
const FONT_PATH := "res://assets/fonts/MedievalSharp-Regular.ttf"
const MARGIN_RIGHT := 10
const MARGIN_BOTTOM := 50

var _is_open := false
var _bag_panel: Control
var _bag_button: Button
var _tooltip: Label
var _inventory: InventoryManager
var _font: Font

func _ready() -> void:
	layer = 9
	_font = load(FONT_PATH)
	_build_bag_button()
	_build_bag_panel()
	_build_tooltip()
	_bag_panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		_toggle()

func _toggle() -> void:
	_is_open = not _is_open
	_bag_panel.visible = _is_open
	if _is_open:
		_find_inventory()
		_rebuild_slots()

func _find_inventory() -> void:
	if _inventory:
		return
	var nodes := get_tree().get_nodes_in_group("inventory")
	if nodes.size() > 0:
		_inventory = nodes[0] as InventoryManager
		_inventory.inventory_changed.connect(_refresh)

# === BAG BUTTON (bottom-right, always visible) ===
func _build_bag_button() -> void:
	_bag_button = Button.new()
	_bag_button.custom_minimum_size = Vector2(44, 44)
	_bag_button.anchor_left = 1.0
	_bag_button.anchor_top = 1.0
	_bag_button.anchor_right = 1.0
	_bag_button.anchor_bottom = 1.0
	_bag_button.offset_left = -54
	_bag_button.offset_top = -54
	_bag_button.offset_right = -MARGIN_RIGHT
	_bag_button.offset_bottom = -MARGIN_RIGHT
	_bag_button.pressed.connect(_toggle)
	_bag_button.tooltip_text = "Backpack (B)"

	var style := StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.set_corner_radius_all(6)
	style.border_color = ACCENT
	style.set_border_width_all(2)
	_bag_button.add_theme_stylebox_override("normal", style)

	var style_hover := style.duplicate()
	style_hover.bg_color = Color(0.2, 0.18, 0.25, 0.95)
	_bag_button.add_theme_stylebox_override("hover", style_hover)

	var style_pressed := style.duplicate()
	style_pressed.bg_color = Color(0.25, 0.22, 0.3, 0.95)
	_bag_button.add_theme_stylebox_override("pressed", style_pressed)

	# Bag icon label (emoji-like)
	_bag_button.text = "B"
	if _font:
		_bag_button.add_theme_font_override("font", _font)
	_bag_button.add_theme_font_size_override("font_size", 22)
	_bag_button.add_theme_color_override("font_color", ACCENT)

	add_child(_bag_button)

# === BAG PANEL (above the button) ===
func _build_bag_panel() -> void:
	var rows: int = ceili(float(InventoryManager.SLOTS_PER_BAG) / COLS)
	var grid_w: float = COLS * (SLOT_SIZE + SLOT_MARGIN) + SLOT_MARGIN
	var grid_h: float = rows * (SLOT_SIZE + SLOT_MARGIN) + SLOT_MARGIN
	var panel_w: float = grid_w + BAG_PADDING * 2
	var panel_h: float = grid_h + BAG_PADDING + 34

	_bag_panel = ColorRect.new()
	(_bag_panel as ColorRect).color = BG_COLOR
	_bag_panel.anchor_left = 1.0
	_bag_panel.anchor_top = 1.0
	_bag_panel.anchor_right = 1.0
	_bag_panel.anchor_bottom = 1.0
	_bag_panel.offset_right = -MARGIN_RIGHT
	_bag_panel.offset_bottom = -60
	_bag_panel.offset_left = -MARGIN_RIGHT - panel_w
	_bag_panel.offset_top = -60 - panel_h
	add_child(_bag_panel)

	# Title
	var title := Label.new()
	title.text = "Backpack"
	if _font:
		title.add_theme_font_override("font", _font)
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", ACCENT)
	title.position = Vector2(BAG_PADDING, 6)
	title.size = Vector2(panel_w - BAG_PADDING * 2, 24)
	_bag_panel.add_child(title)

	# Close X
	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.flat = true
	close_btn.add_theme_font_size_override("font_size", 14)
	close_btn.add_theme_color_override("font_color", TEXT_COLOR)
	close_btn.position = Vector2(panel_w - 28, 4)
	close_btn.size = Vector2(24, 24)
	close_btn.pressed.connect(_toggle)
	_bag_panel.add_child(close_btn)

func _rebuild_slots() -> void:
	# Remove old slot nodes
	for child in _bag_panel.get_children():
		if child is Panel:
			child.queue_free()

	if not _inventory:
		return

	for i in range(InventoryManager.SLOTS_PER_BAG):
		var col: int = i % COLS
		var row: int = i / COLS
		var x: float = BAG_PADDING + col * (SLOT_SIZE + SLOT_MARGIN)
		var y: float = 32 + row * (SLOT_SIZE + SLOT_MARGIN)

		var slot := Panel.new()
		var style := StyleBoxFlat.new()
		style.bg_color = SLOT_EMPTY
		style.set_corner_radius_all(4)
		style.border_color = Color(1, 1, 1, 0.08)
		style.set_border_width_all(1)
		slot.add_theme_stylebox_override("panel", style)
		slot.position = Vector2(x, y)
		slot.size = Vector2(SLOT_SIZE, SLOT_SIZE)
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		slot.set_meta("slot_idx", i)
		slot.mouse_entered.connect(_on_slot_hover.bind(slot, true))
		slot.mouse_exited.connect(_on_slot_hover.bind(slot, false))
		_bag_panel.add_child(slot)

		var icon := TextureRect.new()
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.position = Vector2(3, 3)
		icon.size = Vector2(SLOT_SIZE - 6, SLOT_SIZE - 6)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.name = "Icon"
		slot.add_child(icon)

		var qty := Label.new()
		qty.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		qty.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		qty.position = Vector2(0, 0)
		qty.size = Vector2(SLOT_SIZE - 3, SLOT_SIZE - 2)
		qty.add_theme_font_size_override("font_size", 12)
		qty.add_theme_color_override("font_color", TEXT_COLOR)
		qty.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		qty.add_theme_constant_override("shadow_offset_x", 1)
		qty.add_theme_constant_override("shadow_offset_y", 1)
		qty.mouse_filter = Control.MOUSE_FILTER_IGNORE
		qty.name = "Qty"
		slot.add_child(qty)

	await get_tree().process_frame
	_refresh()

func _build_tooltip() -> void:
	_tooltip = Label.new()
	_tooltip.add_theme_font_size_override("font_size", 13)
	_tooltip.add_theme_color_override("font_color", TEXT_COLOR)
	_tooltip.anchor_left = 1.0
	_tooltip.anchor_top = 1.0
	_tooltip.anchor_right = 1.0
	_tooltip.anchor_bottom = 1.0
	_tooltip.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_tooltip.offset_right = -MARGIN_RIGHT
	_tooltip.offset_bottom = -58
	_tooltip.offset_left = -350
	_tooltip.offset_top = -74
	_tooltip.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_tooltip)

func _refresh() -> void:
	if not _inventory:
		return
	for child in _bag_panel.get_children():
		if not (child is Panel) or not child.has_meta("slot_idx"):
			continue
		var slot_idx: int = child.get_meta("slot_idx")
		var data := _inventory.get_slot(0, slot_idx)
		var icon_node: TextureRect = child.get_node("Icon")
		var qty_node: Label = child.get_node("Qty")
		if data.is_empty():
			icon_node.texture = null
			qty_node.text = ""
			_update_slot_style(child, SLOT_EMPTY)
		else:
			icon_node.texture = data.item.icon
			var qty: int = data.quantity
			qty_node.text = str(qty) if qty > 1 else ""
			_update_slot_style(child, SLOT_COLOR)

func _update_slot_style(slot: Panel, color: Color) -> void:
	var style: StyleBoxFlat = slot.get_theme_stylebox("panel").duplicate()
	style.bg_color = color
	slot.add_theme_stylebox_override("panel", style)

func _on_slot_hover(slot: Panel, hovering: bool) -> void:
	if not _inventory:
		return
	var slot_idx: int = slot.get_meta("slot_idx")
	var data := _inventory.get_slot(0, slot_idx)

	if hovering and not data.is_empty():
		_update_slot_style(slot, SLOT_HOVER)
		var item: ItemResource = data.item
		_tooltip.text = "%s — %s" % [item.display_name, item.description]
	else:
		_update_slot_style(slot, SLOT_EMPTY if data.is_empty() else SLOT_COLOR)
		_tooltip.text = ""
