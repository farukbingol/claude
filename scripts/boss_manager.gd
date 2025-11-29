extends Node

## BossManager - Handles boss spawning and effects
## Bosses appear every 20 blocks with increasing difficulty

signal boss_started(boss_type: String, level: int)
signal boss_defeated(boss_type: String, reward: int)
signal boss_effect_active(effect_type: String)

# Current boss state
var current_boss: String = ""
var boss_active: bool = false
var current_boss_level: int = 0
var difficulty_cycle: int = 0  # Increases each time we loop past 100

# Effect states
var ice_effect_active: bool = false
var earthquake_effect_active: bool = false
var ghost_effect_active: bool = false
var chaos_effect_active: bool = false

func _ready() -> void:
	print("BossManager initialized")

## Check if a boss should spawn at this block level
func check_boss_spawn(block_count: int) -> void:
	# block_count = len(placed_blocks), first element is base platform
	# Actual block count = block_count - 1
	var actual_blocks = block_count - 1
	
	if actual_blocks <= 0:
		return
	
	# Calculate effective level (loops every 100 blocks)
	var effective_level = actual_blocks % 100
	if effective_level == 0 and actual_blocks > 0:
		effective_level = 100
	
	# Calculate difficulty cycle (how many times we've looped)
	difficulty_cycle = actual_blocks / 100
	
	# Check if we're at a boss level
	for i in range(len(GameConfig.BOSS_LEVELS)):
		if effective_level == GameConfig.BOSS_LEVELS[i]:
			_start_boss(GameConfig.BOSS_TYPES[i], GameConfig.BOSS_LEVELS[i])
			print("🔥 BOSS SPAWN: ", GameConfig.BOSS_TYPES[i], " at block ", actual_blocks)
			return

## Start a boss encounter
func _start_boss(boss_type: String, level: int) -> void:
	current_boss = boss_type
	current_boss_level = level
	boss_active = true
	
	# Reset all effects
	_reset_all_effects()
	
	# Activate boss-specific effect
	match boss_type:
		"ice":
			ice_effect_active = true
		"wind":
			# Wind is already handled by existing wind system
			pass
		"earthquake":
			earthquake_effect_active = true
		"ghost":
			ghost_effect_active = true
		"chaos":
			chaos_effect_active = true
			ice_effect_active = true
			earthquake_effect_active = true
			ghost_effect_active = true
	
	boss_started.emit(boss_type, level)
	boss_effect_active.emit(boss_type)
	print("BOSS STARTED: ", boss_type, " at level ", level)

## Called when a block is successfully placed during boss fight
func on_block_placed_during_boss() -> void:
	if boss_active:
		_defeat_boss()

## Defeat the current boss and give reward
func _defeat_boss() -> void:
	if not boss_active:
		return
	
	var reward = get_boss_reward(current_boss)
	
	# Apply difficulty multiplier for cycles
	reward = reward * (1 + difficulty_cycle)
	
	DiamondManager.add_diamonds(reward)
	
	boss_defeated.emit(current_boss, reward)
	print("BOSS DEFEATED: ", current_boss, " Reward: ", reward, " diamonds")
	
	# Reset boss state
	current_boss = ""
	boss_active = false
	_reset_all_effects()

## Get the reward for a specific boss type
func get_boss_reward(boss_type: String) -> int:
	return GameConfig.BOSS_REWARDS.get(boss_type, 0)

## Reset all boss effects
func _reset_all_effects() -> void:
	ice_effect_active = false
	earthquake_effect_active = false
	ghost_effect_active = false
	chaos_effect_active = false

## Get ice slide amount (applies difficulty scaling)
func get_ice_slide_amount() -> float:
	if not ice_effect_active:
		return 0.0
	return GameConfig.ICE_SLIDE_AMOUNT * (1.0 + difficulty_cycle * 0.2)

## Check if earthquake effect is active
func is_earthquake_active() -> bool:
	return earthquake_effect_active

## Get earthquake shake intensity
func get_earthquake_shake_intensity() -> float:
	if not earthquake_effect_active:
		return 0.0
	return GameConfig.EARTHQUAKE_SHAKE_INTENSITY * (1.0 + difficulty_cycle * 0.1)

## Get earthquake tower sway
func get_earthquake_tower_sway() -> float:
	if not earthquake_effect_active:
		return 0.0
	return GameConfig.EARTHQUAKE_TOWER_SWAY * (1.0 + difficulty_cycle * 0.1)

## Check if ghost effect is active
func is_ghost_active() -> bool:
	return ghost_effect_active

## Get ghost blink interval (faster at higher difficulties)
func get_ghost_blink_interval() -> float:
	if not ghost_effect_active:
		return 0.0
	return GameConfig.GHOST_BLINK_INTERVAL / (1.0 + difficulty_cycle * 0.2)

## Check if chaos effect is active
func is_chaos_active() -> bool:
	return chaos_effect_active

## Get chaos speed multiplier (random between min and max)
func get_chaos_speed_multiplier() -> float:
	if not chaos_effect_active:
		return 1.0
	return randf_range(GameConfig.CHAOS_SPEED_MIN, GameConfig.CHAOS_SPEED_MAX)

## Get chaos size multiplier (random between min and max)
func get_chaos_size_multiplier() -> float:
	if not chaos_effect_active:
		return 1.0
	return randf_range(GameConfig.CHAOS_SIZE_MIN, GameConfig.CHAOS_SIZE_MAX)

## Check if any boss is active
func is_boss_active() -> bool:
	return boss_active

## Get current boss type
func get_current_boss() -> String:
	return current_boss

## Get boss display name
func get_boss_display_name(boss_type: String) -> String:
	match boss_type:
		"ice":
			return "❄️ BUZ BOSS"
		"wind":
			return "💨 RÜZGAR BOSS"
		"earthquake":
			return "🌋 DEPREM BOSS"
		"ghost":
			return "👻 HAYALET BOSS"
		"chaos":
			return "🌀 KAOS BOSS"
		_:
			return "BOSS"

## Get boss color for UI
func get_boss_color(boss_type: String) -> Color:
	match boss_type:
		"ice":
			return Color(0.5, 0.8, 1.0)  # Light blue
		"wind":
			return Color(0.7, 0.9, 0.7)  # Light green
		"earthquake":
			return Color(1.0, 0.5, 0.3)  # Orange
		"ghost":
			return Color(0.8, 0.6, 1.0)  # Purple
		"chaos":
			return Color(1.0, 0.2, 0.5)  # Pink/red
		_:
			return Color.WHITE
