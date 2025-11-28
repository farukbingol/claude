extends Node2D
class_name Block

## Block - Individual block that moves and can be placed

signal block_dropped
signal block_placed(overlap_amount: float)

# Block state
enum BlockState { MOVING, FALLING, PLACED }
var current_state: BlockState = BlockState.MOVING

# Movement
var move_direction: int = 1  # 1 = right, -1 = left
var move_speed: float = 300.0
var screen_width: float = 1080.0

# Block dimensions
var block_width: float = 200.0
var block_height: float = 50.0

# Colors
var block_color: Color = Color(0.2, 0.6, 0.9)
var placed_block_color: Color = Color(0.3, 0.5, 0.7)

# Physics for falling
var velocity: Vector2 = Vector2.ZERO
var gravity: float = 1500.0

# Reference to previous block for overlap calculation
var previous_block: Block = null
var target_y: float = 0.0  # Y position where block should land
var has_checked_landing: bool = false  # Flag to check landing once

# Visual components
var color_rect: ColorRect

func _ready() -> void:
	# Initialize gravity from config
	gravity = GameConfig.BLOCK_GRAVITY
	_setup_visuals()

## Setup visual representation
func _setup_visuals() -> void:
	color_rect = ColorRect.new()
	color_rect.size = Vector2(block_width, block_height)
	color_rect.position = Vector2(-block_width / 2, -block_height / 2)
	color_rect.color = block_color
	add_child(color_rect)

## Initialize block with parameters
func initialize(width: float, height: float, speed: float, color: Color, start_from_left: bool = true) -> void:
	block_width = width
	block_height = height
	move_speed = speed
	block_color = color
	placed_block_color = color.darkened(0.2)
	
	# Set initial direction based on starting position
	move_direction = 1 if start_from_left else -1
	
	# Update visual
	if color_rect:
		color_rect.size = Vector2(block_width, block_height)
		color_rect.position = Vector2(-block_width / 2, -block_height / 2)
		color_rect.color = block_color

## Set previous block for overlap calculation
func set_previous_block(block: Block) -> void:
	previous_block = block

func _process(delta: float) -> void:
	match current_state:
		BlockState.MOVING:
			_handle_movement(delta)
		BlockState.FALLING:
			_handle_falling(delta)
		BlockState.PLACED:
			pass  # Do nothing when placed

## Handle horizontal movement
func _handle_movement(delta: float) -> void:
	position.x += move_direction * move_speed * delta
	
	# Bounce off screen edges
	var half_width = block_width / 2
	if position.x + half_width >= screen_width:
		position.x = screen_width - half_width
		move_direction = -1
	elif position.x - half_width <= 0:
		position.x = half_width
		move_direction = 1

## Handle falling physics
func _handle_falling(delta: float) -> void:
	velocity.y += gravity * delta
	position.y += velocity.y * delta
	
	# Check if reached target landing position
	if previous_block != null and not has_checked_landing:
		if position.y >= target_y:
			position.y = target_y
			has_checked_landing = true
			_check_landing()
			return
	
	# Check if off screen (complete miss with no previous block or after landing check)
	if position.y > GameConfig.BLOCK_FALL_OFF_Y:
		block_dropped.emit()
		queue_free()

## Check landing and handle placement or miss
func _check_landing() -> void:
	var overlap = _calculate_overlap()
	
	if overlap <= 0:
		# Complete miss - emit game over signal and fall off screen
		AudioManager.play_block_drop()
		block_dropped.emit()
		queue_free()
		return
	
	# Block will be placed
	var overhang = _calculate_overhang()
	_handle_placement(overhang)

## Drop and place the block
func drop_block() -> void:
	if current_state != BlockState.MOVING:
		return
	
	current_state = BlockState.FALLING
	velocity = Vector2.ZERO
	has_checked_landing = false
	
	# Calculate target Y position (where the block should land)
	if previous_block != null:
		# Land on top of previous block
		target_y = previous_block.position.y - block_height
	else:
		# No previous block - this shouldn't happen with new logic
		# but handle it by placing immediately
		_place_block()
		AudioManager.play_block_place()
		block_placed.emit(0.0)

## Calculate overlap amount with previous block
func _calculate_overlap() -> float:
	if previous_block == null:
		return block_width
	
	var my_left = position.x - block_width / 2
	var my_right = position.x + block_width / 2
	var prev_left = previous_block.position.x - previous_block.block_width / 2
	var prev_right = previous_block.position.x + previous_block.block_width / 2
	
	var overlap_left = max(my_left, prev_left)
	var overlap_right = min(my_right, prev_right)
	
	return overlap_right - overlap_left

## Calculate overhang amount (positive = overhanging right, negative = overhanging left)
func _calculate_overhang() -> float:
	if previous_block == null:
		return 0.0
	
	return position.x - previous_block.position.x

## Handle block placement and slicing
func _handle_placement(overhang: float) -> void:
	var abs_overhang = abs(overhang)
	
	if abs_overhang < GameConfig.PERFECT_THRESHOLD:  # Perfect placement threshold
		# Perfect placement - snap to center
		position.x = previous_block.position.x
		_place_block()
		AudioManager.play_perfect()
		block_placed.emit(0.0)
	else:
		# Calculate new width after slicing
		var new_width = block_width - abs_overhang
		
		if new_width <= 0:
			# Complete miss - emit game over signal
			AudioManager.play_block_drop()
			block_dropped.emit()
			queue_free()
			return
		
		# Slice the block - create falling piece
		_create_falling_piece(overhang)
		
		# Update this block's width and position
		var old_center = position.x
		if overhang > 0:
			# Overhanging to the right - move center left
			position.x = old_center - abs_overhang / 2
		else:
			# Overhanging to the left - move center right
			position.x = old_center + abs_overhang / 2
		
		block_width = new_width
		color_rect.size.x = block_width
		color_rect.position.x = -block_width / 2
		
		_place_block()
		AudioManager.play_block_place()
		block_placed.emit(abs_overhang)

## Create a falling piece for the overhang
func _create_falling_piece(overhang: float) -> void:
	var falling_piece = ColorRect.new()
	var piece_width = abs(overhang)
	falling_piece.size = Vector2(piece_width, block_height)
	falling_piece.color = block_color.darkened(0.3)
	
	# Position the falling piece - calculate offset from center
	var half_remaining = (block_width - piece_width) / 2
	var piece_x: float
	if overhang > 0:
		piece_x = position.x + half_remaining
	else:
		piece_x = position.x - half_remaining
	
	# Add to parent and animate falling
	var falling_node = Node2D.new()
	falling_node.position = Vector2(piece_x, position.y)
	falling_piece.position = Vector2(-piece_width / 2, -block_height / 2)
	falling_node.add_child(falling_piece)
	get_parent().add_child(falling_node)
	
	# Create simple falling animation with fade out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(falling_node, "position:y", position.y + 1500, 1.5)
	tween.tween_property(falling_node, "rotation", overhang * GameConfig.FALLING_PIECE_ROTATION, 1.5)  # Slight rotation
	tween.chain().tween_property(falling_node, "modulate:a", 0.0, 0.5)
	tween.tween_callback(falling_node.queue_free)

## Place the block (stop movement)
func _place_block() -> void:
	current_state = BlockState.PLACED
	velocity = Vector2.ZERO
	color_rect.color = placed_block_color
	
	# Add bounce animation
	_add_bounce_animation()

## Add bounce animation when block is placed
func _add_bounce_animation() -> void:
	var original_scale = scale
	scale = Vector2(1.1, 0.9)  # Squash effect
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", original_scale, 0.3)

## Get the current width of the block
func get_width() -> float:
	return block_width

## Check if block is placed
func is_placed() -> bool:
	return current_state == BlockState.PLACED

## Set screen width for boundary calculation
func set_screen_width(width: float) -> void:
	screen_width = width

## Place block immediately without animation (for base block)
func place_immediately() -> void:
	current_state = BlockState.PLACED
	velocity = Vector2.ZERO
