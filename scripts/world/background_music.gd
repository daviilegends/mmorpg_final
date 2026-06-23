extends AudioStreamPlayer

@export var music_path: String = "res://assets/audio/andorios-rpg-medieval-animated-music-320583.mp3"
@export var volume_db: float = -10.0

func _ready() -> void:
	var stream: AudioStream = load(music_path)
	if not stream:
		push_warning("[Music] Could not load: %s" % music_path)
		return
	self.stream = stream
	self.volume_db = volume_db
	self.bus = &"Master"
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	play()
