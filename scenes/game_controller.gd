extends Node2D

## GameController - Main game scene controller
## Handles block spawning, game flow, and UI updates

const Block = preload("res://scripts/block.gd")

@onready var blocks_container: Node2D = $BlocksContainer
@onready var background: ColorRect = $Background
@onready var score_label: Label = $UI/TopBar/ScoreLabel
@onready var high_score_label: Label = $UI/TopBar/HighScoreLabel
@onready var perfect_label: Label = $UI/PerfectLabel
@onready var combo_label: Label = $UI/ComboLabel
@onready var tap_hint: Label = $UI/TapHint
@onready var banner_placeholder: ColorRect = $UI/BannerPlaceholder
@onready var pause_button: Button = $UI/PauseButton
@onready var pause_menu: Control = $UI/PauseMenu
@onready var speed_indicator: Label = $UI/SpeedIndicator

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

# Screen shake
var shake_intensity: float = 0.0
var original_camera_pos: Vector2 = Vector2.ZERO

# Background gradient
var gradient_texture: GradientTexture2D

func _ready() -> void:
	_setup_game()
	_setup_gradient_background()
	_update_ui()
	
	# Connect signals
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.high_score_changed.connect(_on_high_score_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.combo_achieved.connect(_on_combo_achieved)
	GameManager.perfect_placement.connect(_on_perfect_placement)
	GameManager.speed_increased.connect(_on_speed_increased)
	
	# Setup pause menu
	_setup_pause_menu()
	
	# Show banner ad
	if not IAPManager.is_no_ads_purchased():
		AdManager.show_banner()
	else:
		banner_placeholder.visible = false
	
	# Start the game
	GameManager.start_game()
	_spawn_first_block()
	
	# Update speed indicator
	_update_speed_indicator()

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

func _setup_gradient_background() -> void:
	# Create gradient for sky background
	var gradient = Gradient.new()
	gradient.offsets = [0.0, 0.25, 0.5, 0.75, 1.0]
	gradient.colors = [
		GameConfig.BG_COLORS[0],
		GameConfig.BG_COLORS[1],
		GameConfig.BG_COLORS[2],
		GameConfig.BG_COLORS[3],
		GameConfig.BG_COLORS[4]
	]
	
	gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.width = int(screen_width)
	gradient_texture.height = int(screen_height)
	gradient_texture.fill = GradientTexture2D.FILL_LINEAR
	gradient_texture.fill_from = Vector2(0.5, 1.0)
	gradient_texture.fill_to = Vector2(0.5, 0.0)
	
	# Apply to background
	var texture_rect = TextureRect.new()
	texture_rect.texture = gradient_texture
	texture_rect.size = Vector2(screen_width, screen_height)
	texture_rect.position = Vector2.ZERO
	texture_rect.z_index = -1
	add_child(texture_rect)
	
	# Hide the original background
	background.visible = false

func _setup_pause_menu() -> void:
	# Hide pause menu initially
	if pause_menu:
		pause_menu.visible = false

func _update_ui() -> void:
	score_label.text = "SCORE: " + ScoreManager.get_score_text()
	high_score_label.text = "BEST: " + ScoreManager.get_high_score_text()

func _update_speed_indicator() -> void:
	if speed_indicator:
		var speed_percent = int((GameManager.current_block_speed / GameManager.max_block_speed) * 100)
		speed_indicator.text = "SPEED: " + str(speed_percent) + "%"

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
	var color_index = (len(placed_blocks) - 1) % len(GameConfig.BLOCK_COLORS)
	var block_color = GameConfig.BLOCK_COLORS[color_index]
	
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

func _process(delta: float) -> void:
	# Handle screen shake
	if shake_intensity > 0:
		shake_intensity -= delta * 30.0
		if shake_intensity <= 0:
			shake_intensity = 0
			blocks_container.position = Vector2.ZERO
		else:
			blocks_container.position = Vector2(
				randf_range(-shake_intensity, shake_intensity),
				randf_range(-shake_intensity, shake_intensity)
			)

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
		GameManager.on_block_placed(0.0)
	else:
		GameManager.on_block_placed(overlap_amount)
	
	# Move camera up
	_scroll_view()
	
	# Update background gradient based on height
	_update_background_gradient()
	
	# Spawn next block
	if GameManager.is_playing():
		current_block = null
		await get_tree().create_timer(GameConfig.BLOCK_SPAWN_DELAY).timeout
		if GameManager.is_playing():
			_spawn_block()

func _on_block_dropped() -> void:
	# Block completely missed - GAME OVER
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

func _update_background_gradient() -> void:
	# Update gradient colors based on tower height
	var height_factor = min(len(placed_blocks) / GameConfig.BG_GRADIENT_BLOCKS_FOR_FULL_CHANGE, 1.0)  # Full gradient change at configured blocks
	
	if gradient_texture and gradient_texture.gradient:
		var gradient = gradient_texture.gradient
		var base_index = int(height_factor * (len(GameConfig.BG_COLORS) - GameConfig.BG_GRADIENT_TRANSITION_RANGE - 1))  # Shift through color palette
		
		if base_index < len(GameConfig.BG_COLORS) - GameConfig.BG_GRADIENT_TRANSITION_RANGE:
			gradient.colors[0] = GameConfig.BG_COLORS[base_index]
			gradient.colors[1] = GameConfig.BG_COLORS[base_index + 1]
			gradient.colors[2] = GameConfig.BG_COLORS[base_index + 2]
			gradient.colors[3] = GameConfig.BG_COLORS[base_index + 3]
			if base_index + GameConfig.BG_GRADIENT_TRANSITION_RANGE < len(GameConfig.BG_COLORS):
				gradient.colors[4] = GameConfig.BG_COLORS[base_index + GameConfig.BG_GRADIENT_TRANSITION_RANGE]

func _on_perfect_placement() -> void:
	_show_perfect_text()
	# Add glow effect
	_add_glow_effect()

func _show_perfect_text() -> void:
	perfect_label.visible = true
	perfect_label.modulate.a = 1.0
	perfect_label.scale = Vector2(1.5, 1.5)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(perfect_label, "modulate:a", 0.0, GameConfig.PERFECT_TEXT_DURATION)
	tween.tween_property(perfect_label, "scale", Vector2(1.0, 1.0), 0.2)
	tween.chain().tween_callback(func(): perfect_label.visible = false)

func _on_combo_achieved(combo_count: int) -> void:
	_show_combo_text(combo_count)
	_trigger_screen_shake()
	AudioManager.play_combo()

func _show_combo_text(combo_count: int) -> void:
	if combo_label:
		combo_label.text = "COMBO x" + str(combo_count) + "!"
		combo_label.visible = true
		combo_label.modulate.a = 1.0
		combo_label.scale = Vector2(2.0, 2.0)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(combo_label, "modulate:a", 0.0, GameConfig.COMBO_TEXT_DURATION)
		tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.3)
		tween.chain().tween_callback(func(): combo_label.visible = false)

func _trigger_screen_shake() -> void:
	shake_intensity = GameConfig.SCREEN_SHAKE_INTENSITY

func _add_glow_effect() -> void:
	# Add a simple flash effect on the last placed block
	if len(placed_blocks) > 0:
		var last_block = placed_blocks[-1]
		if is_instance_valid(last_block):
			var original_modulate = last_block.modulate
			last_block.modulate = Color(1.5, 1.5, 1.5, 1.0)  # Bright flash
			var tween = create_tween()
			tween.tween_property(last_block, "modulate", original_modulate, 0.3)

func _on_speed_increased(new_speed: float) -> void:
	_update_speed_indicator()

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

func _on_pause_pressed() -> void:
	if pause_menu:
		pause_menu.visible = true
		GameManager.pause_game()

func _on_resume_pressed() -> void:
	if pause_menu:
		pause_menu.visible = false
		GameManager.resume_game()

func _on_pause_settings_pressed() -> void:
	# Could open settings overlay
	AudioManager.play_button_click()

func _on_pause_quit_pressed() -> void:
	if pause_menu:
		pause_menu.visible = false
	GameManager.go_to_menu()
