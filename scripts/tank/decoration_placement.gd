class_name DecorationPlacement
extends RefCounted
## Pure overlap-detection utility for decor placement (TASKS.md 2.3).
## Edge-touching rects (sharing only a boundary, zero area overlap) count as valid.

static func rects_overlap(a: Rect2, b: Rect2) -> bool:
	return a.position.x < b.position.x + b.size.x \
		and a.position.x + a.size.x > b.position.x \
		and a.position.y < b.position.y + b.size.y \
		and a.position.y + a.size.y > b.position.y


static func is_valid_placement(candidate: Rect2, others: Array[Rect2]) -> bool:
	for other in others:
		if rects_overlap(candidate, other):
			return false
	return true
