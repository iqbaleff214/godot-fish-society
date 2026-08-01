class_name InventoryUI
extends Control
## Inventory panel (TASKS.md 5.4/7.3) that doubles as the Decorate Mode UI
## (TASKS.md 7.4): selecting an item places it in the tank at a default
## position, then Decoration's own drag-to-reposition (gated on
## GameState.decorate_mode_active, TASKS.md 2.3/7.4) lets the player fine
## -tune it. Closing this panel exits Decorate Mode (HUD listens for
## `closed`) — "persists layout to PlayerData" per the 7.4 DoD has nothing
## to persist to yet (task 8.1 owns the save schema), so there's no explicit
## save call here; the tank's live node state already reflects the layout.

signal closed

const DEFAULT_PLACEMENT_POSITION := Vector2(200, 150)

## Assigned externally by tank_view.gd after instancing (TASKS.md 7.1).
var tank_manager: TankManager

@onready var dimmer: ColorRect = $Dimmer
@onready var item_list: VBoxContainer = $Panel/Margin/VBox/ItemList
@onready var empty_label: Label = $Panel/Margin/VBox/EmptyLabel
@onready var done_button: Button = $Panel/Margin/VBox/DoneButton


func _ready() -> void:
	visible = false
	done_button.pressed.connect(close)
	dimmer.gui_input.connect(_on_dimmer_input)


func open() -> void:
	visible = true
	_refresh_list()


func close() -> void:
	visible = false
	closed.emit()


func _on_dimmer_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()


func _refresh_list() -> void:
	# remove_child() first so get_children() reflects the change immediately
	# (avoids stale-children bugs on back-to-back refreshes within one
	# frame — see ShopUI's _refresh_list), then queue_free() to actually
	# destroy them — plain free() would error here since this can run from
	# inside the very button's own "pressed" signal handler (_place_item),
	# and Godot won't free an object still processing a signal call.
	for child in item_list.get_children():
		item_list.remove_child(child)
		child.queue_free()

	empty_label.visible = PlayerData.inventory.is_empty()

	for item: DecorItem in PlayerData.inventory:
		_add_item_row(item)


func _add_item_row(item: DecorItem) -> void:
	var button := Button.new()
	button.text = "Place: %s" % item.display_name
	button.pressed.connect(_place_item.bind(item))
	item_list.add_child(button)


func _place_item(item: DecorItem) -> void:
	if tank_manager == null:
		return
	tank_manager.place_decor_from_inventory(item, DEFAULT_PLACEMENT_POSITION)
	_refresh_list()
