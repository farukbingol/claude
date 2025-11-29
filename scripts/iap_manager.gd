extends Node

## IAPManager - Handles In-App Purchase functionality
## Specifically for "No Ads" purchase

signal purchase_started
signal purchase_completed(product_id: String)
signal purchase_failed(product_id: String, error: String)
signal purchase_restored

# Product IDs
const PRODUCT_NO_ADS: String = "no_ads"

# Google Play Billing plugin reference
var billing_plugin = null

# Purchase state
var no_ads_purchased: bool = false

# Save file path
const SAVE_PATH: String = "user://iap_data.save"

func _ready() -> void:
	_load_purchase_state()
	_initialize_billing()
	print("IAPManager initialized. No Ads purchased: ", no_ads_purchased)

## Initialize Google Play Billing
func _initialize_billing() -> void:
	# Try to get Google Play Billing singleton
	if Engine.has_singleton("GodotGooglePlayBilling"):
		billing_plugin = Engine.get_singleton("GodotGooglePlayBilling")
		_setup_billing()
		print("Google Play Billing plugin found")
	else:
		print("Google Play Billing plugin not found - running in test mode")

## Setup billing callbacks
func _setup_billing() -> void:
	if billing_plugin == null:
		return
	
	# Connect signals if available
	if billing_plugin.has_signal("connected"):
		billing_plugin.connected.connect(_on_connected)
	if billing_plugin.has_signal("disconnected"):
		billing_plugin.disconnected.connect(_on_disconnected)
	if billing_plugin.has_signal("purchases_updated"):
		billing_plugin.purchases_updated.connect(_on_purchases_updated)
	if billing_plugin.has_signal("purchase_error"):
		billing_plugin.purchase_error.connect(_on_purchase_error)
	
	# Start connection
	if billing_plugin.has_method("startConnection"):
		billing_plugin.startConnection()

## Purchase No Ads
func purchase_no_ads() -> void:
	print("Attempting to purchase No Ads...")
	purchase_started.emit()
	
	if billing_plugin != null and billing_plugin.has_method("purchase"):
		billing_plugin.purchase(PRODUCT_NO_ADS)
	else:
		# Test mode - simulate successful purchase
		print("Test mode: Simulating No Ads purchase...")
		await get_tree().create_timer(1.0).timeout
		_complete_no_ads_purchase()

## Complete the No Ads purchase
func _complete_no_ads_purchase() -> void:
	no_ads_purchased = true
	_save_purchase_state()
	AdManager.disable_ads()
	purchase_completed.emit(PRODUCT_NO_ADS)
	print("No Ads purchase completed!")

## Restore purchases
func restore_purchases() -> void:
	print("Restoring purchases...")
	
	if billing_plugin != null and billing_plugin.has_method("queryPurchases"):
		billing_plugin.queryPurchases("inapp")
	else:
		# Test mode - check saved state
		if no_ads_purchased:
			purchase_restored.emit()
			print("Purchase restored from local storage")
		else:
			print("No purchases to restore")

## Check if No Ads has been purchased
func is_no_ads_purchased() -> bool:
	return no_ads_purchased

## Set No Ads purchased state (used by DiamondManager for diamond purchases)
func set_no_ads_purchased(purchased: bool) -> void:
	no_ads_purchased = purchased
	_save_purchase_state()
	if purchased:
		AdManager.disable_ads()
		purchase_completed.emit(PRODUCT_NO_ADS)

## Save purchase state to local storage
func _save_purchase_state() -> void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"no_ads_purchased": no_ads_purchased
		}
		save_file.store_var(save_data)
		save_file.close()
		print("Purchase state saved")

## Load purchase state from local storage
func _load_purchase_state() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			save_file.close()
			if save_data is Dictionary:
				no_ads_purchased = save_data.get("no_ads_purchased", false)
				print("Purchase state loaded")

# Billing callbacks
func _on_connected() -> void:
	print("Billing connected")
	# Query existing purchases
	if billing_plugin.has_method("queryPurchases"):
		billing_plugin.queryPurchases("inapp")

func _on_disconnected() -> void:
	print("Billing disconnected")

func _on_purchases_updated(purchases: Array) -> void:
	for purchase in purchases:
		if purchase is Dictionary:
			var sku = purchase.get("sku", "")
			var state = purchase.get("purchase_state", -1)
			
			if sku == PRODUCT_NO_ADS and state == 1:  # 1 = purchased
				_complete_no_ads_purchase()

func _on_purchase_error(error_code: int, error_message: String) -> void:
	print("Purchase error: ", error_code, " - ", error_message)
	purchase_failed.emit(PRODUCT_NO_ADS, error_message)
