extends GutTest
## Unit tests for PlayerLevel XP curve (TASKS.md 6.1).


func test_xp_required_for_level_one_is_zero() -> void:
	assert_eq(PlayerLevel.xp_required_for_level(1), 0)


func test_xp_required_for_level_two() -> void:
	assert_eq(PlayerLevel.xp_required_for_level(2), PlayerLevel.XP_PER_LEVEL)


func test_level_for_xp_zero_is_level_one() -> void:
	assert_eq(PlayerLevel.level_for_xp(0), 1)


func test_level_for_xp_just_under_threshold_stays_previous_level() -> void:
	var xp := PlayerLevel.xp_required_for_level(2) - 1
	assert_eq(PlayerLevel.level_for_xp(xp), 1)


func test_level_for_xp_exactly_at_threshold_advances() -> void:
	var xp := PlayerLevel.xp_required_for_level(2)
	assert_eq(PlayerLevel.level_for_xp(xp), 2)


func test_level_for_xp_crossing_multiple_levels() -> void:
	var xp := PlayerLevel.xp_required_for_level(5)
	assert_eq(PlayerLevel.level_for_xp(xp), 5)
