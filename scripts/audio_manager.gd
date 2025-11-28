extends Node

## AudioManager - Handles all game audio
## Background music and sound effects

signal music_toggled(enabled: bool)
signal sfx_toggled(enabled: bool)

# Audio settings
var music_enabled: bool = true
var sfx_enabled: bool = true
var music_volume: float = 0.8
var sfx_volume: float = 1.0

# Audio players
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS: int = 8

# Save file path
const SAVE_PATH: String = "user://audio_settings.save"

# Sound effect names
const SFX_BLOCK_PLACE: String = "block_place"
const SFX_PERFECT: String = "perfect"
const SFX_GAME_OVER: String = "game_over"
const SFX_BUTTON_CLICK: String = "button_click"
const SFX_BLOCK_DROP: String = "block_drop"

# Preloaded sounds (placeholder - actual sounds would be loaded from files)
var sounds: Dictionary = {}

func _ready() -> void:
	_load_settings()
	_setup_audio_players()
	_load_sounds()
	print("AudioManager initialized. Music: ", music_enabled, ", SFX: ", sfx_enabled)

## Setup audio stream players
func _setup_audio_players() -> void:
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Create pool of SFX players
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)

## Load sound files
func _load_sounds() -> void:
	# Try to load sounds from assets folder
	# These are placeholders - actual sounds would be .wav or .ogg files
	var sound_files = {
		SFX_BLOCK_PLACE: "res://assets/sounds/block_place.wav",
		SFX_PERFECT: "res://assets/sounds/perfect.wav",
		SFX_GAME_OVER: "res://assets/sounds/game_over.wav",
		SFX_BUTTON_CLICK: "res://assets/sounds/button_click.wav",
		SFX_BLOCK_DROP: "res://assets/sounds/block_drop.wav"
	}
	
	for sound_name in sound_files:
		var path = sound_files[sound_name]
		if ResourceLoader.exists(path):
			sounds[sound_name] = load(path)
		else:
			# Create a placeholder beep sound
			sounds[sound_name] = null
			print("Sound file not found: ", path)

## Play a sound effect
func play_sfx(sound_name: String) -> void:
	if not sfx_enabled:
		return
	
	var sound = sounds.get(sound_name)
	if sound == null:
		# Generate a simple beep for testing
		print("Playing SFX (placeholder): ", sound_name)
		return
	
	# Find an available player
	for player in sfx_players:
		if not player.playing:
			player.stream = sound
			player.volume_db = linear_to_db(sfx_volume)
			player.play()
			return
	
	# All players busy, use first one
	sfx_players[0].stream = sound
	sfx_players[0].volume_db = linear_to_db(sfx_volume)
	sfx_players[0].play()

## Play background music
func play_music(music_path: String = "res://assets/sounds/background_music.ogg") -> void:
	if not music_enabled:
		return
	
	if ResourceLoader.exists(music_path):
		var music = load(music_path)
		music_player.stream = music
		music_player.volume_db = linear_to_db(music_volume)
		music_player.play()
		print("Playing music: ", music_path)
	else:
		print("Music file not found: ", music_path)

## Stop background music
func stop_music() -> void:
	music_player.stop()

## Toggle music on/off
func toggle_music() -> void:
	music_enabled = not music_enabled
	
	if music_enabled:
		# Resume music if it was playing
		if music_player.stream != null:
			music_player.play()
	else:
		music_player.stop()
	
	_save_settings()
	music_toggled.emit(music_enabled)
	print("Music toggled: ", music_enabled)

## Toggle sound effects on/off
func toggle_sfx() -> void:
	sfx_enabled = not sfx_enabled
	_save_settings()
	sfx_toggled.emit(sfx_enabled)
	print("SFX toggled: ", sfx_enabled)

## Set music volume (0.0 to 1.0)
func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	music_player.volume_db = linear_to_db(music_volume)
	_save_settings()

## Set SFX volume (0.0 to 1.0)
func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	_save_settings()

## Check if music is enabled
func is_music_enabled() -> bool:
	return music_enabled

## Check if SFX is enabled
func is_sfx_enabled() -> bool:
	return sfx_enabled

## Save audio settings
func _save_settings() -> void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"music_enabled": music_enabled,
			"sfx_enabled": sfx_enabled,
			"music_volume": music_volume,
			"sfx_volume": sfx_volume
		}
		save_file.store_var(save_data)
		save_file.close()

## Load audio settings
func _load_settings() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			save_file.close()
			if save_data is Dictionary:
				music_enabled = save_data.get("music_enabled", true)
				sfx_enabled = save_data.get("sfx_enabled", true)
				music_volume = save_data.get("music_volume", 0.8)
				sfx_volume = save_data.get("sfx_volume", 1.0)

## Play block placement sound
func play_block_place() -> void:
	play_sfx(SFX_BLOCK_PLACE)

## Play perfect placement sound
func play_perfect() -> void:
	play_sfx(SFX_PERFECT)

## Play game over sound
func play_game_over() -> void:
	play_sfx(SFX_GAME_OVER)

## Play button click sound
func play_button_click() -> void:
	play_sfx(SFX_BUTTON_CLICK)

## Play block drop sound
func play_block_drop() -> void:
	play_sfx(SFX_BLOCK_DROP)
