extends Node3D

const G := "res://assets/models/Medieval Village MegaKit[Standard]/glTF/"
const W := 2.0 # wall width
const H := 3.0 # wall height

func _ready() -> void:
	_build_road()
	_build_left_building()
	_build_right_building()
	_build_small_house()
	_build_tower()
	_build_fences()
	_build_decorations()

func _p(model: String, pos: Vector3, rot_y: float = 0.0, parent: Node3D = null) -> Node3D:
	var scene: PackedScene = load(G + model + ".gltf")
	if not scene:
		push_warning("[Village] Missing: %s" % model)
		return null
	var inst := scene.instantiate()
	var target := parent if parent else self
	target.add_child(inst)
	inst.position = pos
	inst.rotation.y = deg_to_rad(rot_y)
	_add_collision(inst)
	return inst

func _add_collision(node: Node3D) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			child.create_trimesh_collision()
		if child.get_child_count() > 0:
			_add_collision(child)

# === ROAD (center cobblestone path) ===
func _build_road() -> void:
	for z in range(-6, 7):
		for x in range(-1, 2):
			_p("Floor_UnevenBrick", Vector3(x * W, 0.01, z * W))

# === LEFT BUILDING (large, 2-story, stone base + plaster upper) ===
func _build_left_building() -> void:
	var b := Node3D.new()
	b.name = "Building_Left"
	b.position = Vector3(-6, 0, 0)
	add_child(b)

	# Ground floor - stone walls (facing road = +X side)
	# Front wall (faces road, along Z)
	_p("Wall_UnevenBrick_Straight", Vector3(0, 0, 0), 0, b)
	_p("Wall_UnevenBrick_Door_Round", Vector3(0, 0, W), 0, b)
	_p("Wall_UnevenBrick_Straight", Vector3(0, 0, W * 2), 0, b)
	# Back wall
	_p("Wall_UnevenBrick_Window_Wide_Round", Vector3(-W * 3, 0, 0), 180, b)
	_p("Wall_UnevenBrick_Straight", Vector3(-W * 3, 0, W), 180, b)
	_p("Wall_UnevenBrick_Straight", Vector3(-W * 3, 0, W * 2), 180, b)
	# Left side (along X)
	_p("Wall_UnevenBrick_Straight", Vector3(0, 0, 0), 90, b)
	_p("Wall_UnevenBrick_Straight", Vector3(-W, 0, 0), 90, b)
	_p("Wall_UnevenBrick_Straight", Vector3(-W * 2, 0, 0), 90, b)
	# Right side
	_p("Wall_UnevenBrick_Window_Thin_Round", Vector3(0, 0, W * 3), -90, b)
	_p("Wall_UnevenBrick_Straight", Vector3(-W, 0, W * 3), -90, b)
	_p("Wall_UnevenBrick_Straight", Vector3(-W * 2, 0, W * 3), -90, b)

	# Second floor - plaster walls with overhang
	_p("Overhang_UnevenBrick_Long", Vector3(0, H, 0), 0, b)
	_p("Overhang_UnevenBrick_Long", Vector3(0, H, W * 2), 0, b)

	_p("Wall_Plaster_WoodGrid", Vector3(0, H, 0), 0, b)
	_p("Wall_Plaster_Window_Wide_Round", Vector3(0, H, W), 0, b)
	_p("Wall_Plaster_WoodGrid", Vector3(0, H, W * 2), 0, b)
	_p("Wall_Plaster_Straight", Vector3(-W * 3, H, 0), 180, b)
	_p("Wall_Plaster_Straight", Vector3(-W * 3, H, W), 180, b)
	_p("Wall_Plaster_Straight", Vector3(-W * 3, H, W * 2), 180, b)
	_p("Wall_Plaster_Straight", Vector3(0, H, 0), 90, b)
	_p("Wall_Plaster_Straight", Vector3(-W, H, 0), 90, b)
	_p("Wall_Plaster_Straight", Vector3(-W * 2, H, 0), 90, b)
	_p("Wall_Plaster_Window_Thin_Round", Vector3(0, H, W * 3), -90, b)
	_p("Wall_Plaster_Straight", Vector3(-W, H, W * 3), -90, b)
	_p("Wall_Plaster_Straight", Vector3(-W * 2, H, W * 3), -90, b)

	# Roof
	_p("Roof_RoundTiles_6x6", Vector3(-W * 3, H * 2, 0), 0, b)

	# Stairs at entrance
	_p("Stairs_Exterior_Straight", Vector3(0, 0, W), 0, b)

	# Floor second story
	for x in range(3):
		for z in range(3):
			_p("Floor_WoodDark", Vector3(-x * W, H, z * W), 0, b)

# === RIGHT BUILDING (half-timbered with balcony) ===
func _build_right_building() -> void:
	var b := Node3D.new()
	b.name = "Building_Right"
	b.position = Vector3(4, 0, -2)
	add_child(b)

	# Ground floor - stone
	_p("Wall_UnevenBrick_Straight", Vector3(0, 0, 0), 0, b)
	_p("Wall_UnevenBrick_Straight", Vector3(0, 0, W), 0, b)
	_p("Wall_UnevenBrick_Door_Round", Vector3(0, 0, W * 2), 0, b)
	_p("Wall_UnevenBrick_Straight", Vector3(0, 0, W * 3), 0, b)
	_p("Wall_UnevenBrick_Straight", Vector3(W * 3, 0, 0), 180, b)
	_p("Wall_UnevenBrick_Window_Wide_Round", Vector3(W * 3, 0, W), 180, b)
	_p("Wall_UnevenBrick_Straight", Vector3(W * 3, 0, W * 2), 180, b)
	_p("Wall_UnevenBrick_Straight", Vector3(W * 3, 0, W * 3), 180, b)
	_p("Wall_UnevenBrick_Straight", Vector3(0, 0, 0), -90, b)
	_p("Wall_UnevenBrick_Straight", Vector3(W, 0, 0), -90, b)
	_p("Wall_UnevenBrick_Straight", Vector3(W * 2, 0, 0), -90, b)
	_p("Wall_UnevenBrick_Window_Thin_Round", Vector3(0, 0, W * 4), 90, b)
	_p("Wall_UnevenBrick_Straight", Vector3(W, 0, W * 4), 90, b)
	_p("Wall_UnevenBrick_Straight", Vector3(W * 2, 0, W * 4), 90, b)

	# Second floor - plaster
	_p("Wall_Plaster_WoodGrid", Vector3(0, H, 0), 0, b)
	_p("Wall_Plaster_Window_Wide_Round", Vector3(0, H, W), 0, b)
	_p("Wall_Plaster_WoodGrid", Vector3(0, H, W * 2), 0, b)
	_p("Wall_Plaster_Window_Wide_Round", Vector3(0, H, W * 3), 0, b)
	_p("Wall_Plaster_Straight", Vector3(W * 3, H, 0), 180, b)
	_p("Wall_Plaster_Straight", Vector3(W * 3, H, W), 180, b)
	_p("Wall_Plaster_Straight", Vector3(W * 3, H, W * 2), 180, b)
	_p("Wall_Plaster_Straight", Vector3(W * 3, H, W * 3), 180, b)
	_p("Wall_Plaster_Straight", Vector3(0, H, 0), -90, b)
	_p("Wall_Plaster_Straight", Vector3(W, H, 0), -90, b)
	_p("Wall_Plaster_Straight", Vector3(W * 2, H, 0), -90, b)
	_p("Wall_Plaster_Straight", Vector3(0, H, W * 4), 90, b)
	_p("Wall_Plaster_Straight", Vector3(W, H, W * 4), 90, b)
	_p("Wall_Plaster_Straight", Vector3(W * 2, H, W * 4), 90, b)

	# Balcony on road side
	_p("Balcony_Cross_Straight", Vector3(0, H, W), 0, b)
	_p("Balcony_Cross_Straight", Vector3(0, H, W * 2), 0, b)

	# Roof
	_p("Roof_RoundTiles_6x8", Vector3(0, H * 2, 0), -90, b)

	# Stairs at entrance
	_p("Stairs_Exterior_Straight", Vector3(0, 0, W * 2), 0, b)

# === SMALL HOUSE (background center) ===
func _build_small_house() -> void:
	var b := Node3D.new()
	b.name = "Small_House"
	b.position = Vector3(-2, 0, -8)
	add_child(b)

	# Walls
	_p("Wall_Plaster_Door_Round", Vector3(0, 0, 0), 0, b)
	_p("Wall_Plaster_Straight", Vector3(0, 0, W), 0, b)
	_p("Wall_Plaster_Straight", Vector3(-W * 2, 0, 0), 180, b)
	_p("Wall_Plaster_Window_Wide_Round", Vector3(-W * 2, 0, W), 180, b)
	_p("Wall_Plaster_Straight", Vector3(0, 0, 0), 90, b)
	_p("Wall_Plaster_Straight", Vector3(-W, 0, 0), 90, b)
	_p("Wall_Plaster_Straight", Vector3(0, 0, W * 2), -90, b)
	_p("Wall_Plaster_Straight", Vector3(-W, 0, W * 2), -90, b)

	# Roof
	_p("Roof_RoundTiles_4x4", Vector3(-W * 2, H, 0), 0, b)

	# Door
	_p("Door_1_Round", Vector3(0, 0, 0), 0, b)

# === TOWER (background right) ===
func _build_tower() -> void:
	var b := Node3D.new()
	b.name = "Tower"
	b.position = Vector3(8, 0, -8)
	add_child(b)

	for floor_i in range(3):
		var y := float(floor_i) * H
		_p("Wall_UnevenBrick_Straight", Vector3(0, y, 0), 0, b)
		_p("Wall_UnevenBrick_Straight", Vector3(W * 2, y, 0), 180, b)
		_p("Wall_UnevenBrick_Straight", Vector3(0, y, 0), -90, b)
		_p("Wall_UnevenBrick_Straight", Vector3(0, y, W), 90, b)
		if floor_i == 0:
			_p("Wall_UnevenBrick_Door_Flat", Vector3(0, y, 0), 0, b)
		elif floor_i > 0:
			_p("Wall_UnevenBrick_Window_Thin_Round", Vector3(0, y, 0), 0, b)

	# Tower roof
	_p("Roof_Tower_RoundTiles", Vector3(0, H * 3, 0), 0, b)

# === FENCES along the road ===
func _build_fences() -> void:
	# Right side of road
	for i in range(4):
		_p("Prop_WoodenFence_Single", Vector3(3, 0, -4 + i * W))
	# Some stone border pieces
	for i in range(3):
		_p("Prop_ExteriorBorder_Straight1", Vector3(3.5, 0, 6 + i * W))

# === DECORATIONS ===
func _build_decorations() -> void:
	# Crates near left building
	_p("Prop_Crate", Vector3(-5, 0, -3))
	_p("Prop_Crate", Vector3(-5.4, 0, -3.3))
	_p("Prop_Crate", Vector3(-5.2, 0.6, -3.1))
	# Wagon on the road side
	_p("Prop_Wagon", Vector3(-4, 0, 7), 15)
	# Scattered bricks
	_p("Prop_Brick1", Vector3(2.5, 0, 5))
	_p("Prop_Brick2", Vector3(3, 0, 6))
	_p("Prop_Brick3", Vector3(2.8, 0, 5.5))
	_p("Prop_Brick4", Vector3(3.2, 0, 4.5))
	# Vines on buildings
	_p("Prop_Vine1", Vector3(-6, 1, 0))
	_p("Prop_Vine2", Vector3(4, 1, -2))
	_p("Prop_Vine4", Vector3(4, 4, 2))
	# Chimney
	_p("Prop_Chimney", Vector3(-8, H * 2, 2))
	_p("Prop_Chimney2", Vector3(6, H * 2, 0))
	# Supports
	_p("Prop_Support", Vector3(-6, 0, -1))
	_p("Prop_Support", Vector3(-6, 0, 7))
