extends Node
## Autoload: save/load orchestration (TASKS.md 8.2) and autosave triggers
## (TASKS.md 8.4). Converts between live PlayerData (+ the active
## TankManager's tank layout) and a PlayerSave, handles file I/O, and
## applies offline decay (8.3) on load.

const SAVE_PATH := "user://save.json"
const AUTOSAVE_INTERVAL_SECONDS := 120.0


func _ready() -> void:
	load_game()

	EventBus.item_purchased.connect(_on_item_purchased)  # 8.4: after purchases

	var timer := Timer.new()
	timer.wait_time = AUTOSAVE_INTERVAL_SECONDS
	timer.timeout.connect(save_game)
	add_child(timer)
	timer.start()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:  # 8.4: on app quit
		save_game()
		get_tree().quit()


func get_save_path() -> String:
	return SAVE_PATH


func save_game() -> void:
	_sync_tank_layout_from_live_tank()
	var save := _build_save_from_player_data()
	save.last_saved_unix_time = Time.get_unix_time_from_system()

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: failed to open save file for writing: %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(save.to_dict()))
	file.close()


## No-op if no save file exists yet — PlayerData's own field initializers
## are already sensible defaults, so a fresh install loads cleanly without
## error (TASKS.md 8.2 DoD).
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: failed to open save file for reading: %s" % SAVE_PATH)
		return
	var text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if not (parsed is Dictionary):
		push_error("SaveManager: save file is corrupt (not a JSON object), ignoring.")
		return

	var save := PlayerSave.from_dict(parsed)
	var species_directory := TankManager.build_default_species_directory()
	OfflineDecay.apply(save, Time.get_unix_time_from_system(), species_directory)
	_apply_save_to_player_data(save)
	_sync_tank_manager_from_player_data()


func _on_item_purchased() -> void:
	save_game()


func _build_save_from_player_data() -> PlayerSave:
	var save := PlayerSave.new()
	save.tank_layout = PlayerData.tank_layout
	save.owned_fish = PlayerData.owned_fish
	for item: DecorItem in PlayerData.inventory:
		save.inventory.append(item.id)
	save.coins = PlayerData.coins
	save.gems = PlayerData.gems
	save.level = PlayerData.level
	save.xp = PlayerData.xp
	save.quest_progress = PlayerData.quest_progress
	return save


func _apply_save_to_player_data(save: PlayerSave) -> void:
	PlayerData.tank_layout = save.tank_layout
	PlayerData.owned_fish = save.owned_fish
	var decor_directory := TankManager.build_default_decor_directory()
	PlayerData.inventory.clear()
	for item_id in save.inventory:
		if decor_directory.has(item_id):
			PlayerData.inventory.append(decor_directory[item_id])
	PlayerData.coins = save.coins
	PlayerData.gems = save.gems
	PlayerData.level = save.level
	PlayerData.xp = save.xp
	PlayerData.quest_progress = save.quest_progress


func _sync_tank_layout_from_live_tank() -> void:
	var tank_manager: TankManager = get_tree().get_first_node_in_group("tank_manager")
	if tank_manager != null:
		PlayerData.tank_layout = tank_manager.get_placed_decor_snapshot()
		PlayerData.owned_fish = tank_manager.get_owned_fish_snapshot()


## Only matters if load_game() runs while a tank is already active (e.g. a
## future "load save" menu action) — on normal boot this autoload's
## load_game() runs before TankView exists, and TankManager's own _ready()
## picks up the already-populated PlayerData fields on its own.
func _sync_tank_manager_from_player_data() -> void:
	var tank_manager: TankManager = get_tree().get_first_node_in_group("tank_manager")
	if tank_manager != null:
		tank_manager.load_from_player_data()
		tank_manager.load_tank_layout_from_player_data()
