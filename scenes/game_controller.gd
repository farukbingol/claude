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
@onready var wind_indicator: Label = $UI/WindIndicator

# Game settings
var screen_width: float = 1080.0
var screen_height: float = 1920.0

# Block settings
var block_spawn_y: float = 400.0
var base_block_y: float = 1700.0
var block_height: float = GameConfig.BASE_BLOCK_HEIGHT

# Current block reference
var current_block: Node2D = null
var placed_blocks: Array = []

# Screen shake
var shake_intensity: float = 0.0
var original_camera_pos: Vector2 = Vector2.ZERO

# Background gradient
var gradient_texture: GradientTexture2D

# Camera tracking
var camera_offset_y: float = 0.0
var target_camera_offset_y: float = 0.0

# Boss UI elements (created dynamically)
var boss_label: Label = null
var diamond_label: Label = null
var dev_mode_label: Label = null

# Earthquake effect
var earthquake_time: float = 0.0

# Ghost effect for current block
var ghost_blink_timer: float = 0.0

func _ready() -> void:
	_setup_game()
	_setup_gradient_background()
	_setup_boss_ui()
	_update_ui()
	
	# Connect signals
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.high_score_changed.connect(_on_high_score_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.combo_achieved.connect(_on_combo_achieved)
	GameManager.perfect_placement.connect(_on_perfect_placement)
	GameManager.speed_increased.connect(_on_speed_increased)
	
	# Connect boss signals
	BossManager.boss_started.connect(_on_boss_started)
	BossManager.boss_defeated.connect(_on_boss_defeated)
	DiamondManager.diamonds_changed.connect(_on_diamonds_changed)
	
	# Setup pause menu
	_setup_pause_menu()
	
	# Show banner ad
	if not IAPManager.is_no_ads_purchased():
		AdManager.show_banner()
	else:
		banner_placeholder.visible = false
	
	# Start the game
	GameManager.start_game()
	AchievementManager.start_session()
	_spawn_first_block()
	
	# Update speed indicator
	_update_speed_indicator()
	_update_diamond_display()

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
		GameConfig.BG_COLORS[min(4, len(GameConfig.BG_COLORS) - 1)]
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
	texture_rect.name = "GradientBackground"
	add_child(texture_rect)
	
	# Hide the original background
	background.visible = false

func _setup_pause_menu() -> void:
	# Hide pause menu initially
	if pause_menu:
		pause_menu.visible = false

func _setup_boss_ui() -> void:
	# Create boss label
	boss_label = Label.new()
	boss_label.name = "BossLabel"
	boss_label.text = ""
	boss_label.visible = false
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boss_label.add_theme_font_size_override("font_size", 36)
	boss_label.position = Vector2(screen_width / 2 - 150, 150)
	boss_label.size = Vector2(300, 50)
	$UI.add_child(boss_label)
	
	# Create diamond label
	diamond_label = Label.new()
	diamond_label.name = "DiamondLabel"
	diamond_label.text = "💎 0"
	diamond_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	diamond_label.add_theme_font_size_override("font_size", 24)
	diamond_label.position = Vector2(screen_width - 150, 60)
	diamond_label.size = Vector2(130, 40)
	$UI.add_child(diamond_label)
	
	# Create dev mode label if active
	if DiamondManager.is_dev_mode_active():
		_show_dev_mode_label()

func _update_ui() -> void:
	score_label.text = "SCORE: " + ScoreManager.get_score_text()
	high_score_label.text = "BEST: " + ScoreManager.get_high_score_text()

func _update_speed_indicator() -> void:
	if speed_indicator:
		var speed_percent = int((GameManager.current_block_speed / GameManager.max_block_speed) * 100)
		speed_indicator.text = "SPEED: " + str(speed_percent) + "%"
		# Change color based on speed (from gray to red at max speed)
		var color_factor = clamp((GameManager.current_block_speed - GameManager.base_block_speed) / (GameManager.max_block_speed - GameManager.base_block_speed), 0.0, 1.0)
		speed_indicator.modulate = Color(1.0, 1.0 - color_factor * 0.6, 1.0 - color_factor * 0.7)

func _update_wind_indicator() -> void:
	if wind_indicator:
		var block_count = len(placed_blocks)
		if block_count >= GameConfig.WIND_START_BLOCKS:
			wind_indicator.visible = true
			var wind_progress = min(float(block_count - GameConfig.WIND_START_BLOCKS) / GameConfig.WIND_RAMP_BLOCKS, 1.0)
			var wave_count = 1 + int(wind_progress * 4)  # 1-5 waves
			var waves = "~".repeat(wave_count)
			wind_indicator.text = "WIND: " + waves
		else:
			wind_indicator.visible = false

func _update_diamond_display() -> void:
	if diamond_label:
		diamond_label.text = "💎 " + str(DiamondManager.get_diamonds())

func _show_dev_mode_label() -> void:
	if dev_mode_label == null:
		dev_mode_label = Label.new()
		dev_mode_label.name = "DevModeLabel"
		dev_mode_label.text = "🔧 DEV MODE"
		dev_mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dev_mode_label.add_theme_font_size_override("font_size", 20)
		dev_mode_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))
		dev_mode_label.position = Vector2(screen_width / 2 - 75, 100)
		dev_mode_label.size = Vector2(150, 30)
		$UI.add_child(dev_mode_label)

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
	# Check for boss spawn
	var block_count = len(placed_blocks)
	BossManager.check_boss_spawn(block_count)
	
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
	
	# Apply boss color tint if active
	if BossManager.is_boss_active():
		var boss_color = BossManager.get_boss_color(BossManager.get_current_boss())
		block_color = block_color.lerp(boss_color, 0.3)
	
	# Calculate speed and width with chaos effect
	var speed = GameManager.current_block_speed
	var width = GameManager.current_block_width
	
	if BossManager.is_chaos_active():
		speed *= BossManager.get_chaos_speed_multiplier()
		width *= BossManager.get_chaos_size_multiplier()
	
	# Initialize block
	block_scene.set_screen_width(screen_width)
	block_scene.initialize(
		width,
		block_height,
		speed,
		block_color,
		start_from_left
	)
	
	# Apply wind if we're above the wind threshold OR wind boss is active
	if block_count >= GameConfig.WIND_START_BLOCKS or BossManager.get_current_boss() == "wind":
		var wind_progress = min(float(block_count - GameConfig.WIND_START_BLOCKS) / GameConfig.WIND_RAMP_BLOCKS, 1.0)
		var wind_strength = GameConfig.WIND_BASE_STRENGTH + wind_progress * (GameConfig.WIND_MAX_STRENGTH - GameConfig.WIND_BASE_STRENGTH)
		
		# Boost wind during wind boss
		if BossManager.get_current_boss() == "wind":
			wind_strength *= 1.5
		
		block_scene.set_wind_strength(wind_strength)
	
	# Apply ice effect
	if BossManager.ice_effect_active:
		block_scene.set_ice_effect(true, BossManager.get_ice_slide_amount())
	
	# Apply ghost effect
	if BossManager.is_ghost_active():
		block_scene.set_ghost_effect(true, BossManager.get_ghost_blink_interval())
	
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
			blocks_container.position = Vector2(0, camera_offset_y)
		else:
			blocks_container.position = Vector2(
				randf_range(-shake_intensity, shake_intensity),
				camera_offset_y + randf_range(-shake_intensity, shake_intensity)
			)
	
	# Handle earthquake effect
	if BossManager.is_earthquake_active():
		earthquake_time += delta
		var sway = sin(earthquake_time * 8.0) * BossManager.get_earthquake_tower_sway()
		for block in placed_blocks:
			if is_instance_valid(block):
				block.rotation = deg_to_rad(sway * 0.5)
		
		# Continuous screen shake during earthquake
		if shake_intensity <= 0:
			shake_intensity = BossManager.get_earthquake_shake_intensity() * 0.3
	
	# Smooth camera follow - camera tracks block height 1:1
	if camera_offset_y != target_camera_offset_y:
		# Use a faster lerp for responsive camera tracking
		camera_offset_y = lerp(camera_offset_y, target_camera_offset_y, GameConfig.CAMERA_LERP_SPEED * delta)
		if abs(camera_offset_y - target_camera_offset_y) < 1.0:
			camera_offset_y = target_camera_offset_y
		blocks_container.position.y = camera_offset_y

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
	var is_perfect = overlap_amount < 5.0
	if is_perfect:
		GameManager.on_block_placed(0.0)
	else:
		GameManager.on_block_placed(overlap_amount)
	
	# Handle boss defeat if boss is active
	if BossManager.is_boss_active():
		BossManager.on_block_placed_during_boss()
	
	# Notify achievement manager
	var block_count = len(placed_blocks)
	var in_wind = block_count >= GameConfig.WIND_START_BLOCKS
	var at_max_speed = GameManager.current_block_speed >= GameManager.max_block_speed * 0.95
	AchievementManager.on_block_placed(is_perfect, GameManager.current_combo, in_wind, at_max_speed)
	
	# Move camera up (improved camera follow)
	_scroll_view()
	
	# Update background gradient based on height
	_update_background_gradient()
	
	# Update wind indicator
	_update_wind_indicator()
	
	# Spawn next block
	if GameManager.is_playing():
		current_block = null
		await get_tree().create_timer(GameConfig.BLOCK_SPAWN_DELAY).timeout
		if GameManager.is_playing():
			_spawn_block()

func _on_block_dropped() -> void:
	# Block completely missed - GAME OVER
	AchievementManager.on_game_end()
	GameManager.end_game()

func _scroll_view() -> void:
	var block_count = len(placed_blocks)
	
	# Camera only starts scrolling after threshold
	if block_count <= GameConfig.CAMERA_SCROLL_START_BLOCK:
		target_camera_offset_y = 0.0
		return
	
	# For each new block, scroll up by exactly one block height
	var blocks_to_scroll = block_count - GameConfig.CAMERA_SCROLL_START_BLOCK
	target_camera_offset_y = blocks_to_scroll * block_height
	
	# Clean up old blocks when tower is very tall
	if block_count > GameConfig.BLOCK_CLEANUP_THRESHOLD:
		var visible_bottom = base_block_y + camera_offset_y + screen_height
		for i in range(len(placed_blocks) - 1, -1, -1):
			var block = placed_blocks[i]
			if is_instance_valid(block) and block.position.y > visible_bottom + 500:
				if i < len(placed_blocks) - GameConfig.MIN_VISIBLE_BLOCKS:
					block.queue_free()
					placed_blocks.remove_at(i)

func _update_background_gradient() -> void:
	# Update gradient colors based on tower height and atmospheric zones
	var block_count = len(placed_blocks)
	var max_colors = len(GameConfig.BG_COLORS)
	
	# Calculate which zone we're in based on block count
	var zone_progress: float = 0.0
	var base_index: int = 0
	
	if block_count < GameConfig.BG_ZONE_CITY:
		# Zone 1: City (0-30 blocks) - colors 0-3
		zone_progress = float(block_count) / GameConfig.BG_ZONE_CITY
		base_index = int(zone_progress * 2)  # Transition through first 3 colors
	elif block_count < GameConfig.BG_ZONE_CLOUDS:
		# Zone 2: Clouds (30-60 blocks) - colors 4-6
		zone_progress = float(block_count - GameConfig.BG_ZONE_CITY) / (GameConfig.BG_ZONE_CLOUDS - GameConfig.BG_ZONE_CITY)
		base_index = 3 + int(zone_progress * 2)
	elif block_count < GameConfig.BG_ZONE_ATMOSPHERE:
		# Zone 3: High Atmosphere (60-100 blocks) - colors 7-9
		zone_progress = float(block_count - GameConfig.BG_ZONE_CLOUDS) / (GameConfig.BG_ZONE_ATMOSPHERE - GameConfig.BG_ZONE_CLOUDS)
		base_index = 6 + int(zone_progress * 2)
	else:
		# Zone 4: Space (100+ blocks) - colors 9-11
		zone_progress = min(float(block_count - GameConfig.BG_ZONE_ATMOSPHERE) / 50.0, 1.0)
		base_index = 9 + int(zone_progress * 2)
	
	# Clamp base_index to valid range
	base_index = clampi(base_index, 0, max_colors - 5)
	
	if gradient_texture and gradient_texture.gradient:
		var gradient = gradient_texture.gradient
		gradient.colors[0] = GameConfig.BG_COLORS[base_index]
		gradient.colors[1] = GameConfig.BG_COLORS[min(base_index + 1, max_colors - 1)]
		gradient.colors[2] = GameConfig.BG_COLORS[min(base_index + 2, max_colors - 1)]
		gradient.colors[3] = GameConfig.BG_COLORS[min(base_index + 3, max_colors - 1)]
		gradient.colors[4] = GameConfig.BG_COLORS[min(base_index + 4, max_colors - 1)]

func _on_perfect_placement() -> void:
	_show_perfect_text()
	# Add glow effect
	_add_glow_effect()
	# Add small screen shake for perfect
	_trigger_screen_shake_light()
	# Add haptic feedback
	_trigger_haptic()
	# Spawn particles
	_spawn_perfect_particles()

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
	_trigger_haptic()
	_spawn_combo_particles(combo_count)

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

func _trigger_screen_shake_light() -> void:
	shake_intensity = GameConfig.SCREEN_SHAKE_INTENSITY * 0.3

func _trigger_haptic() -> void:
	# Trigger haptic feedback on mobile devices
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(50)  # 50ms vibration

func _spawn_perfect_particles() -> void:
	# Create confetti-like particles for perfect placement
	if len(placed_blocks) > 0:
		var last_block = placed_blocks[-1]
		if is_instance_valid(last_block):
			_create_particles_at(last_block.position, Color.GOLD)

func _spawn_combo_particles(combo_count: int) -> void:
	# Create more particles for higher combos
	if len(placed_blocks) > 0:
		var last_block = placed_blocks[-1]
		if is_instance_valid(last_block):
			var colors = [Color.ORANGE, Color.RED, Color.MAGENTA]
			var color_index = min(combo_count - 2, len(colors) - 1)
			_create_particles_at(last_block.position, colors[color_index])

func _create_particles_at(pos: Vector2, color: Color) -> void:
	var particles = CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.amount = 20
	particles.lifetime = 0.8
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.gravity = Vector2(0, 400)
	particles.initial_velocity_min = 200.0
	particles.initial_velocity_max = 400.0
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0
	particles.color = color
	add_child(particles)
	
	# Auto-free after particles finish
	await get_tree().create_timer(1.5).timeout
	if is_instance_valid(particles):
		particles.queue_free()

# Boss event handlers
func _on_boss_started(boss_type: String, level: int) -> void:
	if boss_label:
		boss_label.text = BossManager.get_boss_display_name(boss_type)
		boss_label.add_theme_color_override("font_color", BossManager.get_boss_color(boss_type))
		boss_label.visible = true
		
		# Animate boss label
		boss_label.scale = Vector2(2.0, 2.0)
		boss_label.modulate.a = 0.0
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(boss_label, "scale", Vector2(1.0, 1.0), 0.5)
		tween.tween_property(boss_label, "modulate:a", 1.0, 0.3)
	
	# Trigger screen shake for boss arrival
	shake_intensity = GameConfig.SCREEN_SHAKE_INTENSITY * 2.0
	_trigger_haptic()

func _on_boss_defeated(boss_type: String, reward: int) -> void:
	if boss_label:
		# Show victory message
		boss_label.text = "BOSS DEFEATED! +" + str(reward) + " 💎"
		boss_label.add_theme_color_override("font_color", Color.GOLD)
		
		# Animate and hide
		var tween = create_tween()
		tween.tween_property(boss_label, "scale", Vector2(1.5, 1.5), 0.3)
		tween.tween_property(boss_label, "modulate:a", 0.0, 0.5)
		tween.tween_callback(func(): 
			boss_label.visible = false
			boss_label.scale = Vector2(1.0, 1.0)
		)
	
	# Spawn celebration particles
	_spawn_boss_victory_particles()
	_trigger_screen_shake()
	_trigger_haptic()
	_update_diamond_display()

func _on_diamonds_changed(new_amount: int) -> void:
	_update_diamond_display()

func _spawn_boss_victory_particles() -> void:
	# Create extra particles for boss victory
	if len(placed_blocks) > 0:
		var last_block = placed_blocks[-1]
		if is_instance_valid(last_block):
			# Spawn multiple particle bursts
			for i in range(3):
				var offset = Vector2(randf_range(-100, 100), randf_range(-50, 50))
				_create_particles_at(last_block.position + offset, Color.GOLD)
