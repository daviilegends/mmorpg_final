extends CanvasLayer

const SLOT_SIZE := 48
const SLOT_MARGIN := 3
const COLS := 4
const BAG_PADDING := 8
const BAG_BTN_SIZE := 54
const BAG_BTN_MARGIN := 5
const TOTAL_BAG_SLOTS := 4
const BG_COLOR := Color(0.12, 0.1, 0.15, 0.92)
const SLOT_COLOR := Color(0.22, 0.2, 0.28, 0.9)
const SLOT_HOVER := Color(0.4, 0.35, 0.5, 0.9)
const SLOT_EMPTY := Color(0.15, 0.13, 0.18, 0.7)
const LOCKED_COLOR := Color(0.08, 0.07, 0.1, 0.8)
const DROP_TARGET := Color(0.5, 0.45, 0.2, 0.9)
const TEXT_COLOR := Color(0.9, 0.88, 0.8)
const ACCENT := Color(0.7, 0.6, 0.4)
const LOCKED_ACCENT := Color(0.35, 0.3, 0.25)
const FONT_PATH := "res://assets/fonts/MedievalSharp-Regular.ttf"
const MARGIN_RIGHT := 10
const MARGIN_BOTTOM := 10

var _open_bags: Array[bool] = [false, false, false, false]
var _bag_panels: Array[Control] = [null, null, null, null]
var _bag_buttons: Array[Button] = []
var _bag_icons: Array[TextureRect] = []
var _tooltip: Label
var _inventory: InventoryManager
var _font: Font

# Drag state for bag reordering
var _dragging_bag: int = -1
var _drag_icon: TextureRect = null
var _drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	layer = 9
	_font = load(FONT_PATH)
	_build_bag_bar()
	_build_tooltip()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		_toggle_bag(0)

func _input(event: InputEvent) -> void:
	if _dragging_bag < 0:
		return
	if event is InputEventMouseMotion and _drag_icon:
		_drag_icon.global_position = event.position - _drag_offset
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
			_finish_drag(mb.position)

func _find_inventory() -> void:
	if _inventory:
		return
	var nodes := get_tree().get_nodes_in_group("inventory")
	if nodes.size() > 0:
		_inventory = nodes[0] as InventoryManager
		_inventory.inventory_changed.connect(_refresh_all)
		_inventory.bag_equipped.connect(_on_bag_equipped)
		_update_bag_bar()

# === BAG BAR ===
func _build_bag_bar() -> void:
	for i in range(TOTAL_BAG_SLOTS):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(BAG_BTN_SIZE, BAG_BTN_SIZE)
		btn.anchor_left = 1.0
		btn.anchor_top = 1.0
		btn.anchor_right = 1.0
		btn.anchor_bottom = 1.0

		var bar_w: float = TOTAL_BAG_SLOTS * (BAG_BTN_SIZE + BAG_BTN_MARGIN) + BAG_BTN_MARGIN
		var btn_x: float = -MARGIN_RIGHT - bar_w + i * (BAG_BTN_SIZE + BAG_BTN_MARGIN) + BAG_BTN_MARGIN
		btn.offset_left = btn_x
		btn.offset_right = btn_x + BAG_BTN_SIZE
		btn.offset_top = -MARGIN_BOTTOM - BAG_BTN_SIZE
		btn.offset_bottom = -MARGIN_BOTTOM

		_apply_bag_btn_style(btn, i == 0)

		var idx := i
		btn.pressed.connect(func() -> void: _toggle_bag(idx))
		btn.gui_input.connect(func(ev: InputEvent) -> void: _on_bag_btn_input(ev, idx))
		add_child(btn)
		_bag_buttons.append(btn)

		var icon_rect := TextureRect.new()
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon_rect.offset_left = 3
		icon_rect.offset_top = 3
		icon_rect.offset_right = -3
		icon_rect.offset_bottom = -3
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(icon_rect)
		_bag_icons.append(icon_rect)

	await get_tree().process_frame
	_find_inventory()

func _on_bag_btn_input(event: InputEvent, bag_idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			if not _inventory:
				return
			var bag := _inventory.get_bag(bag_idx)
			if not bag or bag.id == "":
				return
			_start_drag(bag_idx, mb.global_position)

func _start_drag(bag_idx: int, mouse_pos: Vector2) -> void:
	_dragging_bag = bag_idx
	var bag := _inventory.get_bag(bag_idx)

	_drag_icon = TextureRect.new()
	_drag_icon.texture = bag.icon
	_drag_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_drag_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_drag_icon.size = Vector2(BAG_BTN_SIZE, BAG_BTN_SIZE)
	_drag_icon.modulate = Color(1, 1, 1, 0.8)
	_drag_icon.z_index = 100
	_drag_offset = Vector2(BAG_BTN_SIZE / 2, BAG_BTN_SIZE / 2)
	_drag_icon.global_position = mouse_pos - _drag_offset
	add_child(_drag_icon)

	_bag_icons[bag_idx].modulate = Color(1, 1, 1, 0.3)

	for i in range(TOTAL_BAG_SLOTS):
		if i != bag_idx:
			_highlight_drop_target(i, true)

func _finish_drag(mouse_pos: Vector2) -> void:
	if _dragging_bag < 0:
		return

	var target_idx := _get_bag_slot_at(mouse_pos)

	if target_idx >= 0 and target_idx != _dragging_bag:
		_inventory.swap_bags(_dragging_bag, target_idx)
		_close_all_bag_panels()
		_update_bag_bar()

	_bag_icons[_dragging_bag].modulate = Color(1, 1, 1, 1)
	for i in range(TOTAL_BAG_SLOTS):
		_highlight_drop_target(i, false)

	if _drag_icon:
		_drag_icon.queue_free()
		_drag_icon = null
	_dragging_bag = -1

func _get_bag_slot_at(pos: Vector2) -> int:
	for i in range(TOTAL_BAG_SLOTS):
		var btn := _bag_buttons[i]
		var rect := Rect2(btn.global_position, btn.size)
		if rect.has_point(pos):
			return i
	return -1

func _highlight_drop_target(idx: int, highlight: bool) -> void:
	var btn := _bag_buttons[idx]
	if highlight:
		var style := StyleBoxFlat.new()
		style.bg_color = DROP_TARGET
		style.set_corner_radius_all(5)
		style.border_color = Color(1, 0.9, 0.4)
		style.set_border_width_all(2)
		btn.add_theme_stylebox_override("normal", style)
	else:
		var bag := _inventory.get_bag(idx) if _inventory else null
		var active := bag != null and bag.id != ""
		_apply_bag_btn_style(btn, active)

func _close_all_bag_panels() -> void:
	for i in range(TOTAL_BAG_SLOTS):
		_open_bags[i] = false
		if _bag_panels[i]:
			_bag_panels[i].queue_free()
			_bag_panels[i] = null

func _apply_bag_btn_style(btn: Button, active: bool) -> void:
	var border_color: Color = ACCENT if active else LOCKED_ACCENT
	var bg: Color = BG_COLOR if active else LOCKED_COLOR

	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.set_corner_radius_all(5)
	style.border_color = border_color
	style.set_border_width_all(2)
	btn.add_theme_stylebox_override("normal", style)

	var style_hover := style.duplicate()
	style_hover.bg_color = Color(bg.r + 0.08, bg.g + 0.08, bg.b + 0.1, bg.a)
	btn.add_theme_stylebox_override("hover", style_hover)

	var style_pressed := style.duplicate()
	style_pressed.bg_color = Color(bg.r + 0.12, bg.g + 0.1, bg.b + 0.15, bg.a)
	btn.add_theme_stylebox_override("pressed", style_pressed)

	btn.tooltip_text = "Empty bag slot" if not active else "Backpack (B)"
	btn.disabled = not active
	btn.text = ""

func _update_bag_bar() -> void:
	if not _inventory:
		return
	for i in range(TOTAL_BAG_SLOTS):
		var bag := _inventory.get_bag(i)
		if bag and bag.id != "":
			_apply_bag_btn_style(_bag_buttons[i], true)
			_bag_icons[i].texture = bag.icon
			_bag_icons[i].modulate = Color(1, 1, 1, 1)
			_bag_buttons[i].tooltip_text = bag.display_name
		else:
			_apply_bag_btn_style(_bag_buttons[i], false)
			_bag_icons[i].texture = null

func _on_bag_equipped(bag_idx: int, _bag: BagResource) -> void:
	_update_bag_bar()

func _toggle_bag(bag_idx: int) -> void:
	if _dragging_bag >= 0:
		return
	_find_inventory()
	if not _inventory:
		return
	if bag_idx >= _inventory.get_bag_count():
		return
	var bag := _inventory.get_bag(bag_idx)
	if not bag or bag.id == "":
		return

	_open_bags[bag_idx] = not _open_bags[bag_idx]

	if _open_bags[bag_idx]:
		if _bag_panels[bag_idx]:
			_bag_panels[bag_idx].queue_free()
		_bag_panels[bag_idx] = _create_bag_panel(bag_idx)
		add_child(_bag_panels[bag_idx])
		_refresh_bag(bag_idx)
	else:
		if _bag_panels[bag_idx]:
			_bag_panels[bag_idx].visible = false

func _create_bag_panel(bag_idx: int) -> Control:
	var bag := _inventory.get_bag(bag_idx)
	var slot_count := bag.slot_count
	var rows: int = ceili(float(slot_count) / COLS)
	var grid_w: float = COLS * (SLOT_SIZE + SLOT_MARGIN) + SLOT_MARGIN
	var grid_h: float = rows * (SLOT_SIZE + SLOT_MARGIN) + SLOT_MARGIN
	var panel_w: float = grid_w + BAG_PADDING * 2
	var panel_h: float = grid_h + BAG_PADDING + 32

	var panel := ColorRect.new()
	panel.color = BG_COLOR

	var panel_right: float = -MARGIN_RIGHT - bag_idx * (panel_w + 6)
	var panel_bottom: float = -MARGIN_BOTTOM - BAG_BTN_SIZE - 6

	panel.anchor_left = 1.0
	panel.anchor_top = 1.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_right = panel_right
	panel.offset_left = panel_right - panel_w
	panel.offset_bottom = panel_bottom
	panel.offset_top = panel_bottom - panel_h

	var title_container := HBoxContainer.new()
	title_container.position = Vector2(BAG_PADDING, 5)
	title_container.size = Vector2(panel_w - BAG_PADDING * 2 - 24, 22)
	title_container.add_theme_constant_override("separation", 4)
	panel.add_child(title_container)

	if bag.icon:
		var title_icon := TextureRect.new()
		title_icon.texture = bag.icon
		title_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		title_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		title_icon.custom_minimum_size = Vector2(18, 18)
		title_container.add_child(title_icon)

	var title := Label.new()
	title.text = bag.display_name
	if _font:
		title.add_theme_font_override("font", _font)
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", ACCENT)
	title_container.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.flat = true
	close_btn.add_theme_font_size_override("font_size", 12)
	close_btn.add_theme_color_override("font_color", TEXT_COLOR)
	close_btn.position = Vector2(panel_w - 22, 4)
	close_btn.size = Vector2(18, 18)
	var idx := bag_idx
	close_btn.pressed.connect(func() -> void: _toggle_bag(idx))
	panel.add_child(close_btn)

	for i in range(slot_count):
		var col: int = i % COLS
		var row: int = i / COLS
		var x: float = BAG_PADDING + col * (SLOT_SIZE + SLOT_MARGIN)
		var y: float = 28 + row * (SLOT_SIZE + SLOT_MARGIN)

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
		slot.set_meta("bag_idx", bag_idx)
		slot.set_meta("slot_idx", i)
		slot.mouse_entered.connect(_on_slot_hover.bind(slot, true))
		slot.mouse_exited.connect(_on_slot_hover.bind(slot, false))
		panel.add_child(slot)

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

	return panel

func unlock_bag_slot(bag_idx: int, bag: BagResource) -> void:
	if not _inventory:
		_find_inventory()
	if _inventory:
		_inventory.equip_bag(bag_idx, bag)

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
	_tooltip.offset_bottom = -MARGIN_BOTTOM - BAG_BTN_SIZE - 4
	_tooltip.offset_left = -400
	_tooltip.offset_top = -MARGIN_BOTTOM - BAG_BTN_SIZE - 20
	_tooltip.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_tooltip)

func _refresh_all() -> void:
	for i in range(TOTAL_BAG_SLOTS):
		if _open_bags[i] and _bag_panels[i]:
			_refresh_bag(i)

func _refresh_bag(bag_idx: int) -> void:
	if not _inventory or not _bag_panels[bag_idx]:
		return
	for child in _bag_panels[bag_idx].get_children():
		if not (child is Panel) or not child.has_meta("slot_idx"):
			continue
		var slot_idx: int = child.get_meta("slot_idx")
		var data := _inventory.get_slot(bag_idx, slot_idx)
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
		_find_inventory()
	if not _inventory:
		return
	var bag_idx: int = slot.get_meta("bag_idx")
	var slot_idx: int = slot.get_meta("slot_idx")
	var data := _inventory.get_slot(bag_idx, slot_idx)

	if hovering and not data.is_empty():
		_update_slot_style(slot, SLOT_HOVER)
		var item: ItemResource = data.item
		_tooltip.text = "%s — %s" % [item.display_name, item.description]
	else:
		_update_slot_style(slot, SLOT_EMPTY if data.is_empty() else SLOT_COLOR)
		_tooltip.text = ""
