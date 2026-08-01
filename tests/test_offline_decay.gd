extends GutTest
## Unit tests for OfflineDecay (TASKS.md 8.3).


func _make_save(hunger: float, happiness: float, cleanliness: float, last_saved: int) -> PlayerSave:
	var save := PlayerSave.new()
	save.owned_fish = [{
		"species_id": "guppy",
		"name": "Bubbles",
		"hunger": hunger,
		"happiness": happiness,
		"cleanliness_sensitivity": cleanliness,
	}]
	save.last_saved_unix_time = last_saved
	return save


func test_applies_direct_formula_for_elapsed_window() -> void:
	var save := _make_save(100.0, 100.0, 100.0, 0)
	var species := FishSpecies.new()
	species.hunger_decay_rate = 10.0
	species.happiness_decay_rate = 5.0
	var directory := {"guppy": species}

	OfflineDecay.apply(save, 3600, directory)  # exactly 1 hour elapsed

	assert_almost_eq(save.owned_fish[0]["hunger"], 90.0, 0.001)
	assert_almost_eq(save.owned_fish[0]["happiness"], 95.0, 0.001)
	assert_almost_eq(save.owned_fish[0]["cleanliness_sensitivity"], 98.0, 0.001)  # default decay rate


func test_matches_direct_formula_output_not_a_simulated_loop() -> void:
	# A long elapsed window should still match the single-shot formula
	# exactly (this is the whole point of "direct formula, not catch-up
	# loop") rather than drifting from repeated small steps.
	var save := _make_save(100.0, 100.0, 100.0, 0)
	var species := FishSpecies.new()
	species.hunger_decay_rate = 2.0
	species.happiness_decay_rate = 1.0
	var directory := {"guppy": species}

	var elapsed_hours := 30.0
	OfflineDecay.apply(save, int(elapsed_hours * 3600), directory)

	var expected_hunger: float = clampf(100.0 - 2.0 * elapsed_hours, 0.0, 100.0)
	assert_almost_eq(save.owned_fish[0]["hunger"], expected_hunger, 0.001)


func test_stats_clamp_at_zero_for_very_long_absence() -> void:
	var save := _make_save(50.0, 50.0, 50.0, 0)
	var species := FishSpecies.new()
	species.hunger_decay_rate = 100.0
	var directory := {"guppy": species}

	OfflineDecay.apply(save, 3600 * 24, directory)  # 24 hours

	assert_eq(save.owned_fish[0]["hunger"], 0.0)


func test_unknown_species_id_still_decays_with_default_rate() -> void:
	var save := _make_save(100.0, 100.0, 100.0, 0)
	OfflineDecay.apply(save, 3600, {})  # empty directory, species won't resolve
	assert_almost_eq(save.owned_fish[0]["hunger"], 99.0, 0.001)  # FishStats default rate 1.0/hr


func test_coin_accrual_respects_passive_income_cap() -> void:
	var save := PlayerSave.new()
	save.coins = 0
	save.last_saved_unix_time = 0
	for i in range(10):
		save.owned_fish.append({"species_id": "guppy", "hunger": 100.0, "happiness": 100.0, "cleanliness_sensitivity": 100.0})

	OfflineDecay.apply(save, 3600 * 100, {})  # huge elapsed window, would blow past the cap unclamped

	assert_eq(save.coins, PassiveIncome.MAX_COINS_PER_COLLECTION)


func test_no_negative_elapsed_time_if_clock_looks_backwards() -> void:
	var save := _make_save(50.0, 50.0, 50.0, 1000)
	OfflineDecay.apply(save, 500, {})  # "now" earlier than last_saved_unix_time
	# Should not restore/inflate stats from a negative elapsed window.
	assert_eq(save.owned_fish[0]["hunger"], 50.0)
