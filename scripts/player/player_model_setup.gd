extends Node3D

const ANIM_GENERAL := "res://assets/models/Animations/gltf/Rig_Medium/Rig_Medium_General.glb"
const ANIM_MOVEMENT := "res://assets/models/Animations/gltf/Rig_Medium/Rig_Medium_MovementBasic.glb"

var anim_player: AnimationPlayer = null
var _skeleton_path: String = ""

func _ready() -> void:
	var skeleton := _find_node_of_type(self, "Skeleton3D")
	if skeleton:
		_skeleton_path = str(get_path_to(skeleton))
		print("[Model] Skeleton found at: ", _skeleton_path)
	else:
		push_warning("[Model] No Skeleton3D found in model!")
		return

	anim_player = _find_node_of_type(self, "AnimationPlayer") as AnimationPlayer
	if not anim_player:
		anim_player = AnimationPlayer.new()
		anim_player.name = "AnimationPlayer"
		add_child(anim_player)

	if not anim_player.has_animation_library(""):
		anim_player.add_animation_library("", AnimationLibrary.new())

	_load_animations_from(ANIM_GENERAL)
	_load_animations_from(ANIM_MOVEMENT)

	var lib := anim_player.get_animation_library("")
	print("[Model] Loaded animations: ", lib.get_animation_list())

	if anim_player.has_animation("Idle_A"):
		anim_player.play("Idle_A")

func _find_node_of_type(node: Node, type_name: String) -> Node:
	if node.get_class() == type_name:
		return node
	for child in node.get_children():
		var found := _find_node_of_type(child, type_name)
		if found:
			return found
	return null

func _load_animations_from(glb_path: String) -> void:
	var scene: PackedScene = load(glb_path)
	if not scene:
		push_warning("[Model] Could not load: %s" % glb_path)
		return

	var instance := scene.instantiate()

	var source_skeleton := _find_node_of_type(instance, "Skeleton3D")
	var source_skel_path := ""
	if source_skeleton:
		source_skel_path = str(instance.get_path_to(source_skeleton))
		print("[Model] Source skeleton path in %s: %s" % [glb_path.get_file(), source_skel_path])

	var source_ap := _find_node_of_type(instance, "AnimationPlayer") as AnimationPlayer
	if not source_ap:
		instance.queue_free()
		return

	var source_lib := source_ap.get_animation_library("")
	if not source_lib:
		instance.queue_free()
		return

	var target_lib := anim_player.get_animation_library("")

	for anim_name in source_lib.get_animation_list():
		if anim_name == "T-Pose":
			continue
		if target_lib.has_animation(anim_name):
			continue
		var anim := source_lib.get_animation(anim_name).duplicate()
		_remap_paths(anim, source_skel_path)
		_set_loop_mode(anim, anim_name)
		target_lib.add_animation(anim_name, anim)

	instance.queue_free()

const LOOPING_ANIMS: Array[String] = [
	"Idle_A", "Idle_B", "Walking_A", "Walking_B", "Walking_C",
	"Running_A", "Running_B", "Jump_Idle",
]

func _set_loop_mode(anim: Animation, anim_name: String) -> void:
	if anim_name in LOOPING_ANIMS:
		anim.loop_mode = Animation.LOOP_LINEAR

func _remap_paths(anim: Animation, source_skel_path: String) -> void:
	for i in range(anim.get_track_count()):
		var path_str := str(anim.track_get_path(i))

		if source_skel_path != "" and path_str.begins_with(source_skel_path):
			var remainder := path_str.substr(source_skel_path.length())
			var new_path := _skeleton_path + remainder
			anim.track_set_path(i, NodePath(new_path))
		elif path_str.contains("Skeleton3D"):
			var idx := path_str.find("Skeleton3D")
			var remainder := path_str.substr(idx + "Skeleton3D".length())
			var new_path := _skeleton_path + remainder
			anim.track_set_path(i, NodePath(new_path))
