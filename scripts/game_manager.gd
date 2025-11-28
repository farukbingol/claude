extends Node

## GameManager - Central game state management
## Handles game flow, difficulty, and block management

signal game_started
signal game_over
signal block_placed(is_perfect: bool)
signal speed_increased(new_speed: float)
signal combo_achieved(combo_count: int)
signal perfect_placement

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

func _ready() -> void:
	# Initialize from GameConfig
	base_block_speed = GameConfig.BASE_BLOCK_SPEED
	max_block_speed = GameConfig.MAX_BLOCK_SPEED
	base_block_width = GameConfig.BASE_BLOCK_WIDTH
	base_block_height = GameConfig.BASE_BLOCK_HEIGHT
	min_block_width = GameConfig.MIN_BLOCK_WIDTH
	perfect_threshold = GameConfig.PERFECT_THRESHOLD
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
	
	# Check if perfect placement
	var is_perfect = abs(overlap_amount) <= perfect_threshold
	
	if is_perfect:
		perfect_count += 1
		current_combo += 1
		
		if current_combo > max_combo:
			max_combo = current_combo
		
		# Calculate combo multiplier
		var multiplier = 1.0
		if current_combo >= 2:
			multiplier = GameConfig.COMBO_BASE_MULTIPLIER + (current_combo - 2) * GameConfig.COMBO_INCREMENT
		
		var points = int(GameConfig.PERFECT_BONUS * multiplier)
		ScoreManager.add_score(points, true)
		
		perfect_placement.emit()
		
		if current_combo >= 2:
			combo_achieved.emit(current_combo)
		
		print("Perfect placement! Combo: ", current_combo, " Points: ", points)
	else:
		# Break combo on non-perfect placement
		current_combo = 0
		ScoreManager.add_score(GameConfig.NORMAL_SCORE, false)
		
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
