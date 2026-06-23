extends Node3D

const GLTF_PATH := "res://assets/models/Medieval Village MegaKit[Standard]/glTF/"

func _ready() -> void:
	_build_ground()
	_build_house_1(Vector3(8, 0, 8))
	_build_house_2(Vector3(-8, 0, 8))
	_build_house_3(Vector3(-8, 0, -8))
	_build_tower(Vector3(12, 0, -6))
	_build_props()
	_build_fences()
	_build_path()

func _place(model_name: String, pos: Vector3, rot_y: float = 0.0, parent: Node3D = null) -> Node3D:
	var path := GLTF_PATH + model_name + ".gltf"
	var scene: PackedScene = load(path)
	if not scene:
		push_warning("[Village] Could not load: %s" % path)
		return null

	var instance := scene.instantiate()
	var target := parent if parent else self
	target.add_child(instance)
	instance.position = pos
	instance.rotation.y = deg_to_rad(rot_y)

	_add_collision(instance)
	return instance

func _add_collision(node: Node3D) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			child.create_trimesh_collision()
		if child.get_child_count() > 0:
			_add_collision(child)

func _build_ground() -> void:
	for x in range(-3, 4):
		for z in range(-3, 4):
			var pos := Vector3(x * 4.0, 0, z * 4.0)
			_place("Floor_Brick", pos)

func _build_house_1(origin: Vector3) -> void:
	var house := Node3D.new()
	house.name = "House1"
	house.position = origin
	add_child(house)

	_place("Wall_Plaster_Straight", Vector3(0, 0, 0), 0, house)
	_place("Wall_Plaster_Straight", Vector3(2, 0, 0), 0, house)
	_place("Wall_Plaster_Door_Round", Vector3(4, 0, 0), 0, house)
	_place("Wall_Plaster_Straight", Vector3(0, 0, -4), 180, house)
	_place("Wall_Plaster_Straight", Vector3(2, 0, -4), 180, house)
	_place("Wall_Plaster_Window_Wide_Round", Vector3(4, 0, -4), 180, house)
	_place("Wall_Plaster_Straight", Vector3(0, 0, 0), 90, house)
	_place("Wall_Plaster_Window_Thin_Round", Vector3(6, 0, 0), -90, house)
	_place("Corner_Exterior_Wood", Vector3(0, 0, 0), 0, house)
	_place("Corner_Exterior_Wood", Vector3(6, 0, 0), -90, house)
	_place("Corner_Exterior_Wood", Vector3(0, 0, -4), 90, house)
	_place("Corner_Exterior_Wood", Vector3(6, 0, -4), 180, house)
	_place("Roof_RoundTiles_6x4", Vector3(0, 3, 0), 0, house)
	_place("Door_2_Round", Vector3(4, 0, 0), 0, house)

func _build_house_2(origin: Vector3) -> void:
	var house := Node3D.new()
	house.name = "House2"
	house.position = origin
	add_child(house)

	_place("Wall_UnevenBrick_Straight", Vector3(0, 0, 0), 0, house)
	_place("Wall_UnevenBrick_Door_Round", Vector3(2, 0, 0), 0, house)
	_place("Wall_UnevenBrick_Straight", Vector3(4, 0, 0), 0, house)
	_place("Wall_UnevenBrick_Straight", Vector3(0, 0, -4), 180, house)
	_place("Wall_UnevenBrick_Window_Wide_Round", Vector3(2, 0, -4), 180, house)
	_place("Wall_UnevenBrick_Straight", Vector3(4, 0, -4), 180, house)
	_place("Wall_UnevenBrick_Straight", Vector3(0, 0, 0), 90, house)
	_place("Wall_UnevenBrick_Straight", Vector3(6, 0, 0), -90, house)
	_place("Corner_Exterior_Brick", Vector3(0, 0, 0), 0, house)
	_place("Corner_Exterior_Brick", Vector3(6, 0, 0), -90, house)
	_place("Corner_Exterior_Brick", Vector3(0, 0, -4), 90, house)
	_place("Corner_Exterior_Brick", Vector3(6, 0, -4), 180, house)
	_place("Roof_RoundTiles_6x4", Vector3(0, 3, 0), 0, house)
	_place("Door_1_Round", Vector3(2, 0, 0), 0, house)

func _build_house_3(origin: Vector3) -> void:
	var house := Node3D.new()
	house.name = "House3"
	house.position = origin
	add_child(house)

	_place("Wall_Plaster_Straight", Vector3(0, 0, 0), 0, house)
	_place("Wall_Plaster_Door_Flat", Vector3(2, 0, 0), 0, house)
	_place("Wall_Plaster_Straight", Vector3(0, 0, -2), 180, house)
	_place("Wall_Plaster_Window_Wide_Flat", Vector3(2, 0, -2), 180, house)
	_place("Wall_Plaster_Straight", Vector3(0, 0, 0), 90, house)
	_place("Wall_Plaster_Straight", Vector3(4, 0, 0), -90, house)
	_place("Corner_Exterior_Wood", Vector3(0, 0, 0), 0, house)
	_place("Corner_Exterior_Wood", Vector3(4, 0, 0), -90, house)
	_place("Corner_Exterior_Wood", Vector3(0, 0, -2), 90, house)
	_place("Corner_Exterior_Wood", Vector3(4, 0, -2), 180, house)
	_place("Roof_RoundTiles_4x4", Vector3(0, 3, 1), 0, house)
	_place("Door_1_Flat", Vector3(2, 0, 0), 0, house)

func _build_tower(origin: Vector3) -> void:
	var tower := Node3D.new()
	tower.name = "Tower"
	tower.position = origin
	add_child(tower)

	for floor_y in range(0, 3):
		var y := float(floor_y) * 3.0
		_place("Wall_UnevenBrick_Straight", Vector3(0, y, 0), 0, tower)
		_place("Wall_UnevenBrick_Straight", Vector3(0, y, -2), 180, tower)
		_place("Wall_UnevenBrick_Straight", Vector3(0, y, 0), 90, tower)
		_place("Wall_UnevenBrick_Straight", Vector3(2, y, 0), -90, tower)
		if floor_y > 0:
			_place("Wall_UnevenBrick_Window_Thin_Round", Vector3(2, y, 0), -90, tower)

	_place("Roof_Tower_RoundTiles", Vector3(0, 9, 0), 0, tower)

func _build_props() -> void:
	_place("Prop_Crate", Vector3(5, 0, 4))
	_place("Prop_Crate", Vector3(5.5, 0, 3.5))
	_place("Prop_Crate", Vector3(5.2, 0.5, 3.8))
	_place("Prop_Wagon", Vector3(-3, 0, 3), -30)
	_place("Prop_Chimney", Vector3(10, 3, 6))
	_place("Prop_Chimney2", Vector3(-6, 3, 6))
	_place("Prop_Support", Vector3(6, 0, 7))
	_place("Prop_Support", Vector3(14, 0, 7))

func _build_fences() -> void:
	for i in range(5):
		_place("Prop_WoodenFence_Single", Vector3(-12 + i * 2.0, 0, 14))
	for i in range(5):
		_place("Prop_WoodenFence_Single", Vector3(-12 + i * 2.0, 0, -14), 180)
	for i in range(5):
		_place("Prop_WoodenFence_Single", Vector3(-14, 0, -10 + i * 2.0), 90)

func _build_path() -> void:
	_place("Stairs_Exterior_Straight", Vector3(0, 0, 12))
	_place("Floor_UnevenBrick", Vector3(0, 0, 0))
	_place("Floor_UnevenBrick", Vector3(0, 0, 4))
