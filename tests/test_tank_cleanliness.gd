extends GutTest
## Unit tests for TankCleanliness (TASKS.md 4.2).


func test_decay_reduces_cleanliness_over_one_hour() -> void:
	var tc := TankCleanliness.new()
	tc.decay(3600.0)
	assert_almost_eq(tc.cleanliness, 95.0, 0.001)


func test_decay_clamps_at_zero() -> void:
	var tc := TankCleanliness.new()
	tc.cleanliness = 1.0
	tc.decay(3600.0 * 10)  # far more than enough to drive it negative unclamped
	assert_eq(tc.cleanliness, 0.0)


func test_cleaning_crew_offsets_decay_rate() -> void:
	var tc := TankCleanliness.new()
	# 5 crew members * 1.0/hr regen fully cancels the 5.0/hr base decay.
	tc.decay(3600.0, 5)
	assert_almost_eq(tc.cleanliness, 100.0, 0.001)


func test_cleaning_crew_can_net_positive_but_still_clamped_at_hundred() -> void:
	var tc := TankCleanliness.new()
	tc.decay(3600.0, 10)  # net rate goes negative (regen > decay)
	assert_eq(tc.cleanliness, 100.0)


func test_clean_restores_to_full() -> void:
	var tc := TankCleanliness.new()
	tc.cleanliness = 10.0
	tc.clean()
	assert_eq(tc.cleanliness, 100.0)
