class_name QuestDefinition
extends Resource
## Data definition for one quest (TASKS.md 6.2). New quests are added by
## duplicating a .tres of this type — no script changes needed, matching
## FishSpecies/DecorItem's data-driven pattern (GDD § 7.3).

enum TrackedEvent { FISH_FED, FISH_PETTED, TANK_CLEANED, DECOR_PLACED }

@export var id: String = ""
@export var title: String = ""
@export var tracked_event: TrackedEvent = TrackedEvent.FISH_FED
@export var target_count: int = 1
@export var reward_coins: int = 0
@export var reward_xp: int = 0


## Loads every QuestDefinition .tres under resources/quests/.
static func load_all() -> Array[QuestDefinition]:
	var result: Array[QuestDefinition] = []
	var dir := DirAccess.open("res://resources/quests")
	if dir == null:
		return result
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var quest: QuestDefinition = load("res://resources/quests/" + file_name)
			if quest != null:
				result.append(quest)
		file_name = dir.get_next()
	dir.list_dir_end()
	return result
