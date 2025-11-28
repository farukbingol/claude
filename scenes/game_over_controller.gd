extends Control

## GameOverController - Handles game over screen UI

@onready var score_value: Label = $VBoxContainer/ScoreValue
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var new_record_label: Label = $VBoxContainer/NewRecordLabel
@onready var watch_ad_button: Button = $VBoxContainer/WatchAdButton
@onready var blocks_placed_label: Label = $VBoxContainer/StatsContainer/BlocksPlacedLabel
@onready var perfects_label: Label = $VBoxContainer/StatsContainer/PerfectsLabel
@onready var max_combo_label: Label = $VBoxContainer/StatsContainer/MaxComboLabel

func _ready() -> void:
	_update_ui()
	_handle_interstitial()
	
	# Connect ad signals
	AdManager.rewarded_ad_earned.connect(_on_rewarded_earned)
	AdManager.interstitial_closed.connect(_on_interstitial_closed)
	
	# Load rewarded ad for continue option
	AdManager.load_rewarded()
	
	# Play game over sound
	AudioManager.play_game_over()

func _update_ui() -> void:
	score_value.text = ScoreManager.get_score_text()
	high_score_label.text = "HIGH SCORE: " + ScoreManager.get_high_score_text()
	
	# Show new record label if applicable
	new_record_label.visible = ScoreManager.is_new_high_score()
	
	# Get game stats
	var stats = GameManager.get_game_stats()
	blocks_placed_label.text = "Blocks Placed: " + str(stats.block_count)
	perfects_label.text = "Perfect Placements: " + str(stats.perfect_count)
	max_combo_label.text = "Max Combo: " + str(stats.max_combo)
	
	# Hide watch ad button if continue not available or no ads
	watch_ad_button.visible = GameManager.continue_available and not IAPManager.is_no_ads_purchased()

func _handle_interstitial() -> void:
	# Only show interstitial if it's been enough games and ads are enabled
	if not IAPManager.is_no_ads_purchased():
		if StatsManager.should_show_interstitial():
			AdManager.load_interstitial()
		else:
			print("Skipping interstitial - not enough games since last one")

func _on_restart_pressed() -> void:
	AudioManager.play_button_click()
	
	# Show interstitial before restarting if it should be shown
	if not IAPManager.is_no_ads_purchased() and StatsManager.should_show_interstitial() and AdManager.is_interstitial_ready():
		StatsManager.reset_interstitial_counter()
		AdManager.show_interstitial()
		# Wait for interstitial to close, then restart
	else:
		_restart_game()

func _on_watch_ad_pressed() -> void:
	AudioManager.play_button_click()
	
	if AdManager.is_rewarded_ready():
		AdManager.show_rewarded()
	else:
		# Ad not ready, reload
		AdManager.load_rewarded()
		watch_ad_button.text = "LOADING AD..."
		await get_tree().create_timer(2.0).timeout
		if AdManager.is_rewarded_ready():
			watch_ad_button.text = "CONTINUE (WATCH AD)"
		else:
			watch_ad_button.text = "AD NOT AVAILABLE"

func _on_menu_pressed() -> void:
	AudioManager.play_button_click()
	GameManager.go_to_menu()

func _on_rewarded_earned() -> void:
	# Continue the game
	GameManager.continue_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_interstitial_closed() -> void:
	_restart_game()

func _restart_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
