extends GutTest
## Unit tests for PlayerData currency (TASKS.md 5.1). PlayerData is a
## persistent autoload, so state is reset around every test.


func before_each() -> void:
	PlayerData.coins = 0
	PlayerData.gems = 0


func after_each() -> void:
	PlayerData.coins = 0
	PlayerData.gems = 0


func test_add_coins_increases_balance() -> void:
	PlayerData.add_coins(50)
	assert_eq(PlayerData.coins, 50)


func test_spend_coins_sufficient_balance_succeeds_and_deducts_exact_amount() -> void:
	PlayerData.coins = 100
	var result := PlayerData.spend_coins(40)
	assert_true(result)
	assert_eq(PlayerData.coins, 60)


func test_spend_coins_insufficient_balance_fails_and_unchanged() -> void:
	PlayerData.coins = 10
	var result := PlayerData.spend_coins(40)
	assert_false(result)
	assert_eq(PlayerData.coins, 10)


func test_spend_never_goes_negative() -> void:
	PlayerData.coins = 5
	PlayerData.spend_coins(100)
	assert_true(PlayerData.coins >= 0)


func test_add_gems_increases_balance() -> void:
	PlayerData.add_gems(3)
	assert_eq(PlayerData.gems, 3)


func test_spend_gems_sufficient_succeeds() -> void:
	PlayerData.gems = 10
	assert_true(PlayerData.spend_gems(4))
	assert_eq(PlayerData.gems, 6)


func test_spend_gems_insufficient_fails_and_unchanged() -> void:
	PlayerData.gems = 2
	assert_false(PlayerData.spend_gems(5))
	assert_eq(PlayerData.gems, 2)


func test_currency_changed_signal_emitted_on_spend() -> void:
	PlayerData.coins = 100
	watch_signals(EventBus)
	PlayerData.spend_coins(30)
	assert_signal_emitted(EventBus, "currency_changed")


func test_currency_changed_signal_emitted_on_add() -> void:
	watch_signals(EventBus)
	PlayerData.add_coins(10)
	assert_signal_emitted(EventBus, "currency_changed")
