extends GutTest
## Unit tests for Tank (TASKS.md 2.1).


func test_get_water_bounds_returns_configured_rect() -> void:
	var tank := Tank.new()
	tank.water_bounds = Rect2(Vector2(5, 10), Vector2(300, 150))
	assert_eq(tank.get_water_bounds(), Rect2(Vector2(5, 10), Vector2(300, 150)))
	tank.free()


func test_get_floor_y_returns_configured_value() -> void:
	var tank := Tank.new()
	tank.floor_y = 123.0
	assert_eq(tank.get_floor_y(), 123.0)
	tank.free()
