class_name ShopManager
extends Node
## Purchase flow for fish/decor from the shop catalog (TASKS.md 5.3).
## Catalog is auto-built from resources/fish_species/ and
## resources/decor_items/ via FishSpecies.load_all()/DecorItem.load_all().
## NOTE: GDD § 4.3 describes a "Food" shop tab too, but no purchasable
## FoodItem Resource type exists in the data layer (task 1.x never defined
## one) — deferred; this shop only covers Fish and Decor.

## Fires tank_manager_path == NodePath() (unset) if this ShopManager isn't
## scoped to a tank (e.g. used from a non-gameplay menu later) — purchase_fish
## still works, it just won't live-spawn into a tank.
@export var tank_manager_path: NodePath = ^"../TankManager"
@onready var tank_manager: TankManager = get_node_or_null(tank_manager_path)

var fish_catalog: Array[FishSpecies] = []
var decor_catalog: Array[DecorItem] = []


func _ready() -> void:
	fish_catalog = FishSpecies.load_all()
	decor_catalog = DecorItem.load_all()


## Returns true on success. Fails (no state changed) if locked or unaffordable.
func purchase_fish(species: FishSpecies) -> bool:
	if not Shop.is_unlocked(species.level_requirement, PlayerData.level):
		return false
	if not Shop.can_afford(species.base_price, species.currency_type, PlayerData.coins, PlayerData.gems):
		return false
	if not _spend(species.base_price, species.currency_type):
		return false

	var fish_name := species.display_name
	PlayerData.owned_fish.append({"species_id": species.id, "name": fish_name})
	if tank_manager != null:
		tank_manager.spawn_fish(species, fish_name)
	EventBus.item_purchased.emit()
	return true


func purchase_decor(item: DecorItem) -> bool:
	if not Shop.is_unlocked(item.level_requirement, PlayerData.level):
		return false
	if not Shop.can_afford(item.price, item.currency_type, PlayerData.coins, PlayerData.gems):
		return false
	if not _spend(item.price, item.currency_type):
		return false

	PlayerData.add_to_inventory(item)
	EventBus.item_purchased.emit()
	return true


func _spend(amount: int, currency_type: DecorItem.CurrencyType) -> bool:
	if currency_type == DecorItem.CurrencyType.GEM:
		return PlayerData.spend_gems(amount)
	return PlayerData.spend_coins(amount)
