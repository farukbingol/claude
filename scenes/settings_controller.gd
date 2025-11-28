extends Control

## SettingsController - Handles settings screen UI

@onready var music_toggle: CheckButton = $VBoxContainer/MusicContainer/MusicToggle
@onready var sfx_toggle: CheckButton = $VBoxContainer/SFXContainer/SFXToggle

func _ready() -> void:
	# Set initial toggle states
	music_toggle.button_pressed = AudioManager.is_music_enabled()
	sfx_toggle.button_pressed = AudioManager.is_sfx_enabled()

func _on_music_toggled(_button_pressed: bool) -> void:
	AudioManager.toggle_music()

func _on_sfx_toggled(_button_pressed: bool) -> void:
	AudioManager.toggle_sfx()

func _on_back_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
