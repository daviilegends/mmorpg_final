extends Node3D

const ANIM_GENERAL := "res://assets/models/Animations/gltf/Rig_Medium/Rig_Medium_General.glb"
const ANIM_MOVEMENT := "res://assets/models/Animations/gltf/Rig_Medium/Rig_Medium_MovementBasic.glb"

var anim_player: AnimationPlayer = null

func _ready() -> void:
	anim_player = _find_animation_player(self)
	if not anim_player:
		anim_player = AnimationPlayer.new()
		anim_player.name = "AnimationPlayer"
		add_child(anim_player)
		var lib := AnimationLibrary.new()
		anim_player.add_animation_library("", lib)

	_load_animations_from(ANIM_GENERAL)
	_load_animations_from(ANIM_MOVEMENT)

	if anim_player.has_animation("Idle_A"):
		anim_player.play("Idle_A")

func _find_animation_player(node: Node) -> AnimationPlayer:
	for child in node.get_children():
		if child is AnimationPlayer:
			return child
		var found := _find_animation_player(child)
		if found:
			return found
	return null

func _load_animations_from(glb_path: String) -> void:
	var scene: PackedScene = load(glb_path)
	if not scene:
		push_warning("Could not load animation file: %s" % glb_path)
		return

	var instance := scene.instantiate()
	var source_ap := _find_animation_player(instance)
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
		_remap_paths(anim)
		target_lib.add_animation(anim_name, anim)

	instance.queue_free()

func _remap_paths(anim: Animation) -> void:
	for i in range(anim.get_track_count()):
		var path_str := str(anim.track_get_path(i))
		if path_str.contains("/Skeleton3D"):
			var idx := path_str.find("Skeleton3D")
			var new_path := path_str.substr(idx)
			anim.track_set_path(i, NodePath(new_path))
