class_name PlayerSave
extends RefCounted
## Serializable save-data shape (TASKS.md 8.1). Mirrors PlayerData's fields
## as plain JSON-compatible data (Dictionaries/Arrays/numbers/strings) —
## Resource references (FishSpecies/DecorItem) are stored as id strings and
## re-resolved via FishSpecies.load_all()/DecorItem.load_all() on load, the
## same convention PlayerData.owned_fish already used (task 3.5). Converting
## to/from live PlayerData state is SaveManager's job (TASKS.md 8.2) — this
## class only knows about its own plain-data shape, so the round-trip is
## testable without a scene tree or autoloads.
##
## Schema:
##   tank_layout: Array[{"item_id": String, "position_x": float, "position_y": float}]
##   owned_fish: Array[{"species_id": String, "name": String, "hunger": float,
##                       "happiness": float, "cleanliness_sensitivity": float}]
##   inventory: Array[String]  (DecorItem ids, duplicates allowed)
##   coins: int
##   gems: int
##   level: int
##   xp: int
##   quest_progress: Dictionary  (quest_id -> {"count": int, "completed": bool})
##   last_saved_unix_time: int

var tank_layout: Array[Dictionary] = []
var owned_fish: Array[Dictionary] = []
var inventory: Array[String] = []
var coins: int = 0
var gems: int = 0
var level: int = 1
var xp: int = 0
var quest_progress: Dictionary = {}
var last_saved_unix_time: int = 0


func to_dict() -> Dictionary:
	return {
		"tank_layout": tank_layout,
		"owned_fish": owned_fish,
		"inventory": inventory,
		"coins": coins,
		"gems": gems,
		"level": level,
		"xp": xp,
		"quest_progress": quest_progress,
		"last_saved_unix_time": last_saved_unix_time,
	}


static func from_dict(data: Dictionary) -> PlayerSave:
	var save := PlayerSave.new()
	save.tank_layout = _to_dict_array(data.get("tank_layout", []))
	save.owned_fish = _to_dict_array(data.get("owned_fish", []))
	save.inventory = _to_string_array(data.get("inventory", []))
	# int() casts: JSON.parse_string() returns all numbers as float, so
	# without these these fields would silently hold float values.
	save.coins = int(data.get("coins", 0))
	save.gems = int(data.get("gems", 0))
	save.level = int(data.get("level", 1))
	save.xp = int(data.get("xp", 0))
	save.quest_progress = _normalize_quest_progress(data.get("quest_progress", {}))
	save.last_saved_unix_time = int(data.get("last_saved_unix_time", 0))
	return save


## Same float-from-JSON issue as the int casts above, one level deeper —
## quest_progress's nested "count" values need normalizing too.
static func _normalize_quest_progress(value: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for quest_id in value:
		var entry = value[quest_id]
		if entry is Dictionary:
			result[quest_id] = {
				"count": int(entry.get("count", 0)),
				"completed": bool(entry.get("completed", false)),
			}
	return result


## JSON.parse_string() returns loosely-typed Array/Dictionary (Variant
## elements) — Godot won't implicitly narrow those to Array[Dictionary]/
## Array[String] on assignment, so this converts element by element.
static func _to_dict_array(value: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in value:
		if entry is Dictionary:
			result.append(entry)
	return result


static func _to_string_array(value: Array) -> Array[String]:
	var result: Array[String] = []
	for entry in value:
		result.append(str(entry))
	return result
