extends GutTest
## Integration tests for PlayerData's XP/level/quest wiring (TASKS.md 6.1/6.2).
## PlayerData is a real autoload with _ready() already connected to EventBus
## by the time GUT runs, so emitting EventBus signals here exercises the
## real listener wiring, not a mock.


func before_each() -> void:
	PlayerData.xp = 0
	PlayerData.level = 1
	PlayerData.coins = 0
	PlayerData.quest_progress.clear()


func after_each() -> void:
	PlayerData.xp = 0
	PlayerData.level = 1
	PlayerData.coins = 0
	PlayerData.quest_progress.clear()


func test_add_xp_increases_xp() -> void:
	PlayerData.add_xp(10)
	assert_eq(PlayerData.xp, 10)


func test_add_xp_levels_up_at_threshold_and_emits_level_up() -> void:
	watch_signals(EventBus)
	PlayerData.add_xp(PlayerLevel.XP_PER_LEVEL)
	assert_eq(PlayerData.level, 2)
	assert_signal_emitted(EventBus, "level_up")


func test_add_xp_crossing_multiple_levels_fires_level_up_once_per_level() -> void:
	watch_signals(EventBus)
	PlayerData.add_xp(PlayerLevel.xp_required_for_level(4))
	assert_eq(PlayerData.level, 4)
	assert_signal_emit_count(EventBus, "level_up", 3)


func test_fish_fed_event_awards_care_action_xp() -> void:
	EventBus.fish_fed.emit(null)
	assert_eq(PlayerData.xp, PlayerData.FEED_XP_REWARD)


func test_fish_petted_event_awards_care_action_xp() -> void:
	EventBus.fish_petted.emit(null)
	assert_eq(PlayerData.xp, PlayerData.PET_XP_REWARD)


func test_tank_cleaned_event_awards_care_action_xp() -> void:
	# clean_tank_once has target_count=1, so an unguarded emit would also
	# complete that quest and add its reward_xp on top — pre-complete it so
	# this test isolates just the base care-action XP reward.
	PlayerData.quest_progress["clean_tank_once"] = {"count": 1, "completed": true}
	EventBus.tank_cleaned.emit()
	assert_eq(PlayerData.xp, PlayerData.CLEAN_XP_REWARD)


func test_feed_quest_completes_after_three_feeds_and_grants_reward_once() -> void:
	watch_signals(EventBus)
	for i in range(3):
		EventBus.fish_fed.emit(null)
	var progress: Dictionary = PlayerData.quest_progress.get("feed_3_times", {})
	assert_true(progress.get("completed", false))
	assert_signal_emit_count(EventBus, "quest_completed", 1)
	# 3 feeds * FEED_XP_REWARD + the quest's own reward_coins (30) landed exactly once.
	assert_eq(PlayerData.coins, 30)


func test_feed_quest_does_not_regrant_reward_on_further_feeds() -> void:
	for i in range(3):
		EventBus.fish_fed.emit(null)
	var coins_after_completion := PlayerData.coins
	EventBus.fish_fed.emit(null)
	EventBus.fish_fed.emit(null)
	assert_eq(PlayerData.coins, coins_after_completion)


func test_petting_does_not_progress_feed_quest() -> void:
	EventBus.fish_petted.emit(null)
	EventBus.fish_petted.emit(null)
	var progress: Dictionary = PlayerData.quest_progress.get("feed_3_times", {})
	assert_eq(progress.get("count", 0), 0)
