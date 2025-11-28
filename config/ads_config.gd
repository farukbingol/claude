extends Node

## AdsConfig - Configuration for AdMob ads
## Replace the placeholder IDs with your actual AdMob IDs

# Test mode - Set to false for production
const IS_TEST_MODE: bool = true

# AdMob App ID (replace with your actual App ID)
# For testing, use the Google test App ID
const ADMOB_APP_ID: String = "ca-app-pub-3940256099942544~3347511713"

# Banner Ad Unit ID
# Test ID: ca-app-pub-3940256099942544/6300978111
# Replace with your actual Banner Ad Unit ID for production
const BANNER_AD_ID: String = "ca-app-pub-3940256099942544/6300978111"

# Interstitial Ad Unit ID
# Test ID: ca-app-pub-3940256099942544/1033173712
# Replace with your actual Interstitial Ad Unit ID for production
const INTERSTITIAL_AD_ID: String = "ca-app-pub-3940256099942544/1033173712"

# Rewarded Ad Unit ID
# Test ID: ca-app-pub-3940256099942544/5224354917
# Replace with your actual Rewarded Ad Unit ID for production
const REWARDED_AD_ID: String = "ca-app-pub-3940256099942544/5224354917"

# Banner position
enum BannerPosition { TOP, BOTTOM }
const BANNER_POS: BannerPosition = BannerPosition.BOTTOM

func _ready() -> void:
	if IS_TEST_MODE:
		print("AdMob running in TEST MODE")
		print("Remember to replace test IDs with production IDs before publishing!")
	else:
		print("AdMob running in PRODUCTION MODE")
