extends Control

## AchievementsController - Displays all achievements and their progress

@onready var achievements_list: VBoxContainer = $GlassPanel/VBoxContainer/ScrollContainer/AchievementsList
@onready var count_label: Label = $GlassPanel/VBoxContainer/Header/CountLabel

func _ready() -> void:
	_populate_achievements()
	_update_count()

func _populate_achievements() -> void:
	# Clear existing items
	for child in achievements_list.get_children():
		child.queue_free()
	
	# Add achievement items
	var achievements = AchievementManager.get_all_achievements()
	for achievement in achievements:
		var item = _create_achievement_item(achievement)
		achievements_list.add_child(item)

func _create_achievement_item(achievement: Dictionary) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 100)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	panel.add_child(hbox)
	
	# Status icon
	var status_label = Label.new()
	status_label.custom_minimum_size = Vector2(60, 0)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 36)
	if achievement.unlocked:
		status_label.text = "✅"
	else:
		status_label.text = "🔒"
	hbox.add_child(status_label)
	
	# Text container
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	# Name
	var name_label = Label.new()
	name_label.text = achievement.name
	name_label.add_theme_font_size_override("font_size", 28)
	if achievement.unlocked:
		name_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	vbox.add_child(name_label)
	
	# Description
	var desc_label = Label.new()
	desc_label.text = achievement.description
	desc_label.add_theme_font_size_override("font_size", 20)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(desc_label)
	
	# Progress bar (if not unlocked)
	if not achievement.unlocked:
		var progress_container = HBoxContainer.new()
		vbox.add_child(progress_container)
		
		var progress_bar = ProgressBar.new()
		progress_bar.custom_minimum_size = Vector2(200, 20)
		progress_bar.max_value = achievement.target
		progress_bar.value = min(achievement.progress, achievement.target)
		progress_bar.show_percentage = false
		progress_container.add_child(progress_bar)
		
		var progress_text = Label.new()
		progress_text.text = " " + str(achievement.progress) + "/" + str(achievement.target)
		progress_text.add_theme_font_size_override("font_size", 18)
		progress_text.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		progress_container.add_child(progress_text)
	
	# Reward label
	var reward_label = Label.new()
	reward_label.custom_minimum_size = Vector2(120, 0)
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	reward_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	reward_label.add_theme_font_size_override("font_size", 18)
	
	if achievement.reward_type == "xp":
		reward_label.text = "+" + str(achievement.reward_value) + " XP"
		reward_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1))
	elif achievement.reward_type == "unlock":
		reward_label.text = "🎁 Unlock"
		reward_label.add_theme_color_override("font_color", Color(1, 0.6, 0.8))
	
	hbox.add_child(reward_label)
	
	return panel

func _update_count() -> void:
	var unlocked = AchievementManager.get_unlock_count()
	var total = AchievementManager.get_total_count()
	count_label.text = str(unlocked) + "/" + str(total)

func _on_back_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
