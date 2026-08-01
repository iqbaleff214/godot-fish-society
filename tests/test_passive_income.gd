extends GutTest
## Unit tests for PassiveIncome (TASKS.md 5.2).


func test_calculate_matches_formula() -> void:
	# 3 happy fish, 2 hours, rate 10/fish/hour -> 60, well under cap
	assert_eq(PassiveIncome.calculate(3, 2.0), 60)


func test_calculate_zero_fish_or_zero_hours_yields_zero() -> void:
	assert_eq(PassiveIncome.calculate(0, 5.0), 0)
	assert_eq(PassiveIncome.calculate(5, 0.0), 0)


func test_calculate_respects_cap() -> void:
	# 10 fish * 10/hr * 10 hours = 1000, way over the 200 cap
	assert_eq(PassiveIncome.calculate(10, 10.0), PassiveIncome.MAX_COINS_PER_COLLECTION)


func test_calculate_under_cap_not_clamped() -> void:
	# 1 fish * 10/hr * 5 hours = 50, under cap
	assert_eq(PassiveIncome.calculate(1, 5.0), 50)
