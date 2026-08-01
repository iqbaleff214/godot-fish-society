extends Node
## Autoload: single source of truth for player save data
## (currency, level/XP, owned fish/decor, quest progress).
## Fields added per-feature as later tasks need them (see TASKS.md Phase 1).

## Each entry: {"species_id": String, "name": String}. Stats aren't persisted
## yet (TASKS.md 3.5 stubs to FishStats defaults) — that's task 8's job.
var owned_fish: Array[Dictionary] = []

## Owned-but-unplaced decor (TASKS.md 5.4). Duplicates are fine — owning
## multiple copies of the same DecorItem is valid, each entry is just a
## reference to the shared .tres template (no per-instance state to track).
var inventory: Array[DecorItem] = []

var coins: int = 0
var gems: int = 0

## Minimal stub for TASKS.md 5.3's shop level-gating — task 6.1 owns the
## real XP curve/level-up flow and will formalize this further.
var level: int = 1


func add_coins(amount: int) -> void:
	coins += amount
	EventBus.currency_changed.emit(DecorItem.CurrencyType.COIN, coins)


func add_gems(amount: int) -> void:
	gems += amount
	EventBus.currency_changed.emit(DecorItem.CurrencyType.GEM, gems)


## Returns false (balance unchanged) if amount exceeds the current balance —
## coins/gems never go negative.
func spend_coins(amount: int) -> bool:
	if amount > coins:
		return false
	coins -= amount
	EventBus.currency_changed.emit(DecorItem.CurrencyType.COIN, coins)
	return true


func spend_gems(amount: int) -> bool:
	if amount > gems:
		return false
	gems -= amount
	EventBus.currency_changed.emit(DecorItem.CurrencyType.GEM, gems)
	return true


func add_to_inventory(item: DecorItem) -> void:
	inventory.append(item)


## Removes one occurrence of item from inventory. Returns false if none found.
func remove_from_inventory(item: DecorItem) -> bool:
	var idx := inventory.find(item)
	if idx == -1:
		return false
	inventory.remove_at(idx)
	return true
