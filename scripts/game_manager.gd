extends Node

## GameManager - Central game state management
## Handles game flow, difficulty, block management, and player data

signal game_started
signal game_over
signal block_placed(is_perfect: bool)
signal speed_increased(new_speed: float)
signal combo_achieved(combo_count: int)
signal perfect_placement
signal item_unlocked(item_id: String)

# Game states
enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

# Current game state
var current_state: GameState = GameState.MENU

# Game settings (initialized from GameConfig)
var base_block_speed: float = 300.0
var current_block_speed: float = 300.0
var max_block_speed: float = 800.0

# Block settings
var base_block_width: float = 200.0
var base_block_height: float = 50.0
var current_block_width: float = 200.0
var min_block_width: float = 20.0

# Perfect placement threshold (in pixels)
var perfect_threshold: float = 5.0

# Current block count
var block_count: int = 0

# Combo tracking
var current_combo: int = 0
var max_combo: int = 0
var perfect_count: int = 0

# Continue available (from rewarded ad)
var continue_available: bool = true

# Player data
var coins: int = 0
var diamonds: int = 0
var unlocked_items: Array = ["endless"]  # Default mode unlocked
var selected_theme: String = "default"
var selected_mode: String = "endless"

# Available modes and themes
const MODES = ["endless", "zen", "time_attack", "precision", "speed_run"]
const THEMES = ["default", "neon_theme", "sakura_theme", "space_theme"]

# Save path for player data
const PLAYER_DATA_PATH: String = "user://player_data.save"

func _ready() -> void:
	# Initialize from GameConfig
	base_block_speed = GameConfig.BASE_BLOCK_SPEED
	max_block_speed = GameConfig.MAX_BLOCK_SPEED
	base_block_width = GameConfig.BASE_BLOCK_WIDTH
	base_block_height = GameConfig.BASE_BLOCK_HEIGHT
	min_block_width = GameConfig.MIN_BLOCK_WIDTH
	perfect_threshold = GameConfig.PERFECT_THRESHOLD
	_load_player_data()
	print("GameManager initialized")

## Start a new game
func start_game() -> void:
	current_state = GameState.PLAYING
	current_block_speed = base_block_speed
	current_block_width = base_block_width
	block_count = 0
	current_combo = 0
	max_combo = 0
	perfect_count = 0
	continue_available = true
	ScoreManager.reset_score()
	game_started.emit()
	print("Game started!")

## End the current game
func end_game() -> void:
	if current_state == GameState.GAME_OVER:
		return  # Already ended
	
	current_state = GameState.GAME_OVER
	ScoreManager.save_high_score()
	
	# Record stats
	StatsManager.record_game(block_count, perfect_count, max_combo)
	
	game_over.emit()
	print("Game over! Final score: ", ScoreManager.current_score)

## Called when a block is placed
func on_block_placed(overlap_amount: float) -> void:
	block_count += 1
	
	# Calculate speed multiplier for scoring (1.0 to 2.0 based on current speed)
	var speed_multiplier = 1.0 + (current_block_speed - base_block_speed) / (max_block_speed - base_block_speed)
	
	# Check if perfect placement
	var is_perfect = abs(overlap_amount) <= perfect_threshold
	
	if is_perfect:
		perfect_count += 1
		current_combo += 1
		
		if current_combo > max_combo:
			max_combo = current_combo
		
		# Calculate combo multiplier
		var multiplier = 1.0
		if current_combo >= GameConfig.COMBO_START_THRESHOLD:
			multiplier = GameConfig.COMBO_BASE_MULTIPLIER + (current_combo - GameConfig.COMBO_START_THRESHOLD) * GameConfig.COMBO_INCREMENT
		
		# Apply speed multiplier to points
		var points = int(GameConfig.PERFECT_BONUS * multiplier * speed_multiplier)
		ScoreManager.add_score(points, true)
		
		perfect_placement.emit()
		
		if current_combo >= GameConfig.COMBO_START_THRESHOLD:
			combo_achieved.emit(current_combo)
		
		print("Perfect placement! Combo: ", current_combo, " Speed mult: ", speed_multiplier, " Points: ", points)
	else:
		# Break combo on non-perfect placement
		current_combo = 0
		# Apply speed multiplier to normal score
		var points = int(GameConfig.NORMAL_SCORE * speed_multiplier)
		ScoreManager.add_score(points, false)
		
		# Reduce block width based on overhang
		current_block_width -= abs(overlap_amount)
	
	# Check if block is too small
	if current_block_width < min_block_width:
		end_game()
		return
	
	# Increase speed every N blocks
	if block_count % GameConfig.SPEED_INCREASE_INTERVAL == 0:
		increase_speed()
	
	block_placed.emit(is_perfect)

## Increase block movement speed
func increase_speed() -> void:
	var speed_increase = current_block_speed * GameConfig.SPEED_INCREASE_PERCENT
	current_block_speed = min(current_block_speed + speed_increase, max_block_speed)
	speed_increased.emit(current_block_speed)
	print("Speed increased to: ", current_block_speed)

## Continue game after watching rewarded ad
func continue_game() -> void:
	if continue_available:
		continue_available = false
		current_state = GameState.PLAYING
		# Give back some block width
		current_block_width = max(current_block_width, base_block_width * 0.5)
		print("Game continued!")

## Pause the game
func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true

## Resume the game
func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false

## Return to main menu
func go_to_menu() -> void:
	current_state = GameState.MENU
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")

## Check if game is currently playing
func is_playing() -> bool:
	return current_state == GameState.PLAYING

## Get current block dimensions
func get_current_block_size() -> Vector2:
	return Vector2(current_block_width, base_block_height)

## Get current game stats
func get_game_stats() -> Dictionary:
	return {
		"block_count": block_count,
		"perfect_count": perfect_count,
		"max_combo": max_combo,
		"current_combo": current_combo
	}

## Unlock an item (mode or theme)
func unlock_item(item_id: String) -> void:
	if item_id not in unlocked_items:
		unlocked_items.append(item_id)
		_save_player_data()
		item_unlocked.emit(item_id)
		print("Item unlocked: ", item_id)

## Check if an item is unlocked
func is_item_unlocked(item_id: String) -> bool:
	return item_id in unlocked_items

## Get all unlocked items
func get_unlocked_items() -> Array:
	return unlocked_items.duplicate()

## Add coins
func add_coins(amount: int) -> void:
	coins += amount
	_save_player_data()

## Add diamonds
func add_diamonds(amount: int) -> void:
	diamonds += amount
	_save_player_data()

## Spend coins (returns true if successful)
func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		_save_player_data()
		return true
	return false

## Spend diamonds (returns true if successful)
func spend_diamonds(amount: int) -> bool:
	if diamonds >= amount:
		diamonds -= amount
		_save_player_data()
		return true
	return false

## Set selected theme
func set_theme(theme_id: String) -> void:
	if theme_id in THEMES and is_item_unlocked(theme_id):
		selected_theme = theme_id
		_save_player_data()

## Set selected mode
func set_mode(mode_id: String) -> void:
	if mode_id in MODES and is_item_unlocked(mode_id):
		selected_mode = mode_id
		_save_player_data()

## Save player data
func _save_player_data() -> void:
	var save_file = FileAccess.open(PLAYER_DATA_PATH, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"coins": coins,
			"diamonds": diamonds,
			"unlocked_items": unlocked_items,
			"selected_theme": selected_theme,
			"selected_mode": selected_mode
		}
		save_file.store_var(save_data)
		save_file.close()

## Load player data
func _load_player_data() -> void:
	if FileAccess.file_exists(PLAYER_DATA_PATH):
		var save_file = FileAccess.open(PLAYER_DATA_PATH, FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			save_file.close()
			if save_data is Dictionary:
				coins = save_data.get("coins", 0)
				diamonds = save_data.get("diamonds", 0)
				unlocked_items = save_data.get("unlocked_items", ["endless"])
				selected_theme = save_data.get("selected_theme", "default")
				selected_mode = save_data.get("selected_mode", "endless")
