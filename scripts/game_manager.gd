extends Node

## GameManager - Central game state management
## Handles game flow, difficulty, and block management

signal game_started
signal game_over
signal block_placed(is_perfect: bool)
signal speed_increased(new_speed: float)

# Game states
enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

# Current game state
var current_state: GameState = GameState.MENU

# Game settings
var base_block_speed: float = 300.0
var current_block_speed: float = 300.0
var speed_increase_per_block: float = 5.0
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

# Continue available (from rewarded ad)
var continue_available: bool = true

func _ready() -> void:
	print("GameManager initialized")

## Start a new game
func start_game() -> void:
	current_state = GameState.PLAYING
	current_block_speed = base_block_speed
	current_block_width = base_block_width
	block_count = 0
	continue_available = true
	ScoreManager.reset_score()
	game_started.emit()
	print("Game started!")

## End the current game
func end_game() -> void:
	current_state = GameState.GAME_OVER
	ScoreManager.save_high_score()
	game_over.emit()
	print("Game over! Final score: ", ScoreManager.current_score)

## Called when a block is placed
func on_block_placed(overlap_amount: float) -> void:
	block_count += 1
	
	# Check if perfect placement
	var is_perfect = abs(overlap_amount) <= perfect_threshold
	
	if is_perfect:
		ScoreManager.add_score(100)  # Perfect bonus
		print("Perfect placement! +100 bonus")
	else:
		ScoreManager.add_score(10)
		# Reduce block width based on overhang
		current_block_width -= abs(overlap_amount)
	
	# Check if block is too small
	if current_block_width < min_block_width:
		end_game()
		return
	
	# Increase speed
	increase_speed()
	
	block_placed.emit(is_perfect)

## Increase block movement speed
func increase_speed() -> void:
	current_block_speed = min(current_block_speed + speed_increase_per_block, max_block_speed)
	speed_increased.emit(current_block_speed)

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
