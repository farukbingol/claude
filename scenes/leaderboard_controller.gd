extends Control

## LeaderboardController - Displays leaderboard rankings
## Note: This is a mock implementation - actual implementation would require a backend service

@onready var leaderboard_list: VBoxContainer = $GlassPanel/VBoxContainer/ScrollContainer/LeaderboardList
@onready var your_rank_label: Label = $GlassPanel/VBoxContainer/YourRankContainer/YourRankLabel
@onready var global_button: Button = $GlassPanel/VBoxContainer/TabButtons/GlobalButton
@onready var country_button: Button = $GlassPanel/VBoxContainer/TabButtons/CountryButton
@onready var weekly_button: Button = $GlassPanel/VBoxContainer/TabButtons/WeeklyButton

# Current tab
var current_tab: String = "global"

# Mock leaderboard data
var mock_data = {
	"global": [
		{"rank": 1, "name": "ProGamer123", "score": 15420, "country": "🇹🇷"},
		{"rank": 2, "name": "StackMaster", "score": 14850, "country": "🇺🇸"},
		{"rank": 3, "name": "TowerKing", "score": 13200, "country": "🇯🇵"},
		{"rank": 4, "name": "BlockChamp", "score": 12100, "country": "🇩🇪"},
		{"rank": 5, "name": "PerfectPlayer", "score": 11500, "country": "🇰🇷"},
		{"rank": 6, "name": "SpeedDemon", "score": 10800, "country": "🇧🇷"},
		{"rank": 7, "name": "ComboKing", "score": 10200, "country": "🇬🇧"},
		{"rank": 8, "name": "TowerNinja", "score": 9800, "country": "🇫🇷"},
		{"rank": 9, "name": "StackPro", "score": 9400, "country": "🇮🇹"},
		{"rank": 10, "name": "BlockBuilder", "score": 9000, "country": "🇪🇸"}
	],
	"country": [
		{"rank": 1, "name": "AhmetPro", "score": 15420, "country": "🇹🇷"},
		{"rank": 2, "name": "MehmetStack", "score": 12300, "country": "🇹🇷"},
		{"rank": 3, "name": "AyşeGamer", "score": 11000, "country": "🇹🇷"},
		{"rank": 4, "name": "FatihBlock", "score": 10500, "country": "🇹🇷"},
		{"rank": 5, "name": "EcePlay", "score": 9800, "country": "🇹🇷"}
	],
	"weekly": [
		{"rank": 1, "name": "WeeklyKing", "score": 8500, "country": "🇹🇷"},
		{"rank": 2, "name": "NewStar", "score": 7200, "country": "🇺🇸"},
		{"rank": 3, "name": "RisingStar", "score": 6800, "country": "🇯🇵"},
		{"rank": 4, "name": "FreshPlayer", "score": 6200, "country": "🇩🇪"},
		{"rank": 5, "name": "WeeklyPro", "score": 5800, "country": "🇰🇷"}
	]
}

func _ready() -> void:
	_update_tab_buttons()
	_populate_leaderboard()
	_update_your_rank()

func _populate_leaderboard() -> void:
	# Clear existing items
	for child in leaderboard_list.get_children():
		child.queue_free()
	
	# Add leaderboard entries
	var data = mock_data[current_tab]
	for entry in data:
		var item = _create_leaderboard_item(entry)
		leaderboard_list.add_child(item)

func _create_leaderboard_item(entry: Dictionary) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 80)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	panel.add_child(hbox)
	
	# Rank with special styling for top 3
	var rank_label = Label.new()
	rank_label.custom_minimum_size = Vector2(80, 0)
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rank_label.add_theme_font_size_override("font_size", 32)
	
	match entry.rank:
		1:
			rank_label.text = "🥇"
		2:
			rank_label.text = "🥈"
		3:
			rank_label.text = "🥉"
		_:
			rank_label.text = "#" + str(entry.rank)
			rank_label.add_theme_font_size_override("font_size", 24)
	hbox.add_child(rank_label)
	
	# Country flag
	var country_label = Label.new()
	country_label.text = entry.country
	country_label.add_theme_font_size_override("font_size", 28)
	country_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(country_label)
	
	# Name
	var name_label = Label.new()
	name_label.text = entry.name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 26)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(name_label)
	
	# Score
	var score_label = Label.new()
	score_label.custom_minimum_size = Vector2(150, 0)
	score_label.text = _format_score(entry.score)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_label.add_theme_font_size_override("font_size", 26)
	score_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	hbox.add_child(score_label)
	
	return panel

func _format_score(score: int) -> String:
	# Format with thousand separators
	var s = str(score)
	var result = ""
	var count = 0
	for i in range(len(s) - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result

func _update_your_rank() -> void:
	var your_score = ScoreManager.high_score
	
	# Simulate finding your rank
	var your_rank = 42  # Mock rank
	if your_score > 15000:
		your_rank = 1
	elif your_score > 10000:
		your_rank = randi_range(2, 10)
	elif your_score > 5000:
		your_rank = randi_range(11, 50)
	elif your_score > 1000:
		your_rank = randi_range(51, 200)
	else:
		your_rank = randi_range(201, 1000)
	
	your_rank_label.text = "Senin sıran: #" + str(your_rank) + " - " + _format_score(your_score) + " puan"

func _update_tab_buttons() -> void:
	global_button.button_pressed = current_tab == "global"
	country_button.button_pressed = current_tab == "country"
	weekly_button.button_pressed = current_tab == "weekly"

func _on_global_pressed() -> void:
	AudioManager.play_button_click()
	current_tab = "global"
	_update_tab_buttons()
	_populate_leaderboard()

func _on_country_pressed() -> void:
	AudioManager.play_button_click()
	current_tab = "country"
	_update_tab_buttons()
	_populate_leaderboard()

func _on_weekly_pressed() -> void:
	AudioManager.play_button_click()
	current_tab = "weekly"
	_update_tab_buttons()
	_populate_leaderboard()

func _on_back_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
