class_name HUD
extends Control
## Persistent HUD overlay (TASKS.md 7.1): currency/XP display driven purely
## by EventBus signals (no polling), mode buttons, and single-modal
## coordination across Shop/Inventory/Quests (TASKS.md 7.2/7.3/7.4/7.5) —
## opening one closes any other that's open. Opening Inventory also enters
## Decorate Mode and hides this HUD's own top bar/buttons ("hides HUD
## clutter" per 7.4's DoD); closing it exits Decorate Mode again.

@onready var top_bar: Control = $TopBar
@onready var coins_label: Label = $TopBar/CoinsLabel
@onready var gems_label: Label = $TopBar/GemsLabel
@onready var level_label: Label = $TopBar/LevelLabel
@onready var xp_bar: ProgressBar = $TopBar/XPBar
@onready var notification_bell: Button = $TopBar/NotificationBell  # TODO: stub for Phase 2/3, no behavior yet

@onready var button_row: Control = $ButtonRow
@onready var shop_button: Button = $ButtonRow/ShopButton
@onready var inventory_button: Button = $ButtonRow/InventoryButton
@onready var quests_button: Button = $ButtonRow/QuestsButton

@onready var shop_ui: ShopUI = $Shop
@onready var inventory_ui: InventoryUI = $Inventory
@onready var quests_ui: QuestsUI = $Quests


func _ready() -> void:
	shop_button.pressed.connect(_open_panel.bind(shop_ui))
	quests_button.pressed.connect(_open_panel.bind(quests_ui))
	inventory_button.pressed.connect(_open_decorate_mode)
	inventory_ui.closed.connect(_on_inventory_closed)

	EventBus.currency_changed.connect(_on_currency_changed)
	EventBus.level_up.connect(_on_level_up)

	_refresh_currency()
	_refresh_xp()


func _refresh_currency() -> void:
	coins_label.text = "Coins: %d" % PlayerData.coins
	gems_label.text = "Gems: %d" % PlayerData.gems


func _refresh_xp() -> void:
	level_label.text = "Lv. %d" % PlayerData.level
	var current_floor := PlayerLevel.xp_required_for_level(PlayerData.level)
	var next_floor := PlayerLevel.xp_required_for_level(PlayerData.level + 1)
	xp_bar.min_value = 0
	xp_bar.max_value = maxi(next_floor - current_floor, 1)
	xp_bar.value = PlayerData.xp - current_floor


func _on_currency_changed(_type: DecorItem.CurrencyType, _new_amount: int) -> void:
	_refresh_currency()


func _on_level_up(_new_level: int) -> void:
	_refresh_xp()


func _open_panel(panel: Control) -> void:
	_close_all_panels()
	panel.open()


func _open_decorate_mode() -> void:
	_close_all_panels()
	GameState.decorate_mode_active = true
	top_bar.visible = false
	button_row.visible = false
	inventory_ui.open()


func _on_inventory_closed() -> void:
	GameState.decorate_mode_active = false
	top_bar.visible = true
	button_row.visible = true


func _close_all_panels() -> void:
	shop_ui.close()
	inventory_ui.close()
	quests_ui.close()
