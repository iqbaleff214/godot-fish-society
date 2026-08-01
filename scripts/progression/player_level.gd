class_name PlayerLevel
extends RefCounted
## Pure XP-to-level resolution (TASKS.md 6.1).
## XP curve: level N requires (N-1) * XP_PER_LEVEL cumulative XP to reach —
## a simple linear/stepped curve, sufficient for MVP (e.g. with the default
## rate: level 2 at 50 XP, level 3 at 100 XP, level 4 at 150 XP, ...).

const XP_PER_LEVEL := 50


static func xp_required_for_level(level: int) -> int:
	return (level - 1) * XP_PER_LEVEL


## Given total accumulated xp, returns the level it corresponds to (>= 1).
static func level_for_xp(total_xp: int) -> int:
	var level := 1
	while total_xp >= xp_required_for_level(level + 1):
		level += 1
	return level
