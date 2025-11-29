extends Control

## SettingsController - Handles settings screen UI

@onready var music_toggle: CheckButton = $VBoxContainer/MusicContainer/MusicToggle
@onready var sfx_toggle: CheckButton = $VBoxContainer/SFXContainer/SFXToggle
@onready var dev_input: LineEdit = $VBoxContainer/DevContainer/DevInput
@onready var dev_status: Label = $VBoxContainer/DevContainer/DevStatus

func _ready() -> void:
	# Set initial toggle states
	music_toggle.button_pressed = AudioManager.is_music_enabled()
	sfx_toggle.button_pressed = AudioManager.is_sfx_enabled()
	
	# Update dev mode status
	_update_dev_status()

func _on_music_toggled(_button_pressed: bool) -> void:
	AudioManager.toggle_music()

func _on_sfx_toggled(_button_pressed: bool) -> void:
	AudioManager.toggle_sfx()

func _on_back_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_dev_input_text_submitted(new_text: String) -> void:
	if new_text == GameConfig.DEVOPS_CODE:
		DiamondManager.activate_dev_mode()
		dev_input.text = ""
		_update_dev_status()
		AudioManager.play_button_click()
	else:
		dev_input.text = ""

func _update_dev_status() -> void:
	if dev_status:
		if DiamondManager.is_dev_mode_active():
			dev_status.text = "🔧 DEV MODE ACTIVE"
			dev_status.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))
			dev_status.visible = true
		else:
			dev_status.visible = false
