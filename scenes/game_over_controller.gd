extends Control

## GameOverController - Handles game over screen UI

@onready var score_value: Label = $VBoxContainer/ScoreValue
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var new_record_label: Label = $VBoxContainer/NewRecordLabel
@onready var watch_ad_button: Button = $VBoxContainer/WatchAdButton

func _ready() -> void:
	_update_ui()
	_load_interstitial()
	
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
	
	# Hide watch ad button if continue not available or no ads
	watch_ad_button.visible = GameManager.continue_available and not IAPManager.is_no_ads_purchased()

func _load_interstitial() -> void:
	# Show interstitial ad after game over (if ads enabled)
	if not IAPManager.is_no_ads_purchased():
		AdManager.load_interstitial()

func _on_restart_pressed() -> void:
	AudioManager.play_button_click()
	
	# Show interstitial before restarting
	if not IAPManager.is_no_ads_purchased() and AdManager.is_interstitial_ready():
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
			watch_ad_button.text = "WATCH AD TO CONTINUE"
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
