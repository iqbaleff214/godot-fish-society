class_name ShopUI
extends Control
## Shop panel controller (TASKS.md 5.3/7.2): tab switch, full catalog list
## with locked items shown-but-disabled, purchase attempt + feedback,
## single-modal coordination via HUD (open()/close() called externally).

enum Tab { FISH, DECOR }

## Assigned externally by tank_view.gd after instancing (TASKS.md 7.1) —
## simpler and less fragile than a NodePath tied to exact scene nesting depth.
var shop_manager: ShopManager

@onready var fish_tab_button: Button = $Panel/Margin/VBox/TabRow/FishTabButton
@onready var decor_tab_button: Button = $Panel/Margin/VBox/TabRow/DecorTabButton
@onready var feedback_label: Label = $Panel/Margin/VBox/FeedbackLabel
@onready var item_list: VBoxContainer = $Panel/Margin/VBox/ItemList
@onready var close_button: Button = $Panel/Margin/VBox/CloseButton
@onready var dimmer: ColorRect = $Dimmer

var _current_tab: Tab = Tab.FISH


func _ready() -> void:
	visible = false
	fish_tab_button.pressed.connect(_switch_tab.bind(Tab.FISH))
	decor_tab_button.pressed.connect(_switch_tab.bind(Tab.DECOR))
	close_button.pressed.connect(close)
	dimmer.gui_input.connect(_on_dimmer_input)


func open() -> void:
	visible = true
	_switch_tab(_current_tab)


func close() -> void:
	visible = false


func _on_dimmer_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()


func _switch_tab(tab: Tab) -> void:
	_current_tab = tab
	feedback_label.text = ""
	_refresh_list()


func _refresh_list() -> void:
	# remove_child() first so get_children() reflects the change immediately
	# (avoids stale-children bugs on back-to-back refreshes within one
	# frame), then queue_free() to actually destroy them — plain free()
	# can error if this ever runs from inside one of these buttons' own
	# "pressed" handler (Godot won't free an object mid-signal-call).
	for child in item_list.get_children():
		item_list.remove_child(child)
		child.queue_free()

	if shop_manager == null:
		return

	if _current_tab == Tab.FISH:
		for species in shop_manager.fish_catalog:
			_add_fish_row(species)
	else:
		for item in shop_manager.decor_catalog:
			_add_decor_row(item)


func _add_fish_row(species: FishSpecies) -> void:
	var unlocked := Shop.is_unlocked(species.level_requirement, PlayerData.level)
	var button := Button.new()
	if unlocked:
		var currency_label := "gems" if species.currency_type == DecorItem.CurrencyType.GEM else "coins"
		button.text = "%s — %d %s" % [species.display_name, species.base_price, currency_label]
		button.pressed.connect(_attempt_purchase_fish.bind(species))
	else:
		button.text = "Locked: %s (requires level %d)" % [species.display_name, species.level_requirement]
		button.disabled = true
	item_list.add_child(button)


func _add_decor_row(item: DecorItem) -> void:
	var unlocked := Shop.is_unlocked(item.level_requirement, PlayerData.level)
	var button := Button.new()
	if unlocked:
		var currency_label := "gems" if item.currency_type == DecorItem.CurrencyType.GEM else "coins"
		button.text = "%s — %d %s" % [item.display_name, item.price, currency_label]
		button.pressed.connect(_attempt_purchase_decor.bind(item))
	else:
		button.text = "Locked: %s (requires level %d)" % [item.display_name, item.level_requirement]
		button.disabled = true
	item_list.add_child(button)


func _attempt_purchase_fish(species: FishSpecies) -> void:
	if shop_manager.purchase_fish(species):
		feedback_label.text = "Purchased %s!" % species.display_name
	else:
		feedback_label.text = "Can't afford %s." % species.display_name


func _attempt_purchase_decor(item: DecorItem) -> void:
	if shop_manager.purchase_decor(item):
		feedback_label.text = "Purchased %s!" % item.display_name
	else:
		feedback_label.text = "Can't afford %s." % item.display_name
