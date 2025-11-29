extends Node

## DiamondManager - Handles diamond economy
## Diamonds are earned from defeating bosses and can be used to purchase items

signal diamonds_changed(new_amount: int)
signal purchase_completed(item_id: String)
signal purchase_failed(item_id: String, reason: String)

# Diamond balance
var diamonds: int = 0

# DevOps mode state
var dev_mode_active: bool = false
var all_skins_unlocked: bool = false

# Purchased items
var purchased_items: Array = []

# Save file path
const SAVE_PATH: String = "user://diamond_data.save"

func _ready() -> void:
	_load_data()
	print("DiamondManager initialized. Diamonds: ", diamonds)

## Add diamonds (from boss defeats)
func add_diamonds(amount: int) -> void:
	diamonds += amount
	diamonds_changed.emit(diamonds)
	_save_data()
	print("Diamonds added: ", amount, " Total: ", diamonds)

## Spend diamonds (returns true if successful)
func spend_diamonds(amount: int) -> bool:
	if diamonds >= amount:
		diamonds -= amount
		diamonds_changed.emit(diamonds)
		_save_data()
		return true
	return false

## Get current diamond balance
func get_diamonds() -> int:
	return diamonds

## Purchase an item with diamonds
func purchase_item(item_id: String, cost: int) -> bool:
	if item_id in purchased_items:
		purchase_failed.emit(item_id, "Already purchased")
		return false
	
	if diamonds >= cost:
		diamonds -= cost
		purchased_items.append(item_id)
		diamonds_changed.emit(diamonds)
		purchase_completed.emit(item_id)
		_save_data()
		print("Item purchased: ", item_id)
		return true
	else:
		purchase_failed.emit(item_id, "Not enough diamonds")
		return false

## Check if an item has been purchased
func is_item_purchased(item_id: String) -> bool:
	if dev_mode_active and all_skins_unlocked:
		return true
	return item_id in purchased_items

## Purchase No Ads with diamonds
func purchase_no_ads_with_diamonds() -> bool:
	if purchase_item("no_ads_diamond", GameConfig.NO_ADS_DIAMOND_COST):
		# Also update IAPManager to reflect no ads state
		IAPManager.no_ads_purchased = true
		IAPManager._save_purchase_state()
		return true
	return false

## Check if No Ads was purchased with diamonds
func is_no_ads_purchased_with_diamonds() -> bool:
	return "no_ads_diamond" in purchased_items

## Activate DevOps mode
func activate_dev_mode() -> void:
	dev_mode_active = true
	all_skins_unlocked = true
	diamonds = GameConfig.DEVOPS_DIAMONDS
	
	# Also set no ads
	IAPManager.no_ads_purchased = true
	IAPManager._save_purchase_state()
	
	diamonds_changed.emit(diamonds)
	_save_data()
	print("DEV MODE ACTIVATED - Diamonds: ", diamonds)

## Check if DevOps mode is active
func is_dev_mode_active() -> bool:
	return dev_mode_active

## Deactivate DevOps mode (for testing)
func deactivate_dev_mode() -> void:
	dev_mode_active = false
	all_skins_unlocked = false
	_load_data()  # Reload saved data
	print("DEV MODE DEACTIVATED")

## Save data
func _save_data() -> void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"diamonds": diamonds,
			"purchased_items": purchased_items,
			"dev_mode_active": dev_mode_active,
			"all_skins_unlocked": all_skins_unlocked
		}
		save_file.store_var(save_data)
		save_file.close()

## Load data
func _load_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			save_file.close()
			if save_data is Dictionary:
				diamonds = save_data.get("diamonds", 0)
				purchased_items = save_data.get("purchased_items", [])
				dev_mode_active = save_data.get("dev_mode_active", false)
				all_skins_unlocked = save_data.get("all_skins_unlocked", false)
