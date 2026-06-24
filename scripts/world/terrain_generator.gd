extends Node

var terrain: Terrain3D
var _safety_floor: StaticBody3D

func _ready() -> void:
	_create_safety_floor()
	_freeze_player(true)
	terrain = await _create_terrain()
	await get_tree().create_timer(0.5).timeout
	_spawn_vegetation()
	_position_player()
	_freeze_player(false)
	_remove_safety_floor()
	print("[Terrain] Done")

func _create_safety_floor() -> void:
	_safety_floor = StaticBody3D.new()
	var col := CollisionShape3D.new()
	col.shape = WorldBoundaryShape3D.new()
	_safety_floor.add_child(col)
	_safety_floor.position.y = -1.0
	get_parent().add_child(_safety_floor)

func _remove_safety_floor() -> void:
	if _safety_floor:
		_safety_floor.queue_free()

func _freeze_player(freeze: bool) -> void:
	var player := get_parent().find_child("Player", false)
	if not player or not player is CharacterBody3D:
		return
	if freeze:
		player.global_position = Vector3(0, 3, 0)
		player.set_physics_process(false)
	else:
		player.set_physics_process(true)

func _position_player() -> void:
	var player := get_parent().find_child("Player", false)
	if player:
		player.global_position = Vector3(0, 2, 0)

func _create_terrain() -> Terrain3D:
	var grass_gradient := Gradient.new()
	grass_gradient.set_color(0, Color.from_hsv(100.0 / 360.0, 0.45, 0.35))
	grass_gradient.set_color(1, Color.from_hsv(125.0 / 360.0, 0.5, 0.4))
	var grass_ta: Terrain3DTextureAsset = await _create_texture("Grass", grass_gradient, 512)
	grass_ta.uv_scale = 0.08

	var dirt_gradient := Gradient.new()
	dirt_gradient.set_color(0, Color.from_hsv(30.0 / 360.0, 0.4, 0.25))
	dirt_gradient.set_color(1, Color.from_hsv(25.0 / 360.0, 0.45, 0.35))
	var dirt_ta: Terrain3DTextureAsset = await _create_texture("Dirt", dirt_gradient, 512)
	dirt_ta.uv_scale = 0.05

	terrain = Terrain3D.new()
	terrain.name = "Terrain3D"
	get_parent().add_child(terrain, true)

	terrain.material.world_background = Terrain3DMaterial.NONE
	terrain.material.auto_shader = true
	terrain.material.set_shader_param("auto_slope", 15)
	terrain.material.set_shader_param("blend_sharpness", 0.97)

	terrain.assets = Terrain3DAssets.new()
	terrain.assets.set_texture(0, grass_ta)
	terrain.assets.set_texture(1, dirt_ta)

	# Generate heightmap
	var size := 512
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.003
	noise.fractal_octaves = 4

	var img: Image = Image.create_empty(size, size, false, Image.FORMAT_RF)
	var center := Vector2(size / 2.0, size / 2.0)

	# Village area = ~20m radius = ~40 pixels at this scale
	# Each pixel = ~0.5m (size 512 maps to 256m world)
	var village_radius_px := 45.0
	var blend_radius_px := 40.0

	for x in range(size):
		for y in range(size):
			var raw_noise: float = noise.get_noise_2d(x, y)
			# Shift noise to be mostly positive (gentle hills)
			var h: float = (raw_noise + 1.0) * 0.5

			var dist: float = Vector2(x, y).distance_to(center)

			if dist < village_radius_px:
				# Flat village area at height 0
				h = 0.0
			elif dist < village_radius_px + blend_radius_px:
				# Smooth ramp from village to terrain
				var t: float = (dist - village_radius_px) / blend_radius_px
				t = t * t
				h = lerpf(0.0, h, t)

			img.set_pixel(x, y, Color(h, 0.0, 0.0, 1.0))

	terrain.region_size = 512
	# Map to world: 512px centered, height 0 to 30m
	terrain.data.import_images([img, null, null], Vector3(-256, 0, -256), 0.0, 30.0)

	terrain.collision.mode = Terrain3DCollision.DYNAMIC_GAME
	return terrain

func _spawn_vegetation() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 777
	var np := "res://assets/models/Ultimate Stylized Nature - May 2022/glTF/"

	var trees: Array[String] = [
		"BirchTree_1", "BirchTree_2", "BirchTree_3", "BirchTree_4", "BirchTree_5",
		"MapleTree_1", "MapleTree_2", "MapleTree_3", "MapleTree_4", "MapleTree_5",
	]
	var dead_trees: Array[String] = [
		"DeadTree_1", "DeadTree_2", "DeadTree_3", "DeadTree_4", "DeadTree_5",
	]
	var bushes: Array[String] = [
		"Bush", "Bush_Large", "Bush_Small",
		"Bush_Flowers", "Bush_Large_Flowers", "Bush_Small_Flowers",
	]
	var flowers: Array[String] = [
		"Flower_1_Clump", "Flower_2_Clump", "Flower_3_Clump",
		"Flower_4_Clump", "Flower_5_Clump",
	]
	var grass_models: Array[String] = ["Grass_Large", "Grass_Small"]

	var veg := Node3D.new()
	veg.name = "Vegetation"
	get_parent().add_child(veg)

	_scatter(rng, veg, np, trees, 100, 30, 120, 0.7, 1.4, true)
	_scatter(rng, veg, np, dead_trees, 10, 80, 120, 0.5, 0.9, false)
	_scatter(rng, veg, np, bushes, 50, 22, 100, 0.6, 1.2, false)
	_scatter(rng, veg, np, flowers, 30, 18, 60, 0.7, 1.3, false)
	_scatter(rng, veg, np, grass_models, 40, 15, 80, 0.5, 1.0, false)

const VILLAGE_CLEAR := 20.0

func _scatter(rng: RandomNumberGenerator, parent: Node3D, base_path: String,
		models: Array[String], count: int, min_dist: float, max_dist: float,
		scale_min: float, scale_max: float, with_collision: bool) -> void:
	var spawned := 0
	var attempts := 0
	while spawned < count and attempts < count * 4:
		attempts += 1
		var angle := rng.randf() * TAU
		var dist := rng.randf_range(min_dist, max_dist)
		var x := cos(angle) * dist
		var z := sin(angle) * dist

		if Vector2(x, z).length() < VILLAGE_CLEAR:
			continue

		var h: float = terrain.data.get_height(Vector3(x, 0, z))
		if is_nan(h) or h < -10:
			continue

		var model_name: String = models[rng.randi() % models.size()]
		var scene: PackedScene = load(base_path + model_name + ".gltf")
		if not scene:
			continue

		var inst := scene.instantiate()
		parent.add_child(inst)
		inst.position = Vector3(x, h, z)
		inst.rotation.y = rng.randf() * TAU
		var s := rng.randf_range(scale_min, scale_max)
		inst.scale = Vector3(s, s, s)
		spawned += 1

		if with_collision:
			_add_collision(inst)

func _add_collision(node: Node3D) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			child.create_trimesh_collision()
		if child.get_child_count() > 0:
			_add_collision(child)

func _create_texture(tex_name: String, gradient: Gradient, tex_size: int) -> Terrain3DTextureAsset:
	var fnl := FastNoiseLite.new()
	fnl.frequency = 0.004

	var alb_noise := NoiseTexture2D.new()
	alb_noise.width = tex_size
	alb_noise.height = tex_size
	alb_noise.seamless = true
	alb_noise.noise = fnl
	alb_noise.color_ramp = gradient
	await alb_noise.changed
	var alb_img: Image = alb_noise.get_image()
	for x in range(alb_img.get_width()):
		for y in range(alb_img.get_height()):
			var clr: Color = alb_img.get_pixel(x, y)
			clr.a = clr.v
			alb_img.set_pixel(x, y, clr)
	alb_img.generate_mipmaps()
	var albedo := ImageTexture.create_from_image(alb_img)

	var nrm_noise := NoiseTexture2D.new()
	nrm_noise.width = tex_size
	nrm_noise.height = tex_size
	nrm_noise.as_normal_map = true
	nrm_noise.seamless = true
	nrm_noise.noise = fnl
	await nrm_noise.changed
	var nrm_img: Image = nrm_noise.get_image()
	for x in range(nrm_img.get_width()):
		for y in range(nrm_img.get_height()):
			var c: Color = nrm_img.get_pixel(x, y)
			c.a = 0.8
			nrm_img.set_pixel(x, y, c)
	nrm_img.generate_mipmaps()
	var normal := ImageTexture.create_from_image(nrm_img)

	var ta := Terrain3DTextureAsset.new()
	ta.name = tex_name
	ta.albedo_texture = albedo
	ta.normal_texture = normal
	return ta
