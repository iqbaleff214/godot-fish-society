class_name FishSteering
extends RefCounted
## Pure swim-steering math: target movement + bounds clamping (TASKS.md 3.2).

static func clamp_to_bounds(point: Vector2, bounds: Rect2) -> Vector2:
	return Vector2(
		clampf(point.x, bounds.position.x, bounds.position.x + bounds.size.x),
		clampf(point.y, bounds.position.y, bounds.position.y + bounds.size.y)
	)


static func move_toward_point(current: Vector2, target: Vector2, max_distance: float) -> Vector2:
	return current.move_toward(target, max_distance)
