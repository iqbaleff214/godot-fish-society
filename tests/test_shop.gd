extends GutTest
## Unit tests for Shop catalog filtering + affordability (TASKS.md 5.3).


func _make_fish(level_req: int) -> FishSpecies:
	var s := FishSpecies.new()
	s.level_requirement = level_req
	return s


func _make_decor(level_req: int) -> DecorItem:
	var d := DecorItem.new()
	d.level_requirement = level_req
	return d


func test_is_unlocked_true_when_level_meets_requirement() -> void:
	assert_true(Shop.is_unlocked(3, 3))


func test_is_unlocked_true_when_level_exceeds_requirement() -> void:
	assert_true(Shop.is_unlocked(3, 5))


func test_is_unlocked_false_when_level_below_requirement() -> void:
	assert_false(Shop.is_unlocked(3, 2))


func test_filter_unlocked_fish_excludes_locked() -> void:
	var a := _make_fish(1)
	var b := _make_fish(5)
	var result := Shop.filter_unlocked_fish([a, b], 2)
	assert_eq(result.size(), 1)
	assert_eq(result[0], a)


func test_filter_unlocked_decor_excludes_locked() -> void:
	var a := _make_decor(1)
	var b := _make_decor(5)
	var result := Shop.filter_unlocked_decor([a, b], 2)
	assert_eq(result.size(), 1)
	assert_eq(result[0], a)


func test_can_afford_coin_item_sufficient() -> void:
	assert_true(Shop.can_afford(50, DecorItem.CurrencyType.COIN, 100, 0))


func test_can_afford_coin_item_insufficient() -> void:
	assert_false(Shop.can_afford(150, DecorItem.CurrencyType.COIN, 100, 0))


func test_can_afford_gem_item_checks_gems_not_coins() -> void:
	assert_true(Shop.can_afford(5, DecorItem.CurrencyType.GEM, 0, 10))
	assert_false(Shop.can_afford(5, DecorItem.CurrencyType.GEM, 1000, 2))
