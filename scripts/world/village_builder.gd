extends Node3D

const G := "res://assets/models/Medieval Village MegaKit[Standard]/glTF/"
const W := 2.0
const H := 3.0

const SAVE_PATH := "res://scenes/world/village.tscn"

func _ready() -> void:
	if not ResourceLoader.exists(SAVE_PATH):
		_build()
		_save_scene()
		print("[Village] Scene saved to %s — restart and edit visually!" % SAVE_PATH)
	else:
		var scene: PackedScene = load(SAVE_PATH)
		var village := scene.instantiate()
		for child in village.get_children():
			village.remove_child(child)
			add_child(child)
		village.queue_free()
	_add_all_collisions(self)

func _save_scene() -> void:
	var packed := PackedScene.new()
	_set_owner_all(self, self)
	packed.pack(self)
	ResourceSaver.save(packed, SAVE_PATH)

func _set_owner_all(node: Node, root: Node) -> void:
	for child in node.get_children():
		child.owner = root
		_set_owner_all(child, root)

func _build() -> void:
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
	inst.name = model
	return inst

func _add_all_collisions(node: Node3D) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			child.create_trimesh_collision()
		if child is Node3D and child.get_child_count() > 0:
			_add_all_collisions(child)

func _walls(origin: Vector3, nx: int, nz: int, y: float,
		wall_front: String, wall_back: String, wall_left: String, wall_right: String,
		par: Node3D) -> void:
	var x0 := origin.x
	var z0 := origin.z
	var width := nx * W
	var depth := nz * W
	for i in range(nx):
		_p(wall_front, Vector3(x0 + 1 + i * W, y, z0), 180, par)
	for i in range(nx):
		_p(wall_back, Vector3(x0 + 1 + i * W, y, z0 + depth), 0, par)
	for i in range(nz):
		_p(wall_left, Vector3(x0, y, z0 + 1 + i * W), -90, par)
	for i in range(nz):
		_p(wall_right, Vector3(x0 + width, y, z0 + 1 + i * W), 90, par)

func _build_road() -> void:
	var road := Node3D.new()
	road.name = "Road"
	add_child(road)
	for z in range(-8, 9):
		for x in range(-1, 2):
			_p("Floor_UnevenBrick", Vector3(x * W, 0.01, z * W), 0, road)

func _build_left_building(origin: Vector3) -> void:
	var b := Node3D.new()
	b.name = "Building_Left"
	add_child(b)

	var nx := 3
	var nz := 3

	_walls(origin, nx, nz, 0,
		"Wall_UnevenBrick_Straight", "Wall_UnevenBrick_Straight",
		"Wall_UnevenBrick_Straight", "Wall_UnevenBrick_Straight", b)

	_p("Wall_UnevenBrick_Door_Round", Vector3(origin.x + 3, 0, origin.z + nz * W), 0, b)
	_p("Door_2_Round", Vector3(origin.x + 3, 0, origin.z + nz * W), 0, b)
	_p("Wall_UnevenBrick_Window_Wide_Round", Vector3(origin.x + 1, 0, origin.z + nz * W), 0, b)

	_walls(origin, nx, nz, H,
		"Wall_Plaster_Straight", "Wall_Plaster_WoodGrid",
		"Wall_Plaster_Straight", "Wall_Plaster_Straight", b)

	_p("Wall_Plaster_Window_Wide_Round", Vector3(origin.x + 3, H, origin.z + nz * W), 0, b)

	for x in range(nx):
		for z in range(nz):
			_p("Floor_WoodDark", Vector3(origin.x + 1 + x * W, H, origin.z + 1 + z * W), 0, b)

	_p("Roof_RoundTiles_6x6", Vector3(origin.x, H * 2, origin.z), 0, b)
	_p("Stairs_Exterior_Straight", Vector3(origin.x + 2, 0, origin.z + nz * W), 0, b)
	_p("Prop_Chimney", Vector3(origin.x + 2, H * 2, origin.z + 2), 0, b)

func _build_right_building(origin: Vector3) -> void:
	var b := Node3D.new()
	b.name = "Building_Right"
	add_child(b)

	var nx := 3
	var nz := 4

	_walls(origin, nx, nz, 0,
		"Wall_UnevenBrick_Straight", "Wall_UnevenBrick_Straight",
		"Wall_UnevenBrick_Straight", "Wall_UnevenBrick_Straight", b)

	_p("Wall_UnevenBrick_Door_Round", Vector3(origin.x, 0, origin.z + 3), -90, b)
	_p("Door_1_Round", Vector3(origin.x, 0, origin.z + 3), -90, b)
	_p("Wall_UnevenBrick_Window_Wide_Round", Vector3(origin.x, 0, origin.z + 5), -90, b)

	_walls(origin, nx, nz, H,
		"Wall_Plaster_Straight", "Wall_Plaster_Straight",
		"Wall_Plaster_WoodGrid", "Wall_Plaster_Straight", b)

	_p("Wall_Plaster_Window_Wide_Round", Vector3(origin.x, H, origin.z + 3), -90, b)
	_p("Wall_Plaster_Window_Wide_Round", Vector3(origin.x, H, origin.z + 5), -90, b)
	_p("Balcony_Cross_Straight", Vector3(origin.x, H, origin.z + 3), -90, b)
	_p("Balcony_Cross_Straight", Vector3(origin.x, H, origin.z + 5), -90, b)
	_p("Roof_RoundTiles_6x8", Vector3(origin.x, H * 2, origin.z), 0, b)
	_p("Stairs_Exterior_Straight", Vector3(origin.x - W, 0, origin.z + 2), -90, b)
	_p("Prop_Chimney2", Vector3(origin.x + 4, H * 2, origin.z + 4), 0, b)

func _build_small_house(origin: Vector3) -> void:
	var b := Node3D.new()
	b.name = "Small_House"
	add_child(b)

	_walls(origin, 2, 2, 0,
		"Wall_Plaster_Straight", "Wall_Plaster_Straight",
		"Wall_Plaster_Straight", "Wall_Plaster_Straight", b)

	_p("Wall_Plaster_Door_Round", Vector3(origin.x + 1, 0, origin.z + 4), 0, b)
	_p("Door_1_Round", Vector3(origin.x + 1, 0, origin.z + 4), 0, b)
	_p("Wall_Plaster_Window_Wide_Round", Vector3(origin.x + 1, 0, origin.z), 180, b)
	_p("Roof_RoundTiles_4x4", Vector3(origin.x, H, origin.z), 0, b)

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

	_p("Wall_UnevenBrick_Door_Flat", Vector3(origin.x + 1, 0, origin.z + W), 0, b)
	_p("Roof_Tower_RoundTiles", Vector3(origin.x, H * 3, origin.z), 0, b)

func _build_fences() -> void:
	var f := Node3D.new()
	f.name = "Fences"
	add_child(f)
	for i in range(6):
		_p("Prop_WoodenFence_Single", Vector3(3, 0, -6 + i * W), 90, f)
	for i in range(3):
		_p("Prop_ExteriorBorder_Straight1", Vector3(3.5, 0, 8 + i * W), 90, f)

func _build_decorations() -> void:
	var d := Node3D.new()
	d.name = "Decorations"
	add_child(d)
	_p("Prop_Crate", Vector3(-7, 0, -5), 0, d)
	_p("Prop_Crate", Vector3(-7.5, 0, -5.4), 0, d)
	_p("Prop_Crate", Vector3(-7.2, 0.6, -5.2), 0, d)
	_p("Prop_Wagon", Vector3(-5, 0, 8), 20, d)
	_p("Prop_Brick1", Vector3(2.5, 0, 7), 0, d)
	_p("Prop_Brick2", Vector3(3.2, 0, 8), 0, d)
	_p("Prop_Brick3", Vector3(2.8, 0, 7.5), 0, d)
	_p("Prop_Brick4", Vector3(3.5, 0, 6.5), 0, d)
	_p("Prop_Vine1", Vector3(-8, 2, -3), 0, d)
	_p("Prop_Vine2", Vector3(4, 2, -2), 0, d)
	_p("Prop_Vine4", Vector3(4, 5, 0), 0, d)
	_p("Prop_Support", Vector3(-8, 0, -4), 0, d)
	_p("Prop_Support", Vector3(-8, 0, 4), 0, d)
