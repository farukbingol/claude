extends Control

## MainMenuController - Handles main menu UI interactions

@onready var high_score_label: Label = $HighScoreLabel
@onready var no_ads_button: Button = $VBoxContainer/NoAdsButton

func _ready() -> void:
	_update_high_score()
	_update_no_ads_button()
	
	# Connect to IAP signals
	IAPManager.purchase_completed.connect(_on_purchase_completed)

func _update_high_score() -> void:
	high_score_label.text = "HIGH SCORE: " + ScoreManager.get_high_score_text()

func _update_no_ads_button() -> void:
	if IAPManager.is_no_ads_purchased():
		no_ads_button.text = "ADS REMOVED ✓"
		no_ads_button.disabled = true
	else:
		no_ads_button.text = "NO ADS"
		no_ads_button.disabled = false

func _on_play_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_no_ads_pressed() -> void:
	AudioManager.play_button_click()
	IAPManager.purchase_no_ads()

func _on_purchase_completed(_product_id: String) -> void:
	_update_no_ads_button()
