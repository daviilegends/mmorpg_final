extends Node3D

const G := "res://assets/models/Medieval Village MegaKit[Standard]/glTF/"
const W := 2.0
const H := 3.0

func _ready() -> void:
	_build_road()
	_build_left_building(Vector3(-8, 0, -3))
	_build_right_building(Vector3(4, 0, -4))
	_build_small_house(Vector3(-1, 0, -10))
	_build_tower(Vector3(10, 0, -10))
	_build_fences()
	_build_decorations()

func _p(model: String, pos: Vector3, rot_y: float = 0.0, par: Node3D = null) -> Node3D:
	var scene: PackedScene = load(G + model + ".gltf")
	if not scene:
		push_warning("[Village] Missing: %s" % model)
		return null
	var inst := scene.instantiate()
	(par if par else self).add_child(inst)
	inst.position = pos
	inst.rotation.y = deg_to_rad(rot_y)
	_add_col(inst)
	return inst

func _add_col(node: Node3D) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			child.create_trimesh_collision()
		if child.get_child_count() > 0:
			_add_col(child)

# Build walls around a rectangular room.
# origin = bottom-left corner (min X, min Z)
# nx = wall segments along X, nz = wall segments along Z
# rot=0 wall extends along X. rot=90 wall extends along Z.
func _walls(origin: Vector3, nx: int, nz: int, y: float,
		wall_front: String, wall_back: String, wall_left: String, wall_right: String,
		par: Node3D) -> void:
	var x0 := origin.x
	var z0 := origin.z
	var width := nx * W
	var depth := nz * W
	# Front (z=z0, faces -Z outward)
	for i in range(nx):
		_p(wall_front, Vector3(x0 + 1 + i * W, y, z0), 180, par)
	# Back (z=z0+depth, faces +Z outward)
	for i in range(nx):
		_p(wall_back, Vector3(x0 + 1 + i * W, y, z0 + depth), 0, par)
	# Left (x=x0, faces -X outward)
	for i in range(nz):
		_p(wall_left, Vector3(x0, y, z0 + 1 + i * W), -90, par)
	# Right (x=x0+width, faces +X outward)
	for i in range(nz):
		_p(wall_right, Vector3(x0 + width, y, z0 + 1 + i * W), 90, par)

# === ROAD ===
func _build_road() -> void:
	for z in range(-8, 9):
		for x in range(-1, 2):
			_p("Floor_UnevenBrick", Vector3(x * W, 0.01, z * W))

# === LEFT BUILDING: 2-story, 6m x 6m, stone base + plaster top ===
func _build_left_building(origin: Vector3) -> void:
	var b := Node3D.new()
	b.name = "Building_Left"
	add_child(b)

	var nx := 3
	var nz := 3

	# Ground floor - stone walls
	_walls(origin, nx, nz, 0,
		"Wall_UnevenBrick_Straight", "Wall_UnevenBrick_Straight",
		"Wall_UnevenBrick_Straight", "Wall_UnevenBrick_Straight", b)

	# Door on the front (road-facing = back side = +Z)
	_p("Wall_UnevenBrick_Door_Round", Vector3(origin.x + 3, 0, origin.z + nz * W), 0, b)
	_p("Door_2_Round", Vector3(origin.x + 3, 0, origin.z + nz * W), 0, b)

	# Windows
	_p("Wall_UnevenBrick_Window_Wide_Round", Vector3(origin.x + 1, 0, origin.z + nz * W), 0, b)

	# Second floor - plaster
	_walls(origin, nx, nz, H,
		"Wall_Plaster_Straight", "Wall_Plaster_WoodGrid",
		"Wall_Plaster_Straight", "Wall_Plaster_Straight", b)

	# Window on second floor road side
	_p("Wall_Plaster_Window_Wide_Round", Vector3(origin.x + 3, H, origin.z + nz * W), 0, b)

	# Wood floors second story
	for x in range(nx):
		for z in range(nz):
			_p("Floor_WoodDark", Vector3(origin.x + 1 + x * W, H, origin.z + 1 + z * W), 0, b)

	# Roof - 6x6 roof centered over 6x6 building
	_p("Roof_RoundTiles_6x6", Vector3(origin.x, H * 2, origin.z), 0, b)

	# Stairs at entrance
	_p("Stairs_Exterior_Straight", Vector3(origin.x + 2, 0, origin.z + nz * W), 0, b)

	# Chimney
	_p("Prop_Chimney", Vector3(origin.x + 2, H * 2, origin.z + 2))

# === RIGHT BUILDING: 2-story, 6m x 8m, stone + plaster with balcony ===
func _build_right_building(origin: Vector3) -> void:
	var b := Node3D.new()
	b.name = "Building_Right"
	add_child(b)

	var nx := 3
	var nz := 4

	# Ground floor - stone
	_walls(origin, nx, nz, 0,
		"Wall_UnevenBrick_Straight", "Wall_UnevenBrick_Straight",
		"Wall_UnevenBrick_Straight", "Wall_UnevenBrick_Straight", b)

	# Door on left side (road-facing = left = -X)
	_p("Wall_UnevenBrick_Door_Round", Vector3(origin.x, 0, origin.z + 3), -90, b)
	_p("Door_1_Round", Vector3(origin.x, 0, origin.z + 3), -90, b)

	# Window on left side
	_p("Wall_UnevenBrick_Window_Wide_Round", Vector3(origin.x, 0, origin.z + 5), -90, b)

	# Second floor - plaster with wood grid
	_walls(origin, nx, nz, H,
		"Wall_Plaster_Straight", "Wall_Plaster_Straight",
		"Wall_Plaster_WoodGrid", "Wall_Plaster_Straight", b)

	# Windows second floor road side
	_p("Wall_Plaster_Window_Wide_Round", Vector3(origin.x, H, origin.z + 3), -90, b)
	_p("Wall_Plaster_Window_Wide_Round", Vector3(origin.x, H, origin.z + 5), -90, b)

	# Balcony on road side
	_p("Balcony_Cross_Straight", Vector3(origin.x, H, origin.z + 3), -90, b)
	_p("Balcony_Cross_Straight", Vector3(origin.x, H, origin.z + 5), -90, b)

	# Roof
	_p("Roof_RoundTiles_6x8", Vector3(origin.x, H * 2, origin.z), 0, b)

	# Stairs
	_p("Stairs_Exterior_Straight", Vector3(origin.x - W, 0, origin.z + 2), -90, b)

	# Chimney
	_p("Prop_Chimney2", Vector3(origin.x + 4, H * 2, origin.z + 4))

# === SMALL HOUSE: 1-story, 4m x 4m ===
func _build_small_house(origin: Vector3) -> void:
	var b := Node3D.new()
	b.name = "Small_House"
	add_child(b)

	_walls(origin, 2, 2, 0,
		"Wall_Plaster_Straight", "Wall_Plaster_Straight",
		"Wall_Plaster_Straight", "Wall_Plaster_Straight", b)

	# Door facing road (+Z side)
	_p("Wall_Plaster_Door_Round", Vector3(origin.x + 1, 0, origin.z + 4), 0, b)
	_p("Door_1_Round", Vector3(origin.x + 1, 0, origin.z + 4), 0, b)

	# Window on back
	_p("Wall_Plaster_Window_Wide_Round", Vector3(origin.x + 1, 0, origin.z), 180, b)

	# Roof
	_p("Roof_RoundTiles_4x4", Vector3(origin.x, H, origin.z), 0, b)

# === TOWER: 3 floors, 2m x 2m ===
func _build_tower(origin: Vector3) -> void:
	var b := Node3D.new()
	b.name = "Tower"
	add_child(b)

	for fl in range(3):
		var y := fl * H
		var wall_type := "Wall_UnevenBrick_Straight"
		if fl > 0:
			wall_type = "Wall_UnevenBrick_Window_Thin_Round"
		_walls(origin, 1, 1, y, wall_type, wall_type, wall_type, wall_type, b)

	# Door ground floor
	_p("Wall_UnevenBrick_Door_Flat", Vector3(origin.x + 1, 0, origin.z + W), 0, b)

	# Tower roof
	_p("Roof_Tower_RoundTiles", Vector3(origin.x, H * 3, origin.z), 0, b)

# === FENCES ===
func _build_fences() -> void:
	for i in range(6):
		_p("Prop_WoodenFence_Single", Vector3(3, 0, -6 + i * W), 90)
	for i in range(3):
		_p("Prop_ExteriorBorder_Straight1", Vector3(3.5, 0, 8 + i * W), 90)

# === DECORATIONS ===
func _build_decorations() -> void:
	_p("Prop_Crate", Vector3(-7, 0, -5))
	_p("Prop_Crate", Vector3(-7.5, 0, -5.4))
	_p("Prop_Crate", Vector3(-7.2, 0.6, -5.2))
	_p("Prop_Wagon", Vector3(-5, 0, 8), 20)
	_p("Prop_Brick1", Vector3(2.5, 0, 7))
	_p("Prop_Brick2", Vector3(3.2, 0, 8))
	_p("Prop_Brick3", Vector3(2.8, 0, 7.5))
	_p("Prop_Brick4", Vector3(3.5, 0, 6.5))
	_p("Prop_Vine1", Vector3(-8, 2, -3))
	_p("Prop_Vine2", Vector3(4, 2, -2))
	_p("Prop_Vine4", Vector3(4, 5, 0))
	_p("Prop_Support", Vector3(-8, 0, -4))
	_p("Prop_Support", Vector3(-8, 0, 4))
