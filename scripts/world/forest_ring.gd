extends Node3D

const NATURE := "res://assets/models/Ultimate Stylized Nature - May 2022/glTF/"

const TREES: Array[String] = [
	"BirchTree_1", "BirchTree_2", "BirchTree_3", "BirchTree_4", "BirchTree_5",
	"MapleTree_1", "MapleTree_2", "MapleTree_3", "MapleTree_4", "MapleTree_5",
]
const BUSHES: Array[String] = [
	"Bush", "Bush_Large", "Bush_Small",
	"Bush_Flowers", "Bush_Large_Flowers", "Bush_Small_Flowers",
]
const FLOWERS: Array[String] = [
	"Flower_1_Clump", "Flower_2_Clump", "Flower_3_Clump",
	"Flower_4_Clump", "Flower_5_Clump",
]
const GRASS: Array[String] = [
	"Grass_Large", "Grass_Small",
]

@export var inner_radius: float = 18.0
@export var outer_radius: float = 38.0
@export var tree_count: int = 180
@export var bush_count: int = 120
@export var flower_count: int = 80
@export var grass_count: int = 100

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42

	_spawn_ring(rng, TREES, tree_count, inner_radius, outer_radius, 0.6, 1.4)
	_spawn_ring(rng, BUSHES, bush_count, inner_radius - 3.0, outer_radius, 0.7, 1.3)
	_spawn_ring(rng, FLOWERS, flower_count, inner_radius - 5.0, outer_radius - 5.0, 0.8, 1.5)
	_spawn_ring(rng, GRASS, grass_count, inner_radius - 6.0, outer_radius - 3.0, 0.6, 1.2)

func _spawn_ring(rng: RandomNumberGenerator, models: Array[String], count: int,
		r_min: float, r_max: float, scale_min: float, scale_max: float) -> void:
	for i in range(count):
		var angle := rng.randf() * TAU
		var dist := rng.randf_range(r_min, r_max)
		var pos := Vector3(cos(angle) * dist, 0, sin(angle) * dist)

		var model_name: String = models[rng.randi() % models.size()]
		var scene: PackedScene = load(NATURE + model_name + ".gltf")
		if not scene:
			continue

		var inst := scene.instantiate()
		add_child(inst)
		inst.position = pos
		inst.rotation.y = rng.randf() * TAU
		var s := rng.randf_range(scale_min, scale_max)
		inst.scale = Vector3(s, s, s)

		_add_collision(inst)

func _add_collision(node: Node3D) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			child.create_trimesh_collision()
		if child.get_child_count() > 0:
			_add_collision(child)
