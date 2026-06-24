extends CanvasLayer

const SLOT_SIZE := 56
const SLOT_MARGIN := 3
const COLS := 4
const BAG_PADDING := 12
const BG_COLOR := Color(0.12, 0.1, 0.15, 0.92)
const SLOT_COLOR := Color(0.22, 0.2, 0.28, 0.9)
const SLOT_HOVER := Color(0.4, 0.35, 0.5, 0.9)
const SLOT_EMPTY := Color(0.15, 0.13, 0.18, 0.7)
const TEXT_COLOR := Color(0.9, 0.88, 0.8)
const ACCENT := Color(0.7, 0.6, 0.4)
const FONT_PATH := "res://assets/fonts/MedievalSharp-Regular.ttf"
const MARGIN_RIGHT := 15
const MARGIN_BOTTOM := 15

var _is_open := false
var _root: Control
var _bag_container: VBoxContainer
var _bag_panels: Array[Control] = []
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
		_rebuild_bags()

func _find_inventory() -> void:
	if _inventory:
		return
	var nodes := get_tree().get_nodes_in_group("inventory")
	if nodes.size() > 0:
		_inventory = nodes[0] as InventoryManager
		_inventory.inventory_changed.connect(_refresh)
		_inventory.bag_added.connect(func(_idx: int) -> void: _rebuild_bags())

func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_bag_container = VBoxContainer.new()
	_bag_container.anchor_left = 1.0
	_bag_container.anchor_top = 1.0
	_bag_container.anchor_right = 1.0
	_bag_container.anchor_bottom = 1.0
	_bag_container.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_bag_container.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_bag_container.offset_right = -MARGIN_RIGHT
	_bag_container.offset_bottom = -MARGIN_BOTTOM
	_bag_container.offset_left = -400
	_bag_container.offset_top = -600
	_bag_container.add_theme_constant_override("separation", 8)
	_bag_container.alignment = BoxContainer.ALIGNMENT_END
	_root.add_child(_bag_container)

	_tooltip = Label.new()
	_tooltip.add_theme_font_size_override("font_size", 14)
	_tooltip.add_theme_color_override("font_color", TEXT_COLOR)
	_tooltip.anchor_left = 1.0
	_tooltip.anchor_top = 1.0
	_tooltip.anchor_right = 1.0
	_tooltip.anchor_bottom = 1.0
	_tooltip.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_tooltip.offset_right = -MARGIN_RIGHT
	_tooltip.offset_bottom = -2
	_tooltip.offset_left = -400
	_tooltip.offset_top = -MARGIN_BOTTOM
	_tooltip.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_root.add_child(_tooltip)

func _rebuild_bags() -> void:
	for child in _bag_container.get_children():
		child.queue_free()
	_bag_panels.clear()

	if not _inventory:
		return

	for bag_idx in range(_inventory.get_bag_count()):
		var bag_panel := _create_bag_panel(bag_idx)
		_bag_container.add_child(bag_panel)
		_bag_panels.append(bag_panel)

	_refresh()

func _create_bag_panel(bag_idx: int) -> Control:
	var rows: int = ceili(float(InventoryManager.SLOTS_PER_BAG) / COLS)
	var grid_w: float = COLS * (SLOT_SIZE + SLOT_MARGIN) + SLOT_MARGIN
	var grid_h: float = rows * (SLOT_SIZE + SLOT_MARGIN) + SLOT_MARGIN
	var panel_w: float = grid_w + BAG_PADDING * 2
	var panel_h: float = grid_h + BAG_PADDING + 32

	var panel := ColorRect.new()
	panel.color = BG_COLOR
	panel.custom_minimum_size = Vector2(panel_w, panel_h)

	var title := Label.new()
	title.text = "Bag %d" % (bag_idx + 1)
	if _font:
		title.add_theme_font_override("font", _font)
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", ACCENT)
	title.position = Vector2(BAG_PADDING, 6)
	title.size = Vector2(panel_w - BAG_PADDING * 2, 24)
	panel.add_child(title)

	for i in range(InventoryManager.SLOTS_PER_BAG):
		var col: int = i % COLS
		var row: int = i / COLS
		var x: float = BAG_PADDING + col * (SLOT_SIZE + SLOT_MARGIN)
		var y: float = 30 + row * (SLOT_SIZE + SLOT_MARGIN)

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
		icon.position = Vector2(4, 4)
		icon.size = Vector2(SLOT_SIZE - 8, SLOT_SIZE - 8)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.name = "Icon"
		slot.add_child(icon)

		var qty := Label.new()
		qty.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		qty.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		qty.position = Vector2(0, 0)
		qty.size = Vector2(SLOT_SIZE - 4, SLOT_SIZE - 2)
		qty.add_theme_font_size_override("font_size", 13)
		qty.add_theme_color_override("font_color", TEXT_COLOR)
		qty.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		qty.add_theme_constant_override("shadow_offset_x", 1)
		qty.add_theme_constant_override("shadow_offset_y", 1)
		qty.mouse_filter = Control.MOUSE_FILTER_IGNORE
		qty.name = "Qty"
		slot.add_child(qty)

	return panel

func _refresh() -> void:
	if not _inventory:
		return
	for bag_panel in _bag_panels:
		var bag_idx: int = -1
		for child in bag_panel.get_children():
			if child is Panel and child.has_meta("bag_idx"):
				bag_idx = child.get_meta("bag_idx")
				var slot_idx: int = child.get_meta("slot_idx")
				var slot := _inventory.get_slot(bag_idx, slot_idx)
				var icon_node: TextureRect = child.get_node("Icon")
				var qty_node: Label = child.get_node("Qty")
				if slot.is_empty():
					icon_node.texture = null
					qty_node.text = ""
					_update_slot_style(child, SLOT_EMPTY)
				else:
					icon_node.texture = slot.item.icon
					var qty: int = slot.quantity
					qty_node.text = str(qty) if qty > 1 else ""
					_update_slot_style(child, SLOT_COLOR)

func _update_slot_style(slot: Panel, color: Color) -> void:
	var style: StyleBoxFlat = slot.get_theme_stylebox("panel").duplicate()
	style.bg_color = color
	slot.add_theme_stylebox_override("panel", style)

func _on_slot_hover(slot: Panel, hovering: bool) -> void:
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
		var color := SLOT_EMPTY if data.is_empty() else SLOT_COLOR
		_update_slot_style(slot, color)
		_tooltip.text = ""
