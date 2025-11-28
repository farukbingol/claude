extends Node

## GameConfig - Central configuration for all game settings
## Easy to modify all game parameters in one place

# ============= BLOCK SETTINGS =============
const BASE_BLOCK_WIDTH: float = 200.0
const BASE_BLOCK_HEIGHT: float = 50.0
const MIN_BLOCK_WIDTH: float = 20.0

# ============= SPEED SETTINGS =============
const BASE_BLOCK_SPEED: float = 300.0
const MAX_BLOCK_SPEED: float = 800.0
const SPEED_INCREASE_INTERVAL: int = 5  # Increase speed every N blocks
const SPEED_INCREASE_PERCENT: float = 0.10  # 10% speed increase

# ============= SCORING SETTINGS =============
const NORMAL_SCORE: int = 10
const PERFECT_BONUS: int = 100
const PERFECT_THRESHOLD: float = 5.0  # Pixels tolerance for perfect placement

# Combo multipliers
const COMBO_BASE_MULTIPLIER: float = 2.0  # First combo gives 2x
const COMBO_INCREMENT: float = 1.0  # Each subsequent combo adds 1x (2x, 3x, 4x...)
const COMBO_START_THRESHOLD: int = 2  # Combo starts counting from this number of consecutive perfects

# ============= PHYSICS SETTINGS =============
const BLOCK_GRAVITY: float = 1500.0
const BLOCK_FALL_OFF_Y: float = 2500.0  # Y position where block is considered fallen off

# ============= VISUAL SETTINGS =============
# Block color palette (as per requirements)
const BLOCK_COLORS: Array = [
	Color("#FF6B6B"),  # Red
	Color("#4ECDC4"),  # Turquoise
	Color("#FFE66D"),  # Yellow
	Color("#95E1D3"),  # Mint
	Color("#F38181"),  # Coral
	Color("#AA96DA"),  # Purple
	Color("#FCBAD3"),  # Pink
	Color("#A8D8EA"),  # Light Blue
]

# Background gradient colors (sky changes as tower grows)
const BG_COLORS: Array = [
	Color("#1a1a2e"),  # Night - bottom
	Color("#16213e"),  # Deep blue
	Color("#0f3460"),  # Blue
	Color("#1a508b"),  # Light blue
	Color("#c06c84"),  # Sunset pink
	Color("#f67280"),  # Coral
	Color("#f8b500"),  # Orange
	Color("#ffcb74"),  # Light orange - top
]

# Animation durations
const PERFECT_TEXT_DURATION: float = 1.0
const COMBO_TEXT_DURATION: float = 1.2
const BLOCK_SPAWN_DELAY: float = 0.3
const SCREEN_SHAKE_DURATION: float = 0.3
const SCREEN_SHAKE_INTENSITY: float = 10.0
const FALLING_PIECE_ROTATION: float = 0.05  # Rotation factor for falling pieces

# Background gradient settings
const BG_GRADIENT_BLOCKS_FOR_FULL_CHANGE: float = 50.0  # Full gradient change at this many blocks
const BG_GRADIENT_TRANSITION_RANGE: int = 4  # Number of colors in gradient transition

# ============= AD SETTINGS =============
const INTERSTITIAL_MIN_GAMES: int = 3
const INTERSTITIAL_MAX_GAMES: int = 5
const GAMES_BETWEEN_INTERSTITIALS: int = 3  # Show interstitial every N games

# ============= UI SETTINGS =============
const SCREEN_WIDTH: float = 1080.0
const SCREEN_HEIGHT: float = 1920.0
const BANNER_HEIGHT: float = 100.0

func _ready() -> void:
	print("GameConfig loaded")
