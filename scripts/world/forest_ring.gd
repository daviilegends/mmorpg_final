extends Node3D

@export var inner_radius: float = 22.0
@export var outer_radius: float = 35.0
@export var tree_count: int = 200

var _trunk_mat: StandardMaterial3D
var _leaves_mats: Array[StandardMaterial3D] = []

func _ready() -> void:
	_create_materials()
	_generate_trees()

func _create_materials() -> void:
	_trunk_mat = StandardMaterial3D.new()
	_trunk_mat.albedo_color = Color(0.45, 0.3, 0.15)

	for color in [Color(0.18, 0.5, 0.18), Color(0.22, 0.55, 0.2), Color(0.15, 0.45, 0.22), Color(0.25, 0.6, 0.2)]:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		_leaves_mats.append(mat)

func _generate_trees() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345

	for i in range(tree_count):
		var angle := rng.randf() * TAU
		var dist := rng.randf_range(inner_radius, outer_radius)
		var x := cos(angle) * dist
		var z := sin(angle) * dist

		var tree := Node3D.new()
		tree.name = "Tree_%d" % i
		tree.position = Vector3(x, 0, z)
		tree.rotation.y = rng.randf() * TAU
		add_child(tree)

		var trunk_height := rng.randf_range(1.2, 2.5)
		var trunk_radius := rng.randf_range(0.12, 0.25)
		var crown_radius := rng.randf_range(0.8, 1.8)
		var crown_height := rng.randf_range(1.5, 3.0)

		var trunk_mesh := CylinderMesh.new()
		trunk_mesh.top_radius = trunk_radius * 0.7
		trunk_mesh.bottom_radius = trunk_radius
		trunk_mesh.height = trunk_height

		var trunk := MeshInstance3D.new()
		trunk.mesh = trunk_mesh
		trunk.position.y = trunk_height / 2.0
		trunk.set_surface_override_material(0, _trunk_mat)
		tree.add_child(trunk)

		var crown_mesh := SphereMesh.new()
		crown_mesh.radius = crown_radius
		crown_mesh.height = crown_height

		var crown := MeshInstance3D.new()
		crown.mesh = crown_mesh
		crown.position.y = trunk_height + crown_height * 0.35
		crown.set_surface_override_material(0, _leaves_mats[rng.randi() % _leaves_mats.size()])
		tree.add_child(crown)
		crown.create_trimesh_collision()

		trunk.create_trimesh_collision()
