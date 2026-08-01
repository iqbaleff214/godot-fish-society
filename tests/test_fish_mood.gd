extends GutTest
## Table-driven unit tests for FishMood thresholds (TASKS.md 3.4).


func test_mood_thresholds() -> void:
	var cases := [
		# [hunger, happiness, expected_mood]
		[100.0, 100.0, FishMood.Mood.HAPPY],
		[80.0, 80.0, FishMood.Mood.HAPPY],
		[79.9, 80.0, FishMood.Mood.NEUTRAL],
		[80.0, 79.9, FishMood.Mood.NEUTRAL],
		[60.0, 60.0, FishMood.Mood.NEUTRAL],
		[49.9, 60.0, FishMood.Mood.HUNGRY],
		[20.0, 60.0, FishMood.Mood.HUNGRY],
		[19.9, 60.0, FishMood.Mood.SAD],  # hunger < 20 forces SAD even with ok happiness
		[60.0, 49.9, FishMood.Mood.SAD],
		[60.0, 20.0, FishMood.Mood.SAD],
		[60.0, 19.9, FishMood.Mood.SICK],
		[0.0, 0.0, FishMood.Mood.SICK],
	]
	for c in cases:
		var hunger: float = c[0]
		var happiness: float = c[1]
		var expected: FishMood.Mood = c[2]
		assert_eq(FishMood.derive(hunger, happiness), expected, "hunger=%s happiness=%s" % [hunger, happiness])


func test_no_mood_value_represents_death() -> void:
	# Every enum value must be a recoverable mood, never a terminal/dead state.
	for mood in FishMood.Mood.values():
		assert_true(mood in [FishMood.Mood.HAPPY, FishMood.Mood.NEUTRAL, FishMood.Mood.HUNGRY, FishMood.Mood.SAD, FishMood.Mood.SICK])
