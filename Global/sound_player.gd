#class_name BaseSoundPlayer
extends Node


@export var sound_map: Dictionary[String, AudioStream]





static var add_max_db = 10.
static var add_min_db = -20.
static var add_max_linear_db: float
static var add_min_linear_db: float

func _ready():
	add_max_linear_db = db_to_linear(add_max_db)
	add_min_linear_db = db_to_linear(add_min_db)

func play_music(audio: AudioStream, adjusted_volumb_db: float = 0.):
	play(audio, true, State.music_volume, adjusted_volumb_db)

func play_sfx(audio: AudioStream, adjusted_volumb_db: float = 0.):
	play(audio, false, State.sfx_volume, adjusted_volumb_db)

func play_sfx_by_id(id: String):
	if id in sound_map:
		play_sfx(sound_map[id] , 0.)
	
func play(audio: AudioStream, single: bool = false, setting_volume_db: float = 0., adjusted_volumb_db: float = 0.):
	if not audio:
		return
	
	if single:
		stop()
	
	for player: AudioStreamPlayer in get_children():
		if not player.playing:
			player.volume_db = setting_volume_db + adjusted_volumb_db
			player.stream = audio
			player.play()
			break

func play_energy(audio: AudioStream, single: bool = false, 
		energy_factor: float = 0.5):
			
	energy_factor = clamp(energy_factor, 0, 1)
	var volumb_db = linear_to_db(lerp(add_min_linear_db, add_max_linear_db, energy_factor))
	play(audio, single, volumb_db)
	

func stop():
	for player: AudioStreamPlayer in get_children():
		player.stop()
