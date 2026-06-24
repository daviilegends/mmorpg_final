extends Node

var terrain: Terrain3D

func _ready() -> void:
	terrain = await _create_terrain()
	_spawn_vegetation()
	_position_player()
	print("[Terrain] Generated terrain with vegetation")

func _position_player() -> void:
	await get_tree().process_frame
	var player := get_parent().find_child("Player", false)
	if player:
		var h: float = terrain.data.get_height(Vector3.ZERO)
		player.global_position = Vector3(0, h + 2, 0)

func _create_terrain() -> Terrain3D:
	var grass_gradient := Gradient.new()
	grass_gradient.set_color(0, Color.from_hsv(100.0 / 360.0, 0.45, 0.35))
	grass_gradient.set_color(1, Color.from_hsv(125.0 / 360.0, 0.5, 0.4))
	var grass_ta: Terrain3DTextureAsset = await _create_texture("Grass", grass_gradient, 1024)
	grass_ta.uv_scale = 0.08

	var dirt_gradient := Gradient.new()
	dirt_gradient.set_color(0, Color.from_hsv(30.0 / 360.0, 0.4, 0.25))
	dirt_gradient.set_color(1, Color.from_hsv(25.0 / 360.0, 0.45, 0.35))
	var dirt_ta: Terrain3DTextureAsset = await _create_texture("Dirt", dirt_gradient, 1024)
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

	var size := 1024
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.0008
	noise.fractal_octaves = 5

	# Second noise for mountain ridges
	var ridge_noise := FastNoiseLite.new()
	ridge_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	ridge_noise.frequency = 0.002
	ridge_noise.fractal_octaves = 3

	var img: Image = Image.create_empty(size, size, false, Image.FORMAT_RF)
	var center := Vector2(size / 2.0, size / 2.0)
	var flat_radius := 60.0
	var blend_radius := 80.0

	for x in range(size):
		for y in range(size):
			var h: float = noise.get_noise_2d(x, y)
			var ridge: float = absf(ridge_noise.get_noise_2d(x, y))
			ridge = ridge * ridge * 1.5

			var dist: float = Vector2(x, y).distance_to(center)

			if dist < flat_radius:
				h = 0.0
			elif dist < flat_radius + blend_radius:
				var t: float = (dist - flat_radius) / blend_radius
				t = t * t * t
				h = lerpf(0.0, h + ridge, t)
			else:
				h = h + ridge
				var edge_factor: float = clampf((dist - 300) / 200.0, 0, 1)
				h += edge_factor * 0.5

			img.set_pixel(x, y, Color(h, 0.0, 0.0, 1.0))

	terrain.region_size = 1024
	terrain.data.import_images([img, null, null], Vector3(-size / 2.0, 0, -size / 2.0), 0.0, 120.0)

	terrain.collision.mode = Terrain3DCollision.DYNAMIC_GAME

	return terrain

func _spawn_vegetation() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 777
	var nature_path := "res://assets/models/Ultimate Stylized Nature - May 2022/glTF/"

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
	var grass: Array[String] = ["Grass_Large", "Grass_Small"]

	var veg_node := Node3D.new()
	veg_node.name = "Vegetation"
	get_parent().add_child(veg_node)

	# Dense forest outside village
	_scatter(rng, veg_node, nature_path, trees, 400, 25, 450, 0.7, 1.6, true)
	# Some trees closer to village
	_scatter(rng, veg_node, nature_path, trees, 60, 15, 30, 0.5, 1.0, true)
	# Dead trees scattered in mountains
	_scatter(rng, veg_node, nature_path, dead_trees, 40, 80, 400, 0.6, 1.2, false)
	# Bushes everywhere
	_scatter(rng, veg_node, nature_path, bushes, 300, 10, 400, 0.6, 1.4, true)
	# Flowers around village
	_scatter(rng, veg_node, nature_path, flowers, 150, 8, 200, 0.7, 1.5, false)
	# Grass patches
	_scatter(rng, veg_node, nature_path, grass, 250, 5, 350, 0.5, 1.3, false)

func _scatter(rng: RandomNumberGenerator, parent: Node3D, base_path: String,
		models: Array[String], count: int, min_dist: float, max_dist: float,
		scale_min: float, scale_max: float, with_collision: bool) -> void:
	for i in range(count):
		var angle := rng.randf() * TAU
		var dist := rng.randf_range(min_dist, max_dist)
		var x := cos(angle) * dist
		var z := sin(angle) * dist

		var h: float = terrain.data.get_height(Vector3(x, 0, z))
		if h < -50 or h > 100:
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
