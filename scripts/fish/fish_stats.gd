class_name FishStats
extends RefCounted
## Pure hunger/happiness/cleanliness-sensitivity tracker for one fish (TASKS.md 3.3).
## hunger_decay_per_hour / happiness_decay_per_hour come from FishSpecies.
## FishSpecies has no per-species cleanliness decay rate, so
## cleanliness_sensitivity always decays at DEFAULT_CLEANLINESS_DECAY_PER_HOUR.
## All three stats stay clamped to [0, 100]; there is no "dead" state.

const DEFAULT_CLEANLINESS_DECAY_PER_HOUR := 2.0
const FEED_HAPPINESS_BUMP := 5.0
const PET_HAPPINESS_BUMP := 3.0

var hunger: float = 100.0
var happiness: float = 100.0
var cleanliness_sensitivity: float = 100.0

var hunger_decay_per_hour: float = 1.0
var happiness_decay_per_hour: float = 1.0
var cleanliness_decay_per_hour: float = DEFAULT_CLEANLINESS_DECAY_PER_HOUR


func _init(species: FishSpecies = null) -> void:
	if species != null:
		hunger_decay_per_hour = species.hunger_decay_rate
		happiness_decay_per_hour = species.happiness_decay_rate


func decay(delta_seconds: float) -> void:
	var hours := delta_seconds / 3600.0
	hunger = clampf(hunger - hunger_decay_per_hour * hours, 0.0, 100.0)
	happiness = clampf(happiness - happiness_decay_per_hour * hours, 0.0, 100.0)
	cleanliness_sensitivity = clampf(cleanliness_sensitivity - cleanliness_decay_per_hour * hours, 0.0, 100.0)


func apply_feed() -> void:
	hunger = 100.0
	happiness = clampf(happiness + FEED_HAPPINESS_BUMP, 0.0, 100.0)


func apply_pet() -> void:
	happiness = clampf(happiness + PET_HAPPINESS_BUMP, 0.0, 100.0)


func apply_cleanliness(tank_cleanliness: float) -> void:
	cleanliness_sensitivity = clampf(tank_cleanliness, 0.0, 100.0)
