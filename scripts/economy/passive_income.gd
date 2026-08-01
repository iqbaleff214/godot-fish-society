class_name PassiveIncome
extends RefCounted
## Pure passive coin-generation formula (TASKS.md 5.2). Coins accrue per
## happy fish per elapsed hour, capped per collection so leaving the game
## idle for a long time doesn't generate unbounded coins. Meant to be
## applied via elapsed-time-since-last-collection (same load-time-delta
## pattern task 8.3 uses for stat decay), not a live per-frame timer —
## actually wiring "last collected" persistence is task 8's job.

const COINS_PER_HAPPY_FISH_PER_HOUR := 10
const MAX_COINS_PER_COLLECTION := 200


static func calculate(happy_fish_count: int, elapsed_hours: float) -> int:
	var raw := int(COINS_PER_HAPPY_FISH_PER_HOUR * happy_fish_count * elapsed_hours)
	return mini(raw, MAX_COINS_PER_COLLECTION)
