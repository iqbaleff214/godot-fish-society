extends GutTest
## Round-trip unit tests for PlayerSave (TASKS.md 8.1).


func _make_populated_save() -> PlayerSave:
	var save := PlayerSave.new()
	save.tank_layout = [{"item_id": "castle", "position_x": 10.0, "position_y": 20.0}]
	save.owned_fish = [{"species_id": "guppy", "name": "Bubbles", "hunger": 42.0, "happiness": 55.0, "cleanliness_sensitivity": 60.0}]
	save.inventory = ["green_plant", "green_plant", "rock_pile"]
	save.coins = 123
	save.gems = 7
	save.level = 3
	save.xp = 250
	save.quest_progress = {"feed_3_times": {"count": 2, "completed": false}}
	save.last_saved_unix_time = 1700000000
	return save


func test_to_dict_round_trips_through_from_dict() -> void:
	var original := _make_populated_save()
	var restored := PlayerSave.from_dict(original.to_dict())

	assert_eq(restored.tank_layout, original.tank_layout)
	assert_eq(restored.owned_fish, original.owned_fish)
	assert_eq(restored.inventory, original.inventory)
	assert_eq(restored.coins, original.coins)
	assert_eq(restored.gems, original.gems)
	assert_eq(restored.level, original.level)
	assert_eq(restored.xp, original.xp)
	assert_eq(restored.quest_progress, original.quest_progress)
	assert_eq(restored.last_saved_unix_time, original.last_saved_unix_time)


func test_round_trips_through_actual_json_text() -> void:
	# Exercises the real JSON.stringify/parse_string path, not just the
	# Dictionary shape — catches anything Variant-typed that JSON can't carry.
	var original := _make_populated_save()
	var json_text := JSON.stringify(original.to_dict())
	var parsed = JSON.parse_string(json_text)
	var restored := PlayerSave.from_dict(parsed)

	assert_eq(restored.owned_fish[0]["species_id"], "guppy")
	assert_eq(restored.owned_fish[0]["hunger"], 42.0)
	assert_eq(restored.inventory, ["green_plant", "green_plant", "rock_pile"])
	assert_eq(restored.coins, 123)
	assert_eq(restored.quest_progress["feed_3_times"]["count"], 2)


func test_from_dict_defaults_missing_fields() -> void:
	var restored := PlayerSave.from_dict({})
	assert_eq(restored.tank_layout, [])
	assert_eq(restored.owned_fish, [])
	assert_eq(restored.inventory, [])
	assert_eq(restored.coins, 0)
	assert_eq(restored.gems, 0)
	assert_eq(restored.level, 1)
	assert_eq(restored.xp, 0)
	assert_eq(restored.quest_progress, {})
	assert_eq(restored.last_saved_unix_time, 0)
