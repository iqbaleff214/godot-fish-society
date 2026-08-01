class_name TankCleanliness
extends RefCounted
## Pure tank-level cleanliness tracker (TASKS.md 4.2). Decays over real
## time; fully restored by the clean action; cleaning-crew fish
## (FishSpecies.is_cleaning_crew) each provide passive bonus regen that
## offsets the decay rate.

const DECAY_PER_HOUR := 5.0
const CLEAN_ACTION_RESTORE := 100.0
const CLEANING_CREW_REGEN_PER_HOUR := 1.0

var cleanliness: float = 100.0


func decay(delta_seconds: float, cleaning_crew_count: int = 0) -> void:
	var hours := delta_seconds / 3600.0
	var net_rate := DECAY_PER_HOUR - (CLEANING_CREW_REGEN_PER_HOUR * cleaning_crew_count)
	cleanliness = clampf(cleanliness - net_rate * hours, 0.0, 100.0)


func clean() -> void:
	cleanliness = CLEAN_ACTION_RESTORE
