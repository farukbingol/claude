# Tower Stacking Game 🏗️

A fun and addictive tower stacking game built with Godot Engine 4.x for Android.

## 🎮 Game Description

Stack blocks as high as you can! Tap to drop blocks and try to align them perfectly. The more accurate your placement, the higher your score. Miss completely and it's game over!

### Features
- **Intuitive Controls**: Simple tap to drop gameplay
- **Progressive Difficulty**: Speed increases as you stack higher
- **Perfect Bonuses**: Get bonus points for precise placement
- **High Score Tracking**: Beat your best score
- **AdMob Integration**: Banner, interstitial, and rewarded ads
- **No Ads Option**: In-app purchase to remove ads
- **Sound Effects & Music**: Immersive audio experience

## 📱 Screenshots

*Coming soon*

## 🛠️ Requirements

- Godot Engine 4.2 or higher
- Android SDK (for Android export)
- JDK 11+ (for Android export)

## 📦 Project Structure

```
├── project.godot          # Main Godot project file
├── export_presets.cfg     # Android export configuration
├── addons/
│   └── admob/             # AdMob plugin placeholder
├── assets/
│   ├── images/            # Image assets (icons, etc.)
│   ├── sounds/            # Sound effects and music
│   └── fonts/             # Custom fonts
├── scenes/
│   ├── main_menu.tscn     # Main menu screen
│   ├── game.tscn          # Main game scene
│   ├── game_over.tscn     # Game over screen
│   └── settings.tscn      # Settings screen
├── scripts/
│   ├── game_manager.gd    # Central game state management
│   ├── block.gd           # Block behavior and physics
│   ├── score_manager.gd   # Score tracking and persistence
│   ├── ad_manager.gd      # AdMob integration
│   ├── iap_manager.gd     # In-app purchase handling
│   └── audio_manager.gd   # Audio management
└── config/
    └── ads_config.gd      # Ad unit IDs configuration
```

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/tower-stacking.git
cd tower-stacking
```

### 2. Open in Godot
1. Open Godot Engine 4.2+
2. Click "Import"
3. Navigate to the project folder
4. Select `project.godot`
5. Click "Import & Edit"

### 3. Run in Editor
Press F5 or click the Play button to test the game in the editor.

## 📱 Building for Android

### Prerequisites
1. Install Android SDK
2. Install JDK 11+
3. Configure Godot's Android export templates

### Steps
1. Go to **Project > Export**
2. Select "Android" preset
3. Configure signing keystore (see below)
4. Click "Export Project"

### Creating a Keystore
```bash
keytool -genkey -v -keystore release-key.keystore -alias tower-stacking -keyalg RSA -keysize 2048 -validity 10000
```

### Debug Build (APK)
```bash
# In Godot Editor: Project > Export > Android > Export Project
# Select .apk format
```

### Release Build (AAB)
```bash
# For Google Play Store, export as .aab format
# Make sure to sign with your release keystore
```

## ⚙️ Configuration

### AdMob Setup
See [SETUP_ADMOB.md](SETUP_ADMOB.md) for complete AdMob configuration.

### In-App Purchases
See [SETUP_IAP.md](SETUP_IAP.md) for Google Play Billing setup.

### Publishing to Google Play
See [PUBLISH_GUIDE.md](PUBLISH_GUIDE.md) for step-by-step publishing guide.

## 🎨 Customization

### Changing Block Colors
Edit `block_colors` array in `scenes/game_controller.gd`:
```gdscript
var block_colors: Array[Color] = [
    Color(0.9, 0.3, 0.3),   # Red
    Color(0.9, 0.6, 0.3),   # Orange
    # Add more colors...
]
```

### Adjusting Difficulty
Edit values in `scripts/game_manager.gd`:
```gdscript
var base_block_speed: float = 300.0      # Starting speed
var speed_increase_per_block: float = 5.0 # Speed increase
var max_block_speed: float = 800.0       # Maximum speed
var perfect_threshold: float = 5.0       # Perfect placement range
```

### Changing Ad Unit IDs
Edit `config/ads_config.gd`:
```gdscript
const BANNER_AD_ID: String = "your-banner-id"
const INTERSTITIAL_AD_ID: String = "your-interstitial-id"
const REWARDED_AD_ID: String = "your-rewarded-id"
```

## 📝 License

This project is open source. Feel free to use, modify, and distribute.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

If you encounter any issues, please open an issue on GitHub.

---

Made with ❤️ using Godot Engine