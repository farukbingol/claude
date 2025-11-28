extends Node

## StatsManager - Handles persistent game statistics

signal stats_updated

# Statistics
var total_games: int = 0
var total_blocks: int = 0
var total_perfects: int = 0
var best_combo: int = 0
var games_since_interstitial: int = 0

# Save file path
const SAVE_PATH: String = "user://stats_data.save"

func _ready() -> void:
	_load_stats()
	print("StatsManager initialized. Total games: ", total_games)

## Record a completed game
func record_game(blocks_placed: int, perfects: int, max_combo: int) -> void:
	total_games += 1
	total_blocks += blocks_placed
	total_perfects += perfects
	games_since_interstitial += 1
	
	if max_combo > best_combo:
		best_combo = max_combo
	
	_save_stats()
	stats_updated.emit()
	print("Game recorded. Total games: ", total_games)

## Check if interstitial ad should be shown
func should_show_interstitial() -> bool:
	return games_since_interstitial >= GameConfig.GAMES_BETWEEN_INTERSTITIALS

## Reset interstitial counter (call after showing interstitial)
func reset_interstitial_counter() -> void:
	games_since_interstitial = 0
	_save_stats()

## Get all stats as dictionary
func get_stats() -> Dictionary:
	return {
		"total_games": total_games,
		"total_blocks": total_blocks,
		"total_perfects": total_perfects,
		"best_combo": best_combo
	}

## Save stats to local storage
func _save_stats() -> void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"total_games": total_games,
			"total_blocks": total_blocks,
			"total_perfects": total_perfects,
			"best_combo": best_combo,
			"games_since_interstitial": games_since_interstitial
		}
		save_file.store_var(save_data)
		save_file.close()
		print("Stats saved")
	else:
		print("Error saving stats!")

## Load stats from local storage
func _load_stats() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			save_file.close()
			if save_data is Dictionary:
				total_games = save_data.get("total_games", 0)
				total_blocks = save_data.get("total_blocks", 0)
				total_perfects = save_data.get("total_perfects", 0)
				best_combo = save_data.get("best_combo", 0)
				games_since_interstitial = save_data.get("games_since_interstitial", 0)
				print("Stats loaded")
	else:
		total_games = 0
		total_blocks = 0
		total_perfects = 0
		best_combo = 0
		games_since_interstitial = 0
