extends Node

var terrain: Terrain3D

func _ready() -> void:
	terrain = await _create_terrain()
	print("[Terrain] Generated terrain with Terrain3D")

func _create_terrain() -> Terrain3D:
	# Grass texture
	var grass_gradient := Gradient.new()
	grass_gradient.set_color(0, Color.from_hsv(100.0 / 360.0, 0.45, 0.35))
	grass_gradient.set_color(1, Color.from_hsv(125.0 / 360.0, 0.5, 0.4))
	var grass_ta: Terrain3DTextureAsset = await _create_texture("Grass", grass_gradient, 1024)
	grass_ta.uv_scale = 0.08

	# Dirt texture
	var dirt_gradient := Gradient.new()
	dirt_gradient.set_color(0, Color.from_hsv(30.0 / 360.0, 0.4, 0.25))
	dirt_gradient.set_color(1, Color.from_hsv(25.0 / 360.0, 0.45, 0.35))
	var dirt_ta: Terrain3DTextureAsset = await _create_texture("Dirt", dirt_gradient, 1024)
	dirt_ta.uv_scale = 0.05

	# Create terrain node
	terrain = Terrain3D.new()
	terrain.name = "Terrain3D"
	get_parent().add_child(terrain, true)

	# Configure material
	terrain.material.world_background = Terrain3DMaterial.NONE
	terrain.material.auto_shader = true
	terrain.material.set_shader_param("auto_slope", 15)
	terrain.material.set_shader_param("blend_sharpness", 0.97)

	# Set assets
	terrain.assets = Terrain3DAssets.new()
	terrain.assets.set_texture(0, grass_ta)
	terrain.assets.set_texture(1, dirt_ta)

	# Generate heightmap
	var size := 1024
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.001
	noise.fractal_octaves = 4

	var img: Image = Image.create_empty(size, size, false, Image.FORMAT_RF)
	var center := Vector2(size / 2.0, size / 2.0)
	var flat_radius := 80.0
	var blend_radius := 120.0

	for x in range(size):
		for y in range(size):
			var h: float = noise.get_noise_2d(x, y)

			# Flatten center area for the village
			var dist: float = Vector2(x, y).distance_to(center)
			if dist < flat_radius:
				h = 0.0
			elif dist < flat_radius + blend_radius:
				var t: float = (dist - flat_radius) / blend_radius
				t = t * t
				h = lerpf(0.0, h, t)

			img.set_pixel(x, y, Color(h, 0.0, 0.0, 1.0))

	terrain.region_size = 1024
	terrain.data.import_images([img, null, null], Vector3(-size / 2.0, 0, -size / 2.0), 0.0, 80.0)

	# Enable collision
	terrain.collision.mode = Terrain3DCollision.DYNAMIC_GAME

	return terrain

func _create_texture(tex_name: String, gradient: Gradient, tex_size: int) -> Terrain3DTextureAsset:
	var fnl := FastNoiseLite.new()
	fnl.frequency = 0.004

	# Albedo
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

	# Normal
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
