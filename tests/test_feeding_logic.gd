extends GutTest
## Unit tests for FeedingLogic.select_target_fish (TASKS.md 4.1).
## Fish.new() without add_child/setup() is safe here — only .position and
## .stats (manually assigned) are touched, no @onready/scene-tree state.


func _make_fish(pos: Vector2, hunger: float) -> Fish:
	var fish: Fish = autofree(Fish.new())
	fish.position = pos
	fish.stats = FishStats.new()
	fish.stats.hunger = hunger
	return fish


func test_selects_nearest_eligible_fish() -> void:
	var near := _make_fish(Vector2(10, 0), 50.0)
	var far := _make_fish(Vector2(100, 0), 50.0)
	var result := FeedingLogic.select_target_fish(Vector2(0, 0), [far, near], 90.0)
	assert_eq(result, near)


func test_ignores_fish_at_or_above_threshold() -> void:
	var full := _make_fish(Vector2(1, 0), 95.0)
	var hungry := _make_fish(Vector2(50, 0), 50.0)
	var result := FeedingLogic.select_target_fish(Vector2(0, 0), [full, hungry], 90.0)
	assert_eq(result, hungry)


func test_threshold_is_exclusive_at_boundary() -> void:
	var at_threshold := _make_fish(Vector2(1, 0), 90.0)
	var result := FeedingLogic.select_target_fish(Vector2(0, 0), [at_threshold], 90.0)
	assert_null(result)


func test_returns_null_when_no_fish_eligible() -> void:
	var full := _make_fish(Vector2(1, 0), 100.0)
	var result := FeedingLogic.select_target_fish(Vector2(0, 0), [full], 90.0)
	assert_null(result)


func test_ties_broken_by_lower_hunger() -> void:
	var a := _make_fish(Vector2(10, 0), 60.0)
	var b := _make_fish(Vector2(10, 0), 30.0)  # same distance, hungrier
	var result := FeedingLogic.select_target_fish(Vector2(0, 0), [a, b], 90.0)
	assert_eq(result, b)


func test_empty_list_returns_null() -> void:
	var result := FeedingLogic.select_target_fish(Vector2(0, 0), [], 90.0)
	assert_null(result)
