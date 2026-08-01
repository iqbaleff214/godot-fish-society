extends GutTest
## Unit tests for ShopManager purchase flow (TASKS.md 5.3).
## ShopManager.new() without add_child() leaves tank_manager null (its
## @onready never fires) — fine here since these tests only exercise the
## PlayerData-mutating purchase logic, guarded by "if tank_manager != null".


func before_each() -> void:
	PlayerData.coins = 0
	PlayerData.gems = 0
	PlayerData.level = 1
	PlayerData.owned_fish.clear()
	PlayerData.inventory.clear()


func after_each() -> void:
	PlayerData.coins = 0
	PlayerData.gems = 0
	PlayerData.level = 1
	PlayerData.owned_fish.clear()
	PlayerData.inventory.clear()


func test_purchase_fish_fails_when_locked() -> void:
	var manager := ShopManager.new()
	var species := FishSpecies.new()
	species.level_requirement = 5
	species.base_price = 10
	PlayerData.coins = 1000
	var result := manager.purchase_fish(species)
	assert_false(result)
	assert_eq(PlayerData.coins, 1000)
	assert_eq(PlayerData.owned_fish.size(), 0)
	manager.free()


func test_purchase_fish_fails_when_unaffordable() -> void:
	var manager := ShopManager.new()
	var species := FishSpecies.new()
	species.level_requirement = 1
	species.base_price = 500
	PlayerData.coins = 10
	var result := manager.purchase_fish(species)
	assert_false(result)
	assert_eq(PlayerData.coins, 10)
	assert_eq(PlayerData.owned_fish.size(), 0)
	manager.free()


func test_purchase_fish_succeeds_deducts_coins_and_adds_to_owned() -> void:
	var manager := ShopManager.new()
	var species := FishSpecies.new()
	species.id = "test_fish"
	species.display_name = "Test Fish"
	species.level_requirement = 1
	species.base_price = 30
	species.currency_type = DecorItem.CurrencyType.COIN
	PlayerData.coins = 100
	var result := manager.purchase_fish(species)
	assert_true(result)
	assert_eq(PlayerData.coins, 70)
	assert_eq(PlayerData.owned_fish.size(), 1)
	assert_eq(PlayerData.owned_fish[0]["species_id"], "test_fish")
	manager.free()


func test_purchase_fish_with_gem_currency_deducts_gems_not_coins() -> void:
	var manager := ShopManager.new()
	var species := FishSpecies.new()
	species.id = "rare_fish"
	species.level_requirement = 1
	species.base_price = 20
	species.currency_type = DecorItem.CurrencyType.GEM
	PlayerData.coins = 1000
	PlayerData.gems = 25
	var result := manager.purchase_fish(species)
	assert_true(result)
	assert_eq(PlayerData.gems, 5)
	assert_eq(PlayerData.coins, 1000)
	manager.free()


func test_purchase_decor_succeeds_deducts_coins_and_adds_to_inventory() -> void:
	var manager := ShopManager.new()
	var item := DecorItem.new()
	item.id = "test_decor"
	item.level_requirement = 1
	item.price = 20
	item.currency_type = DecorItem.CurrencyType.COIN
	PlayerData.coins = 50
	var result := manager.purchase_decor(item)
	assert_true(result)
	assert_eq(PlayerData.coins, 30)
	assert_eq(PlayerData.inventory.size(), 1)
	assert_eq(PlayerData.inventory[0], item)
	manager.free()


func test_purchase_decor_fails_when_locked_and_inventory_unchanged() -> void:
	var manager := ShopManager.new()
	var item := DecorItem.new()
	item.level_requirement = 3
	item.price = 5
	PlayerData.coins = 1000
	var result := manager.purchase_decor(item)
	assert_false(result)
	assert_eq(PlayerData.inventory.size(), 0)
	manager.free()


func test_purchase_decor_fails_when_unaffordable_and_inventory_unchanged() -> void:
	var manager := ShopManager.new()
	var item := DecorItem.new()
	item.level_requirement = 1
	item.price = 500
	PlayerData.coins = 5
	var result := manager.purchase_decor(item)
	assert_false(result)
	assert_eq(PlayerData.inventory.size(), 0)
	manager.free()
