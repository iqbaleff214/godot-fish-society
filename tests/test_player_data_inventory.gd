extends GutTest
## Unit tests for PlayerData.inventory (TASKS.md 5.4).


func before_each() -> void:
	PlayerData.inventory.clear()


func after_each() -> void:
	PlayerData.inventory.clear()


func test_add_to_inventory_appends() -> void:
	var item := DecorItem.new()
	item.id = "test_item"
	PlayerData.add_to_inventory(item)
	assert_eq(PlayerData.inventory.size(), 1)
	assert_eq(PlayerData.inventory[0], item)


func test_remove_from_inventory_removes_one_occurrence() -> void:
	var item := DecorItem.new()
	PlayerData.add_to_inventory(item)
	PlayerData.add_to_inventory(item)
	var result := PlayerData.remove_from_inventory(item)
	assert_true(result)
	assert_eq(PlayerData.inventory.size(), 1)


func test_remove_from_inventory_returns_false_when_not_present() -> void:
	var item := DecorItem.new()
	var result := PlayerData.remove_from_inventory(item)
	assert_false(result)
