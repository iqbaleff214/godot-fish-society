extends GutTest
## Unit tests for FishSteering (TASKS.md 3.2).


func test_clamp_to_bounds_point_inside_unchanged() -> void:
	var b := Rect2(0, 0, 100, 50)
	assert_eq(FishSteering.clamp_to_bounds(Vector2(50, 25), b), Vector2(50, 25))


func test_clamp_to_bounds_point_outside_clamped() -> void:
	var b := Rect2(0, 0, 100, 50)
	assert_eq(FishSteering.clamp_to_bounds(Vector2(150, -10), b), Vector2(100, 0))


func test_clamp_to_bounds_point_on_edge_unchanged() -> void:
	var b := Rect2(0, 0, 100, 50)
	assert_eq(FishSteering.clamp_to_bounds(Vector2(100, 50), b), Vector2(100, 50))


func test_clamp_to_bounds_with_nonzero_origin() -> void:
	var b := Rect2(10, 20, 100, 50)
	assert_eq(FishSteering.clamp_to_bounds(Vector2(0, 0), b), Vector2(10, 20))


func test_move_toward_point_reaches_partway_without_overshoot() -> void:
	var result := FishSteering.move_toward_point(Vector2(0, 0), Vector2(10, 0), 5.0)
	assert_eq(result, Vector2(5, 0))


func test_move_toward_point_does_not_overshoot_when_close() -> void:
	var result := FishSteering.move_toward_point(Vector2(0, 0), Vector2(2, 0), 5.0)
	assert_eq(result, Vector2(2, 0))
