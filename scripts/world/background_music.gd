extends AudioStreamPlayer

@export var music_path: String = "res://assets/audio/andorios-rpg-medieval-animated-music-320583.mp3"

func _ready() -> void:
	add_to_group("background_music")
	var stream: AudioStream = load(music_path)
	if not stream:
		push_warning("[Music] Could not load: %s" % music_path)
		return
	self.stream = stream
	volume_db = -10.0
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	play()
