extends Node2D
## Root gameplay scene (TASKS.md 2.2). Wires cross-references between
## sibling managers and the HUD's panels after everything's instanced —
## simpler and less fragile than NodePath math tied to exact nesting depth.

@onready var tank_manager: TankManager = $TankManager
@onready var shop_manager: ShopManager = $ShopManager
@onready var hud: HUD = $HUDAnchor/HUD


func _ready() -> void:
	hud.shop_ui.shop_manager = shop_manager
	hud.inventory_ui.tank_manager = tank_manager
