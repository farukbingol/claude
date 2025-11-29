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

# ============= WIND SETTINGS =============
const WIND_START_BLOCKS: int = 50  # Wind starts affecting blocks after this many blocks
const WIND_BASE_STRENGTH: float = 100.0  # Base wind oscillation strength
const WIND_MAX_STRENGTH: float = 300.0  # Maximum wind strength
const WIND_RAMP_BLOCKS: int = 50  # Blocks over which wind reaches max strength

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
# Zone 1 (0-30 blocks): City silhouette (orange/purple)
# Zone 2 (30-60 blocks): Clouds (blue/white)
# Zone 3 (60-100 blocks): High atmosphere (dark blue)
# Zone 4 (100+ blocks): Space (black + stars)
const BG_COLORS: Array = [
	Color("#2d1b4e"),  # Purple (city bottom)
	Color("#4a2c7d"),  # Purple mid
	Color("#ff6b35"),  # Orange sunset
	Color("#f7931a"),  # Orange
	Color("#87ceeb"),  # Sky blue (clouds start)
	Color("#b0d4ed"),  # Light blue
	Color("#e8f4f8"),  # Almost white (cloud tops)
	Color("#4a90bd"),  # Medium blue (high atmosphere)
	Color("#1e3a5f"),  # Dark blue
	Color("#0a1628"),  # Very dark blue (space approach)
	Color("#050a12"),  # Almost black
	Color("#000008"),  # Space black
]

# Background zone thresholds (block counts)
const BG_ZONE_CITY: int = 30
const BG_ZONE_CLOUDS: int = 60
const BG_ZONE_ATMOSPHERE: int = 100

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
