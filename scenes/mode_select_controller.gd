extends Control

## ModeSelectController - Handles game mode selection

@onready var modes_list: VBoxContainer = $GlassPanel/VBoxContainer/ModesList

# Mode definitions
const MODES = {
	"endless": {
		"name": "Endless",
		"description": "Klasik mod - Sonsuza kadar oyna",
		"icon": "♾️",
		"color": Color(0.3, 0.8, 0.5)
	},
	"zen": {
		"name": "Zen",
		"description": "Rahatlatıcı - Puan yok, sadece oyna",
		"icon": "🧘",
		"color": Color(0.5, 0.7, 1)
	},
	"time_attack": {
		"name": "Time Attack",
		"description": "60 saniyede en çok blok",
		"icon": "⏱️",
		"color": Color(1, 0.6, 0.3)
	},
	"precision": {
		"name": "Precision",
		"description": "Sadece perfect - Bir hata, oyun biter",
		"icon": "🎯",
		"color": Color(0.9, 0.3, 0.3)
	},
	"speed_run": {
		"name": "Speed Run",
		"description": "100 bloğa en hızlı ulaş",
		"icon": "🏃",
		"color": Color(1, 0.8, 0.2)
	}
}

func _ready() -> void:
	_populate_modes()

func _populate_modes() -> void:
	# Clear existing items
	for child in modes_list.get_children():
		child.queue_free()
	
	# Add mode buttons
	for mode_id in MODES:
		var mode = MODES[mode_id]
		var button = _create_mode_button(mode_id, mode)
		modes_list.add_child(button)

func _create_mode_button(mode_id: String, mode: Dictionary) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 120)
	
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 120)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var is_unlocked = GameManager.is_item_unlocked(mode_id)
	var is_selected = GameManager.selected_mode == mode_id
	
	# Create content with HBox
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(hbox)
	
	# Icon
	var icon_label = Label.new()
	icon_label.custom_minimum_size = Vector2(80, 0)
	icon_label.text = mode.icon
	icon_label.add_theme_font_size_override("font_size", 48)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(icon_label)
	
	# Text container
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(vbox)
	
	# Name
	var name_label = Label.new()
	name_label.text = mode.name
	name_label.add_theme_font_size_override("font_size", 32)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_selected:
		name_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	elif not is_unlocked:
		name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	vbox.add_child(name_label)
	
	# Description
	var desc_label = Label.new()
	desc_label.text = mode.description
	desc_label.add_theme_font_size_override("font_size", 20)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(desc_label)
	
	# Status indicator
	var status_label = Label.new()
	status_label.custom_minimum_size = Vector2(100, 0)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 28)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if is_selected:
		status_label.text = "▶"
		status_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
	elif is_unlocked:
		status_label.text = ""
	else:
		status_label.text = "🔒"
		status_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	hbox.add_child(status_label)
	
	# Setup button
	button.disabled = not is_unlocked
	button.pressed.connect(_on_mode_selected.bind(mode_id))
	
	panel.add_child(button)
	return panel

func _on_mode_selected(mode_id: String) -> void:
	AudioManager.play_button_click()
	GameManager.set_mode(mode_id)
	_populate_modes()  # Refresh to show new selection
	
	# Start game with selected mode
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_back_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
