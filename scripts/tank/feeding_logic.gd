class_name FeedingLogic
extends RefCounted
## Pure "which fish gets this food" selection (TASKS.md 4.1).
## Only fish with hunger < hunger_threshold are eligible. Among eligible
## fish, nearest to food_position wins; ties (equal distance) are broken
## by lower hunger — the hungrier fish goes first.

static func select_target_fish(food_position: Vector2, fish_list: Array, hunger_threshold: float) -> Fish:
	var best: Fish = null
	var best_distance := INF
	for fish: Fish in fish_list:
		if fish.stats == null or fish.stats.hunger >= hunger_threshold:
			continue
		var d: float = fish.position.distance_to(food_position)
		if best == null or d < best_distance or (d == best_distance and fish.stats.hunger < best.stats.hunger):
			best = fish
			best_distance = d
	return best
