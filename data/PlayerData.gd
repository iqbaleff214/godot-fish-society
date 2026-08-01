extends Node
## Autoload: single source of truth for player save data
## (currency, level/XP, owned fish/decor, quest progress).
## Fields added per-feature as later tasks need them (see TASKS.md Phase 1).

## Each entry: {"species_id": String, "name": String, "hunger": float,
## "happiness": float, "cleanliness_sensitivity": float}. The stat keys are
## optional (TankManager.resolve_spawn_list defaults to 100.0 for each when
## absent) so freshly-purchased fish (ShopManager) can keep appending the
## bare {"species_id", "name"} shape unchanged (TASKS.md 8.1).
##
## Defaults to one starter Guppy — task 8.2's own DoD calls for "sensible
## defaults (starter fish, zero currency)" on a fresh install. This default
## only ever takes effect when no save file exists yet: SaveManager.load_game()
## overwrites it with the real saved array (however many/few fish that is)
## whenever a save is actually found (TASKS.md 8.2/9.1 — without this, a
## brand new player has 0 fish and 0 coins and cannot do anything at all).
var owned_fish: Array[Dictionary] = [
	{"species_id": "guppy", "name": "Guppy"},
]

## Placed decor layout — TankManager is the live source of truth while a
## tank is loaded; SaveManager refreshes this from it before writing a save
## and restores it via TankManager on load (TASKS.md 8.1/8.2). Each entry:
## {"item_id": String, "position_x": float, "position_y": float}.
var tank_layout: Array[Dictionary] = []

## Owned-but-unplaced decor (TASKS.md 5.4). Duplicates are fine — owning
## multiple copies of the same DecorItem is valid, each entry is just a
## reference to the shared .tres template (no per-instance state to track).
var inventory: Array[DecorItem] = []

var coins: int = 0
var gems: int = 0

var level: int = 1
var xp: int = 0

## Small fixed XP rewards for care actions (GDD § 4.4). Quest rewards
## (TASKS.md 6.2) are per-quest data instead, via QuestDefinition.
const FEED_XP_REWARD := 2
const PET_XP_REWARD := 1
const CLEAN_XP_REWARD := 3

## Static content — quest definitions loaded once from resources/quests/*.tres.
var quest_definitions: Array[QuestDefinition] = []

## quest_id (String) -> {"count": int, "completed": bool}
var quest_progress: Dictionary = {}


func _ready() -> void:
	quest_definitions = QuestDefinition.load_all()
	EventBus.fish_fed.connect(_on_fish_fed)
	EventBus.fish_petted.connect(_on_fish_petted)
	EventBus.tank_cleaned.connect(_on_tank_cleaned)
	EventBus.decor_placed.connect(_on_decor_placed)


## Applies amount to xp, then advances level one step at a time so
## EventBus.level_up fires once per threshold crossed even if this single
## grant jumps multiple levels (TASKS.md 6.1).
func add_xp(amount: int) -> void:
	xp += amount
	var new_level := PlayerLevel.level_for_xp(xp)
	while level < new_level:
		level += 1
		EventBus.level_up.emit(level)


func _on_fish_fed(_fish: Fish) -> void:
	add_xp(FEED_XP_REWARD)
	_record_quest_event(QuestDefinition.TrackedEvent.FISH_FED)


func _on_fish_petted(_fish: Fish) -> void:
	add_xp(PET_XP_REWARD)
	_record_quest_event(QuestDefinition.TrackedEvent.FISH_PETTED)


func _on_tank_cleaned() -> void:
	add_xp(CLEAN_XP_REWARD)
	_record_quest_event(QuestDefinition.TrackedEvent.TANK_CLEANED)


func _on_decor_placed(_item: DecorItem) -> void:
	_record_quest_event(QuestDefinition.TrackedEvent.DECOR_PLACED)


## Updates progress on every quest tracking event_type, granting reward
## exactly once at the not-completed -> completed transition (TASKS.md 6.2).
func _record_quest_event(event_type: QuestDefinition.TrackedEvent) -> void:
	for quest in quest_definitions:
		var before: Dictionary = quest_progress.get(quest.id, {"count": 0, "completed": false})
		var after := QuestTracker.record_event(before, quest, event_type)
		quest_progress[quest.id] = after
		if after.get("completed", false) and not before.get("completed", false):
			add_coins(quest.reward_coins)
			add_xp(quest.reward_xp)
			EventBus.quest_completed.emit(quest)


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
