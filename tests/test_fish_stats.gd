extends GutTest
## Unit tests for FishStats (TASKS.md 3.3).


func test_decay_reduces_stats_by_rate_over_one_hour() -> void:
	var stats := FishStats.new()
	stats.hunger_decay_per_hour = 10.0
	stats.happiness_decay_per_hour = 5.0
	stats.cleanliness_decay_per_hour = 2.0
	stats.decay(3600.0)
	assert_almost_eq(stats.hunger, 90.0, 0.001)
	assert_almost_eq(stats.happiness, 95.0, 0.001)
	assert_almost_eq(stats.cleanliness_sensitivity, 98.0, 0.001)


func test_decay_uses_species_rates_when_provided() -> void:
	var species := FishSpecies.new()
	species.hunger_decay_rate = 20.0
	species.happiness_decay_rate = 4.0
	var stats := FishStats.new(species)
	stats.decay(3600.0)
	assert_almost_eq(stats.hunger, 80.0, 0.001)
	assert_almost_eq(stats.happiness, 96.0, 0.001)


func test_decay_clamps_at_zero() -> void:
	var stats := FishStats.new()
	stats.hunger = 5.0
	stats.hunger_decay_per_hour = 1000.0
	stats.decay(3600.0)
	assert_eq(stats.hunger, 0.0)


func test_stat_clamps_at_one_hundred_after_feed() -> void:
	var stats := FishStats.new()
	stats.happiness = 99.0
	stats.apply_feed()
	assert_eq(stats.happiness, 100.0)


func test_apply_feed_restores_hunger_and_bumps_happiness() -> void:
	var stats := FishStats.new()
	stats.hunger = 40.0
	stats.happiness = 50.0
	stats.apply_feed()
	assert_eq(stats.hunger, 100.0)
	assert_almost_eq(stats.happiness, 55.0, 0.001)


func test_apply_pet_bumps_happiness_only() -> void:
	var stats := FishStats.new()
	stats.hunger = 40.0
	stats.happiness = 50.0
	stats.apply_pet()
	assert_eq(stats.hunger, 40.0)
	assert_almost_eq(stats.happiness, 53.0, 0.001)


func test_apply_cleanliness_sets_and_clamps() -> void:
	var stats := FishStats.new()
	stats.apply_cleanliness(150.0)
	assert_eq(stats.cleanliness_sensitivity, 100.0)
	stats.apply_cleanliness(-10.0)
	assert_eq(stats.cleanliness_sensitivity, 0.0)
