extends Node2D

## GameController - Main game scene controller
## Handles block spawning, game flow, and UI updates

const Block = preload("res://scripts/block.gd")

@onready var blocks_container: Node2D = $BlocksContainer
@onready var background: ColorRect = $Background
@onready var score_label: Label = $UI/TopBar/ScoreLabel
@onready var high_score_label: Label = $UI/TopBar/HighScoreLabel
@onready var perfect_label: Label = $UI/PerfectLabel
@onready var tap_hint: Label = $UI/TapHint
@onready var banner_placeholder: ColorRect = $UI/BannerPlaceholder

# Game settings
var screen_width: float = 1080.0
var screen_height: float = 1920.0

# Block settings
var block_spawn_y: float = 400.0
var base_block_y: float = 1700.0
var block_height: float = 50.0

# Current block reference
var current_block: Node2D = null
var placed_blocks: Array = []

# Block colors (rainbow gradient)
var block_colors: Array[Color] = [
	Color(0.9, 0.3, 0.3),   # Red
	Color(0.9, 0.6, 0.3),   # Orange
	Color(0.9, 0.9, 0.3),   # Yellow
	Color(0.3, 0.9, 0.3),   # Green
	Color(0.3, 0.9, 0.9),   # Cyan
	Color(0.3, 0.3, 0.9),   # Blue
	Color(0.6, 0.3, 0.9),   # Purple
	Color(0.9, 0.3, 0.6),   # Pink
]

func _ready() -> void:
	_setup_game()
	_update_ui()
	
	# Connect signals
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.high_score_changed.connect(_on_high_score_changed)
	GameManager.game_over.connect(_on_game_over)
	
	# Show banner ad
	if not IAPManager.is_no_ads_purchased():
		AdManager.show_banner()
	else:
		banner_placeholder.visible = false
	
	# Start the game
	GameManager.start_game()
	_spawn_first_block()

func _setup_game() -> void:
	# Get screen dimensions
	var viewport_size = get_viewport().get_visible_rect().size
	screen_width = viewport_size.x
	screen_height = viewport_size.y
	
	# Resize background to fill the entire screen
	background.size = Vector2(screen_width, screen_height)
	background.position = Vector2.ZERO
	
	# Adjust base block position
	base_block_y = screen_height - 220.0
	block_spawn_y = 400.0

func _update_ui() -> void:
	score_label.text = "SCORE: " + ScoreManager.get_score_text()
	high_score_label.text = "BEST: " + ScoreManager.get_high_score_text()

func _spawn_first_block() -> void:
	# Create base platform as a Block (so it can be used as previous_block reference)
	var base_block = Node2D.new()
	base_block.set_script(Block)
	blocks_container.add_child(base_block)
	
	# Position at center bottom
	base_block.position = Vector2(screen_width / 2, base_block_y)
	
	# Initialize as a static block
	base_block.set_screen_width(screen_width)
	base_block.initialize(
		GameManager.base_block_width,
		block_height,
		0.0,  # No movement speed
		Color(0.4, 0.4, 0.5),
		true
	)
	
	# Set as placed immediately (static base)
	base_block.place_immediately()
	
	# Add to placed blocks so next block can use it as reference
	placed_blocks.append(base_block)
	
	# Spawn first moving block
	_spawn_block()

func _spawn_block() -> void:
	# Create new block
	var block_scene = Node2D.new()
	block_scene.set_script(Block)
	blocks_container.add_child(block_scene)
	
	# Calculate spawn position - block starts at center top and moves horizontally
	var spawn_y = _get_next_block_y()
	var spawn_x = screen_width / 2  # Start at center
	var start_from_left = len(placed_blocks) % 2 == 0  # Alternate initial direction
	
	block_scene.position = Vector2(spawn_x, spawn_y)
	
	# Get color based on block count (subtract 1 because base block is in placed_blocks)
	var color_index = (len(placed_blocks) - 1) % len(block_colors)
	var block_color = block_colors[color_index]
	
	# Initialize block
	block_scene.set_screen_width(screen_width)
	block_scene.initialize(
		GameManager.current_block_width,
		block_height,
		GameManager.current_block_speed,
		block_color,
		start_from_left
	)
	
	# Set reference to previous block
	if len(placed_blocks) > 0:
		block_scene.set_previous_block(placed_blocks[-1])
	
	# Connect signals
	block_scene.block_placed.connect(_on_block_placed)
	block_scene.block_dropped.connect(_on_block_dropped)
	
	current_block = block_scene
	tap_hint.visible = true

func _get_next_block_y() -> float:
	# Move camera up as tower grows
	var base_y = base_block_y - (len(placed_blocks) * block_height)
	return min(base_y, block_spawn_y)

func _input(event: InputEvent) -> void:
	if not GameManager.is_playing():
		return
	
	# Handle touch/click
	if event is InputEventScreenTouch and event.pressed:
		_drop_current_block()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_drop_current_block()

func _drop_current_block() -> void:
	if current_block == null:
		return
	
	tap_hint.visible = false
	current_block.drop_block()

func _on_block_placed(overlap_amount: float) -> void:
	# Add to placed blocks
	placed_blocks.append(current_block)
	
	# Check for perfect placement
	if overlap_amount < 5.0:
		_show_perfect_text()
		GameManager.on_block_placed(0.0)
	else:
		GameManager.on_block_placed(overlap_amount)
	
	# Move camera up
	_scroll_view()
	
	# Spawn next block
	if GameManager.is_playing():
		current_block = null
		await get_tree().create_timer(0.3).timeout
		if GameManager.is_playing():
			_spawn_block()

func _on_block_dropped() -> void:
	# Block completely missed
	GameManager.end_game()

func _scroll_view() -> void:
	# Scroll all blocks down to keep the active area visible
	if len(placed_blocks) > 10:
		var scroll_amount = block_height
		for block in placed_blocks:
			if is_instance_valid(block):
				block.position.y += scroll_amount
		
		# Also scroll base platform and any other elements
		for child in blocks_container.get_children():
			if child is ColorRect:
				child.position.y += scroll_amount

func _show_perfect_text() -> void:
	perfect_label.visible = true
	perfect_label.modulate.a = 1.0
	
	var tween = create_tween()
	tween.tween_property(perfect_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func(): perfect_label.visible = false)

func _on_score_changed(new_score: int) -> void:
	score_label.text = "SCORE: " + str(new_score)

func _on_high_score_changed(new_high_score: int) -> void:
	high_score_label.text = "BEST: " + str(new_high_score)

func _on_game_over() -> void:
	# Hide banner
	AdManager.hide_banner()
	
	# Wait a moment then show game over screen
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
