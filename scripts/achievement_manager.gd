extends Node

## AchievementManager - Handles achievements and rewards
## Tracks player progress and unlocks achievements

signal achievement_unlocked(achievement_id: String)
signal reward_granted(reward_type: String, reward_value: Variant)

# Achievement definitions
const ACHIEVEMENTS = {
	"first_steps": {
		"name": "İlk Adım",
		"description": "10 blok yerleştir",
		"condition": "blocks_placed",
		"target": 10,
		"reward_type": "xp",
		"reward_value": 100
	},
	"apprentice": {
		"name": "Çırak",
		"description": "50 blok yerleştir",
		"condition": "blocks_placed",
		"target": 50,
		"reward_type": "unlock",
		"reward_value": "time_attack"
	},
	"master": {
		"name": "Usta",
		"description": "100 blok yerleştir",
		"condition": "blocks_placed",
		"target": 100,
		"reward_type": "unlock",
		"reward_value": "speed_run"
	},
	"legend": {
		"name": "Efsane",
		"description": "500 blok yerleştir",
		"condition": "blocks_placed",
		"target": 500,
		"reward_type": "unlock",
		"reward_value": "sakura_theme"
	},
	"god": {
		"name": "Tanrı",
		"description": "1000 blok yerleştir",
		"condition": "blocks_placed",
		"target": 1000,
		"reward_type": "unlock",
		"reward_value": "space_theme"
	},
	"sharpshooter": {
		"name": "Keskin Nişancı",
		"description": "5 perfect üst üste",
		"condition": "perfect_streak",
		"target": 5,
		"reward_type": "unlock",
		"reward_value": "precision"
	},
	"fireball": {
		"name": "Ateş Topu",
		"description": "10 combo yap",
		"condition": "max_combo",
		"target": 10,
		"reward_type": "xp",
		"reward_value": 500
	},
	"unstoppable": {
		"name": "Durdurulamaz",
		"description": "20 combo yap",
		"condition": "max_combo",
		"target": 20,
		"reward_type": "unlock",
		"reward_value": "neon_theme"
	},
	"high_flyer": {
		"name": "Yüksek Uçuş",
		"description": "Bulutlara ulaş (60 blok)",
		"condition": "blocks_placed",
		"target": 60,
		"reward_type": "xp",
		"reward_value": 200
	},
	"astronaut": {
		"name": "Astronot",
		"description": "Uzaya ulaş (100 blok)",
		"condition": "blocks_placed",
		"target": 100,
		"reward_type": "xp",
		"reward_value": 500
	},
	"wind_master": {
		"name": "Rüzgar Ustası",
		"description": "Rüzgarda 10 blok yerleştir",
		"condition": "wind_blocks",
		"target": 10,
		"reward_type": "xp",
		"reward_value": 300
	},
	"speed_demon": {
		"name": "Hız Şeytanı",
		"description": "Maksimum hızda 5 blok yerleştir",
		"condition": "max_speed_blocks",
		"target": 5,
		"reward_type": "xp",
		"reward_value": 400
	},
	"perfectionist": {
		"name": "Mükemmeliyetçi",
		"description": "Tek oyunda 10 perfect",
		"condition": "game_perfects",
		"target": 10,
		"reward_type": "xp",
		"reward_value": 250
	},
	"marathon": {
		"name": "Maraton",
		"description": "10 oyun oyna",
		"condition": "total_games",
		"target": 10,
		"reward_type": "xp",
		"reward_value": 150
	},
	"dedicated": {
		"name": "Bağımlı",
		"description": "50 oyun oyna",
		"condition": "total_games",
		"target": 50,
		"reward_type": "xp",
		"reward_value": 500
	}
}

# Unlocked achievements
var unlocked_achievements: Array = []

# Progress tracking
var progress: Dictionary = {
	"blocks_placed": 0,
	"perfect_streak": 0,
	"max_combo": 0,
	"wind_blocks": 0,
	"max_speed_blocks": 0,
	"game_perfects": 0,
	"total_games": 0
}

# Session tracking (reset each game)
var session_perfects: int = 0
var session_combo: int = 0
var session_wind_blocks: int = 0
var session_max_speed_blocks: int = 0

# Save file path
const SAVE_PATH: String = "user://achievements.save"

func _ready() -> void:
	_load_data()
	print("AchievementManager initialized. Unlocked: ", len(unlocked_achievements))

## Check and unlock achievements based on current progress
func _check_achievements() -> void:
	for achievement_id in ACHIEVEMENTS:
		if achievement_id in unlocked_achievements:
			continue  # Already unlocked
		
		var achievement = ACHIEVEMENTS[achievement_id]
		var condition = achievement["condition"]
		var target = achievement["target"]
		
		var current_value = progress.get(condition, 0)
		
		if current_value >= target:
			_unlock_achievement(achievement_id)

## Unlock an achievement and grant reward
func _unlock_achievement(achievement_id: String) -> void:
	if achievement_id in unlocked_achievements:
		return
	
	unlocked_achievements.append(achievement_id)
	_save_data()
	
	var achievement = ACHIEVEMENTS[achievement_id]
	print("Achievement unlocked: ", achievement["name"])
	
	# Grant reward
	var reward_type = achievement["reward_type"]
	var reward_value = achievement["reward_value"]
	
	if reward_type == "unlock":
		GameManager.unlock_item(reward_value)
	elif reward_type == "xp":
		# XP is just for display, could be used for leveling
		pass
	
	achievement_unlocked.emit(achievement_id)
	reward_granted.emit(reward_type, reward_value)

## Called when a block is placed
func on_block_placed(is_perfect: bool, combo: int, in_wind: bool, at_max_speed: bool) -> void:
	progress["blocks_placed"] += 1
	session_perfects += 1 if is_perfect else 0
	progress["game_perfects"] = max(progress["game_perfects"], session_perfects)
	
	if is_perfect:
		progress["perfect_streak"] = max(progress["perfect_streak"], combo)
	
	progress["max_combo"] = max(progress["max_combo"], combo)
	
	if in_wind:
		session_wind_blocks += 1
		progress["wind_blocks"] = max(progress["wind_blocks"], session_wind_blocks)
	
	if at_max_speed:
		session_max_speed_blocks += 1
		progress["max_speed_blocks"] = max(progress["max_speed_blocks"], session_max_speed_blocks)
	
	_check_achievements()
	_save_data()

## Called when a game ends
func on_game_end() -> void:
	progress["total_games"] += 1
	session_perfects = 0
	session_combo = 0
	session_wind_blocks = 0
	session_max_speed_blocks = 0
	_check_achievements()
	_save_data()

## Start a new game session
func start_session() -> void:
	session_perfects = 0
	session_combo = 0
	session_wind_blocks = 0
	session_max_speed_blocks = 0

## Get achievement data for display
func get_achievement_data(achievement_id: String) -> Dictionary:
	if achievement_id in ACHIEVEMENTS:
		var data = ACHIEVEMENTS[achievement_id].duplicate()
		data["unlocked"] = achievement_id in unlocked_achievements
		data["progress"] = progress.get(data["condition"], 0)
		return data
	return {}

## Get all achievements for display
func get_all_achievements() -> Array:
	var result = []
	for achievement_id in ACHIEVEMENTS:
		var data = get_achievement_data(achievement_id)
		data["id"] = achievement_id
		result.append(data)
	return result

## Check if an achievement is unlocked
func is_unlocked(achievement_id: String) -> bool:
	return achievement_id in unlocked_achievements

## Get unlock count
func get_unlock_count() -> int:
	return len(unlocked_achievements)

## Get total achievement count
func get_total_count() -> int:
	return len(ACHIEVEMENTS)

## Save data
func _save_data() -> void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"unlocked": unlocked_achievements,
			"progress": progress
		}
		save_file.store_var(save_data)
		save_file.close()

## Load data
func _load_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			save_file.close()
			if save_data is Dictionary:
				unlocked_achievements = save_data.get("unlocked", [])
				var loaded_progress = save_data.get("progress", {})
				for key in loaded_progress:
					progress[key] = loaded_progress[key]
