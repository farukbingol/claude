extends Control

## ShopController - Handles the shop UI for purchasing modes, themes, and other items

@onready var mods_list: VBoxContainer = $GlassPanel/VBoxContainer/TabContainer/Modlar/ModsList
@onready var themes_list: VBoxContainer = $GlassPanel/VBoxContainer/TabContainer/Temalar/ThemesList
@onready var other_list: VBoxContainer = $GlassPanel/VBoxContainer/TabContainer/Diğer/OtherList

# Diamond balance label (created dynamically)
var diamond_label: Label = null

# Shop item definitions
const SHOP_ITEMS = {
	"modes": [
		{"id": "zen", "name": "Zen Mode", "description": "Rahatlatıcı, puansız mod", "price": 0.99, "currency": "usd", "unlock_condition": "purchase_only"},
		{"id": "time_attack", "name": "Time Attack", "description": "Zamana karşı yarış", "price": 0.49, "currency": "usd", "unlock_condition": "blocks_50", "unlock_alt": "50 blok yerleştir"},
		{"id": "precision", "name": "Precision", "description": "Sadece perfect sayılır", "price": 0.49, "currency": "usd", "unlock_condition": "perfect_streak_5", "unlock_alt": "5 perfect üst üste"},
		{"id": "speed_run", "name": "Speed Run", "description": "En hızlı 100 blok", "price": 0.49, "currency": "usd", "unlock_condition": "blocks_100", "unlock_alt": "100 blok yerleştir"}
	],
	"themes": [
		{"id": "neon_theme", "name": "Neon Tema", "description": "Parlak neon renkler", "price": 0.99, "currency": "usd", "diamond_price": 100, "unlock_condition": "combo_20", "unlock_alt": "20 combo yap"},
		{"id": "sakura_theme", "name": "Sakura Tema", "description": "Japon kiraz çiçekleri", "price": 0.99, "currency": "usd", "diamond_price": 150, "unlock_condition": "blocks_500", "unlock_alt": "500 blok yerleştir"},
		{"id": "space_theme", "name": "Space Tema", "description": "Uzay ve yıldızlar", "price": 1.99, "currency": "usd", "diamond_price": 250, "unlock_condition": "blocks_1000", "unlock_alt": "1000 blok yerleştir"}
	],
	"other": [
		{"id": "no_ads", "name": "Reklamsız", "description": "Tüm reklamları kaldır", "price": 2.99, "currency": "usd", "diamond_price": 500, "unlock_condition": "purchase_only"}
	]
}

func _ready() -> void:
	_setup_diamond_display()
	_populate_shop()
	DiamondManager.diamonds_changed.connect(_on_diamonds_changed)

func _setup_diamond_display() -> void:
	# Create diamond balance label in header
	diamond_label = Label.new()
	diamond_label.text = "💎 " + str(DiamondManager.get_diamonds())
	diamond_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	diamond_label.add_theme_font_size_override("font_size", 28)
	diamond_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	$GlassPanel/VBoxContainer/Header.add_child(diamond_label)

func _on_diamonds_changed(new_amount: int) -> void:
	if diamond_label:
		diamond_label.text = "💎 " + str(new_amount)
	_populate_shop()  # Refresh to update button states

func _populate_shop() -> void:
	_populate_list(mods_list, SHOP_ITEMS.modes)
	_populate_list(themes_list, SHOP_ITEMS.themes)
	_populate_list(other_list, SHOP_ITEMS.other)

func _populate_list(list_container: VBoxContainer, items: Array) -> void:
	# Clear existing items
	for child in list_container.get_children():
		child.queue_free()
	
	# Add shop items
	for item in items:
		var panel = _create_shop_item(item)
		list_container.add_child(panel)

func _create_shop_item(item: Dictionary) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 140)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	panel.add_child(hbox)
	
	# Icon/status
	var status_label = Label.new()
	status_label.custom_minimum_size = Vector2(60, 0)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 36)
	
	var is_unlocked = GameManager.is_item_unlocked(item.id)
	if item.id == "no_ads":
		is_unlocked = IAPManager.is_no_ads_purchased()
	
	if is_unlocked:
		status_label.text = "✓"
		status_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
	else:
		status_label.text = "🔒"
	hbox.add_child(status_label)
	
	# Text container
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	# Name
	var name_label = Label.new()
	name_label.text = item.name
	name_label.add_theme_font_size_override("font_size", 28)
	if is_unlocked:
		name_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	vbox.add_child(name_label)
	
	# Description
	var desc_label = Label.new()
	desc_label.text = item.description
	desc_label.add_theme_font_size_override("font_size", 20)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(desc_label)
	
	# Unlock condition (if applicable)
	if item.has("unlock_alt") and not is_unlocked:
		var unlock_label = Label.new()
		unlock_label.text = "🎯 " + item.unlock_alt
		unlock_label.add_theme_font_size_override("font_size", 18)
		unlock_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1))
		vbox.add_child(unlock_label)
	
	# Buttons container
	if not is_unlocked:
		var buttons_vbox = VBoxContainer.new()
		buttons_vbox.add_theme_constant_override("separation", 5)
		hbox.add_child(buttons_vbox)
		
		# USD price button
		var buy_button = Button.new()
		buy_button.custom_minimum_size = Vector2(150, 45)
		buy_button.text = "$" + str(item.price)
		buy_button.add_theme_font_size_override("font_size", 22)
		buy_button.set_meta("item_id", item.id)
		buy_button.pressed.connect(_on_buy_pressed.bind(item.id))
		buttons_vbox.add_child(buy_button)
		
		# Diamond price button (if item has diamond_price)
		if item.has("diamond_price"):
			var diamond_button = Button.new()
			diamond_button.custom_minimum_size = Vector2(150, 45)
			diamond_button.text = "💎 " + str(item.diamond_price)
			diamond_button.add_theme_font_size_override("font_size", 22)
			
			# Disable if not enough diamonds
			if DiamondManager.get_diamonds() < item.diamond_price:
				diamond_button.disabled = true
				diamond_button.modulate = Color(0.5, 0.5, 0.5)
			
			diamond_button.pressed.connect(_on_diamond_buy_pressed.bind(item.id, item.diamond_price))
			buttons_vbox.add_child(diamond_button)
	else:
		var owned_label = Label.new()
		owned_label.custom_minimum_size = Vector2(150, 0)
		owned_label.text = "OWNED"
		owned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		owned_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		owned_label.add_theme_font_size_override("font_size", 20)
		owned_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
		hbox.add_child(owned_label)
	
	return panel

func _on_buy_pressed(item_id: String) -> void:
	AudioManager.play_button_click()
	print("Purchasing: ", item_id)
	
	# Handle purchase via IAPManager
	if item_id == "no_ads":
		IAPManager.purchase_no_ads()
	else:
		# For other items, we'd use the appropriate IAP method
		# For now, just unlock it for testing
		GameManager.unlock_item(item_id)
		_populate_shop()  # Refresh UI

func _on_diamond_buy_pressed(item_id: String, diamond_cost: int) -> void:
	AudioManager.play_button_click()
	print("Purchasing with diamonds: ", item_id, " for ", diamond_cost, " diamonds")
	
	if item_id == "no_ads":
		if DiamondManager.purchase_no_ads_with_diamonds():
			print("No Ads purchased with diamonds!")
	else:
		if DiamondManager.purchase_item(item_id, diamond_cost):
			GameManager.unlock_item(item_id)
	
	_populate_shop()  # Refresh UI

func _on_back_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
