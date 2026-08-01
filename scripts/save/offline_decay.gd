class_name OfflineDecay
extends RefCounted
## Applies elapsed-real-time stat decay and passive-coin accrual to a
## PlayerSave in one direct formula application — not a simulated
## catch-up loop (TASKS.md 8.3). Mutates and returns the same PlayerSave.
##
## "Happy fish" for the passive-income calculation (task 5.2) is judged
## from each fish's PRE-decay saved mood (i.e. however the game was left),
## not simulated minute-by-minute across the elapsed window — consistent
## with PassiveIncome.calculate()'s own flat-rate-over-elapsed-hours model.

static func apply(save: PlayerSave, now_unix_time: int, species_directory: Dictionary) -> PlayerSave:
	var elapsed_seconds: float = maxf(0.0, float(now_unix_time - save.last_saved_unix_time))

	var happy_fish_count := 0
	for entry in save.owned_fish:
		var saved_hunger: float = entry.get("hunger", 100.0)
		var saved_happiness: float = entry.get("happiness", 100.0)
		if FishMood.derive(saved_hunger, saved_happiness) == FishMood.Mood.HAPPY:
			happy_fish_count += 1

		var species: FishSpecies = species_directory.get(entry.get("species_id", ""))
		var stats := FishStats.new(species)
		stats.hunger = saved_hunger
		stats.happiness = saved_happiness
		stats.cleanliness_sensitivity = entry.get("cleanliness_sensitivity", 100.0)
		stats.decay(elapsed_seconds)

		entry["hunger"] = stats.hunger
		entry["happiness"] = stats.happiness
		entry["cleanliness_sensitivity"] = stats.cleanliness_sensitivity

	var elapsed_hours := elapsed_seconds / 3600.0
	save.coins += PassiveIncome.calculate(happy_fish_count, elapsed_hours)

	return save
