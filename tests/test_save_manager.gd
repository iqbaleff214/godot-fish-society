extends GutTest
## Integration tests for SaveManager (TASKS.md 8.2/8.3) against the real
## autoload and real user:// file I/O — save/load round-tripping is exactly
## what needs proving here, a mock wouldn't catch a broken JSON shape.


func before_each() -> void:
	_delete_save_file()
	_reset_player_data()


func after_each() -> void:
	_delete_save_file()
	_reset_player_data()


func _delete_save_file() -> void:
	var dir := DirAccess.open("user://")
	if dir != null and dir.file_exists("save.json"):
		dir.remove("save.json")


func _reset_player_data() -> void:
	PlayerData.coins = 0
	PlayerData.gems = 0
	PlayerData.level = 1
	PlayerData.xp = 0
	PlayerData.owned_fish = []
	PlayerData.inventory = []
	PlayerData.tank_layout = []
	PlayerData.quest_progress = {}


func test_save_then_load_round_trips_player_data() -> void:
	PlayerData.coins = 77
	PlayerData.gems = 3
	PlayerData.level = 2
	PlayerData.xp = 60
	PlayerData.owned_fish = [{"species_id": "guppy", "name": "Bubbles", "hunger": 80.0, "happiness": 90.0, "cleanliness_sensitivity": 100.0}]
	PlayerData.quest_progress = {"pet_3_times": {"count": 1, "completed": false}}

	SaveManager.save_game()

	# Mutate live state first to prove load_game() actually restores from
	# disk rather than the assertions accidentally passing on a no-op.
	PlayerData.coins = 0
	PlayerData.owned_fish = []
	PlayerData.quest_progress = {}

	SaveManager.load_game()

	assert_eq(PlayerData.coins, 77)
	assert_eq(PlayerData.gems, 3)
	assert_eq(PlayerData.level, 2)
	assert_eq(PlayerData.xp, 60)
	assert_eq(PlayerData.owned_fish.size(), 1)
	assert_eq(PlayerData.owned_fish[0]["species_id"], "guppy")
	assert_eq(PlayerData.quest_progress["pet_3_times"]["count"], 1)


func test_load_with_no_file_present_does_not_throw_and_keeps_current_state() -> void:
	# before_each already ensured no save file exists.
	PlayerData.coins = 999  # sentinel: load_game() with no file must not touch this
	SaveManager.load_game()
	assert_eq(PlayerData.coins, 999)


func test_inventory_round_trips_by_item_id() -> void:
	var castle: DecorItem = null
	for item in DecorItem.load_all():
		if item.id == "castle":
			castle = item
	PlayerData.inventory = [castle]

	SaveManager.save_game()
	PlayerData.inventory = []
	SaveManager.load_game()

	assert_eq(PlayerData.inventory.size(), 1)
	assert_eq(PlayerData.inventory[0].id, "castle")


func test_offline_decay_applied_on_load_after_time_passes() -> void:
	PlayerData.owned_fish = [{"species_id": "guppy", "name": "Bubbles", "hunger": 100.0, "happiness": 100.0, "cleanliness_sensitivity": 100.0}]
	SaveManager.save_game()

	# Rewrite the just-written file with an old timestamp to simulate elapsed time.
	var read_file := FileAccess.open(SaveManager.get_save_path(), FileAccess.READ)
	var data = JSON.parse_string(read_file.get_as_text())
	read_file.close()
	data["last_saved_unix_time"] = Time.get_unix_time_from_system() - 3600  # 1 hour ago
	var write_file := FileAccess.open(SaveManager.get_save_path(), FileAccess.WRITE)
	write_file.store_string(JSON.stringify(data))
	write_file.close()

	PlayerData.owned_fish = []
	SaveManager.load_game()

	assert_true(PlayerData.owned_fish[0]["hunger"] < 100.0)
