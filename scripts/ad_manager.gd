extends Node

## AdManager - Handles AdMob integration
## Uses placeholder implementation that can be replaced with actual AdMob plugin

signal banner_loaded
signal banner_failed
signal interstitial_loaded
signal interstitial_closed
signal rewarded_ad_loaded
signal rewarded_ad_earned
signal rewarded_ad_closed

# AdMob plugin reference (will be null if plugin not installed)
var admob_plugin = null

# Ad states
var is_banner_loaded: bool = false
var is_interstitial_loaded: bool = false
var is_rewarded_loaded: bool = false

# Ads enabled flag (false when No Ads purchased)
var ads_enabled: bool = true

func _ready() -> void:
	_initialize_admob()
	print("AdManager initialized. Ads enabled: ", ads_enabled)

## Initialize AdMob plugin if available
func _initialize_admob() -> void:
	# Check if ads are disabled via purchase
	ads_enabled = not IAPManager.is_no_ads_purchased()
	
	# Try to get AdMob singleton
	if Engine.has_singleton("AdMob"):
		admob_plugin = Engine.get_singleton("AdMob")
		_setup_admob()
		print("AdMob plugin found and initialized")
	else:
		print("AdMob plugin not found - running in test mode")

## Setup AdMob with configuration
func _setup_admob() -> void:
	if admob_plugin == null:
		return
	
	# Initialize with config
	var config = {
		"is_test_mode": AdsConfig.IS_TEST_MODE,
		"banner_id": AdsConfig.BANNER_AD_ID,
		"interstitial_id": AdsConfig.INTERSTITIAL_AD_ID,
		"rewarded_id": AdsConfig.REWARDED_AD_ID
	}
	
	# Connect signals if available
	if admob_plugin.has_signal("banner_loaded"):
		admob_plugin.banner_loaded.connect(_on_banner_loaded)
	if admob_plugin.has_signal("banner_failed_to_load"):
		admob_plugin.banner_failed_to_load.connect(_on_banner_failed)
	if admob_plugin.has_signal("interstitial_loaded"):
		admob_plugin.interstitial_loaded.connect(_on_interstitial_loaded)
	if admob_plugin.has_signal("interstitial_closed"):
		admob_plugin.interstitial_closed.connect(_on_interstitial_closed)
	if admob_plugin.has_signal("rewarded_ad_loaded"):
		admob_plugin.rewarded_ad_loaded.connect(_on_rewarded_loaded)
	if admob_plugin.has_signal("rewarded_ad_earned_reward"):
		admob_plugin.rewarded_ad_earned_reward.connect(_on_rewarded_earned)
	if admob_plugin.has_signal("rewarded_ad_closed"):
		admob_plugin.rewarded_ad_closed.connect(_on_rewarded_closed)
	
	# Initialize the plugin
	if admob_plugin.has_method("initialize"):
		admob_plugin.initialize()

## Show banner ad at bottom of screen
func show_banner() -> void:
	if not ads_enabled:
		print("Ads disabled - not showing banner")
		return
	
	if admob_plugin != null and admob_plugin.has_method("load_banner"):
		admob_plugin.load_banner()
		print("Loading banner ad...")
	else:
		print("Banner ad requested (test mode)")
		# Simulate banner load in test mode
		await get_tree().create_timer(0.5).timeout
		_on_banner_loaded()

## Hide banner ad
func hide_banner() -> void:
	if admob_plugin != null and admob_plugin.has_method("hide_banner"):
		admob_plugin.hide_banner()
	print("Banner hidden")

## Load interstitial ad
func load_interstitial() -> void:
	if not ads_enabled:
		return
	
	if admob_plugin != null and admob_plugin.has_method("load_interstitial"):
		admob_plugin.load_interstitial()
		print("Loading interstitial ad...")
	else:
		print("Interstitial ad loading (test mode)")
		# Simulate load in test mode
		await get_tree().create_timer(1.0).timeout
		_on_interstitial_loaded()

## Show interstitial ad
func show_interstitial() -> void:
	if not ads_enabled:
		print("Ads disabled - not showing interstitial")
		interstitial_closed.emit()
		return
	
	if not is_interstitial_loaded:
		print("Interstitial not loaded yet")
		interstitial_closed.emit()
		return
	
	if admob_plugin != null and admob_plugin.has_method("show_interstitial"):
		admob_plugin.show_interstitial()
		print("Showing interstitial ad...")
	else:
		print("Showing interstitial ad (test mode)")
		# Simulate showing in test mode
		await get_tree().create_timer(2.0).timeout
		_on_interstitial_closed()

## Load rewarded ad
func load_rewarded() -> void:
	if admob_plugin != null and admob_plugin.has_method("load_rewarded"):
		admob_plugin.load_rewarded()
		print("Loading rewarded ad...")
	else:
		print("Rewarded ad loading (test mode)")
		# Simulate load in test mode
		await get_tree().create_timer(1.0).timeout
		_on_rewarded_loaded()

## Show rewarded ad
func show_rewarded() -> void:
	if not is_rewarded_loaded:
		print("Rewarded ad not loaded yet")
		return
	
	if admob_plugin != null and admob_plugin.has_method("show_rewarded"):
		admob_plugin.show_rewarded()
		print("Showing rewarded ad...")
	else:
		print("Showing rewarded ad (test mode)")
		# Simulate watching ad in test mode
		await get_tree().create_timer(3.0).timeout
		_on_rewarded_earned("coins", 1)
		_on_rewarded_closed()

## Check if rewarded ad is ready
func is_rewarded_ready() -> bool:
	return is_rewarded_loaded

## Update ads enabled state (called when No Ads is purchased)
func disable_ads() -> void:
	ads_enabled = false
	hide_banner()
	print("Ads have been disabled")

# Signal handlers
func _on_banner_loaded() -> void:
	is_banner_loaded = true
	banner_loaded.emit()
	print("Banner loaded successfully")

func _on_banner_failed() -> void:
	is_banner_loaded = false
	banner_failed.emit()
	print("Banner failed to load")

func _on_interstitial_loaded() -> void:
	is_interstitial_loaded = true
	interstitial_loaded.emit()
	print("Interstitial loaded successfully")

func _on_interstitial_closed() -> void:
	is_interstitial_loaded = false
	interstitial_closed.emit()
	# Preload next interstitial
	load_interstitial()
	print("Interstitial closed")

func _on_rewarded_loaded() -> void:
	is_rewarded_loaded = true
	rewarded_ad_loaded.emit()
	print("Rewarded ad loaded successfully")

func _on_rewarded_earned(_currency: String, _amount: int) -> void:
	rewarded_ad_earned.emit()
	print("Reward earned!")

func _on_rewarded_closed() -> void:
	is_rewarded_loaded = false
	rewarded_ad_closed.emit()
	# Preload next rewarded ad
	load_rewarded()
	print("Rewarded ad closed")
