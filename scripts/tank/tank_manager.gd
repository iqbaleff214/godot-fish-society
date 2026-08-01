class_name TankManager
extends Node
## Spawns/despawns Fish instances into a Tank from PlayerData.owned_fish
## (TASKS.md 3.5), and places DecorItems out of PlayerData.inventory into
## the tank (TASKS.md 5.4) — matches GDD § 7.1's "spawns fish/decor" for
## this file. Also restores saved fish stats and the placed-decor tank
## layout on load, and snapshots the live layout for saving (TASKS.md 8.1/
## 8.2). Add as a sibling of a Tank node; resolves it via tank_path by
## default ("../Tank").

const FISH_SCENE: PackedScene = preload("res://scenes/tank/Fish.tscn")
const DECORATION_SCENE: PackedScene = preload("res://scenes/tank/Decoration.tscn")

@export var tank_path: NodePath = ^"../Tank"
@onready var tank: Tank = get_node(tank_path)

## species_id (String) -> FishSpecies. Auto-populated from
## resources/fish_species/*.tres on _ready() if left empty.
var species_directory: Dictionary = {}

var _spawned: Array[Fish] = []


func _ready() -> void:
	add_to_group("tank_manager")  # so SaveManager (TASKS.md 8.2) can find the active tank
	if species_directory.is_empty():
		species_directory = build_default_species_directory()
	load_from_player_data()
	load_tank_layout_from_player_data()


## Pure resolution step: turns PlayerData-shaped owned-fish entries into
## {species, name, stats} tuples ready to spawn, skipping unknown
## species_ids. Kept static/side-effect-free so it's unit-testable without
## a scene tree. "stats" defaults to full (100/100/100) when a saved entry
## doesn't carry them (e.g. a freshly-purchased fish, TASKS.md 3.5/5.3).
static func resolve_spawn_list(owned_fish: Array, directory: Dictionary) -> Array[Dictionary]:
	var resolved: Array[Dictionary] = []
	for entry in owned_fish:
		var species_id: String = entry.get("species_id", "")
		if not directory.has(species_id):
			push_warning("TankManager: unknown species_id '%s', skipping." % species_id)
			continue
		var species: FishSpecies = directory[species_id]
		resolved.append({
			"species": species,
			"name": entry.get("name", species.display_name),
			"stats": {
				"hunger": entry.get("hunger", 100.0),
				"happiness": entry.get("happiness", 100.0),
				"cleanliness_sensitivity": entry.get("cleanliness_sensitivity", 100.0),
			},
		})
	return resolved


static func build_default_species_directory() -> Dictionary:
	var directory: Dictionary = {}
	for species in FishSpecies.load_all():
		if species.id != "":
			directory[species.id] = species
	return directory


static func build_default_decor_directory() -> Dictionary:
	var directory: Dictionary = {}
	for item in DecorItem.load_all():
		if item.id != "":
			directory[item.id] = item
	return directory


func load_from_player_data() -> void:
	despawn_all()
	var owned: Array = PlayerData.owned_fish
	for spawn_info in resolve_spawn_list(owned, species_directory):
		_spawn(spawn_info.species, spawn_info.name, spawn_info.stats)


func spawn_fish(species: FishSpecies, fish_name: String) -> Fish:
	return _spawn(species, fish_name)


func despawn_all() -> void:
	# remove_child() first so get_children() reflects the change immediately
	# — load_from_player_data() can otherwise be called twice in the same
	# frame (e.g. a reload right after a fresh boot) and see stale
	# not-yet-freed fish via the scene tree even though _spawned is already
	# cleared. queue_free() still does the actual deferred destruction.
	for fish in _spawned:
		if is_instance_valid(fish):
			fish.get_parent().remove_child(fish)
			fish.queue_free()
	_spawned.clear()


func _spawn(species: FishSpecies, fish_name: String, saved_stats: Dictionary = {}) -> Fish:
	var fish: Fish = FISH_SCENE.instantiate()
	tank.get_contents_node().add_child(fish)
	fish.display_name = fish_name
	fish.set_tank(tank)
	fish.setup(species)
	if not saved_stats.is_empty():
		fish.stats.hunger = saved_stats.get("hunger", fish.stats.hunger)
		fish.stats.happiness = saved_stats.get("happiness", fish.stats.happiness)
		fish.stats.cleanliness_sensitivity = saved_stats.get("cleanliness_sensitivity", fish.stats.cleanliness_sensitivity)
	_spawned.append(fish)
	return fish


## Takes item out of PlayerData.inventory and places it in the tank
## (TASKS.md 5.4). Returns null (no-op) if the item wasn't actually in
## inventory — e.g. double-clicked or already placed elsewhere.
func place_decor_from_inventory(item: DecorItem, at_position: Vector2) -> Decoration:
	if not PlayerData.remove_from_inventory(item):
		return null
	var decoration := _instantiate_decoration(item, at_position)
	EventBus.decor_placed.emit(item)
	return decoration


## A Decoration placed via place_decor_from_inventory() returns to
## inventory when removed (TASKS.md 5.4's "removing a placed item returns
## it to inventory"). Decoration.request_remove() emits this before
## queue_free(), so decoration.item is still valid here.
func _on_decoration_removed(decoration: Decoration) -> void:
	PlayerData.add_to_inventory(decoration.item)


func _instantiate_decoration(item: DecorItem, at_position: Vector2) -> Decoration:
	var decoration: Decoration = DECORATION_SCENE.instantiate()
	tank.get_contents_node().add_child(decoration)
	decoration.position = at_position
	decoration.setup(item)
	decoration.removed.connect(_on_decoration_removed)
	return decoration


## Replaces all currently-placed decor with PlayerData.tank_layout
## (TASKS.md 8.1/8.2). Clears via plain queue_free() (not request_remove())
## since this isn't a gameplay removal — it must NOT return items to
## inventory or fire the decor_placed quest signal.
func load_tank_layout_from_player_data() -> void:
	# remove_child() + queue_free() — see despawn_all() for why plain
	# queue_free() alone risks stale get_children() results.
	for child in tank.get_contents_node().get_children():
		if child is Decoration:
			tank.get_contents_node().remove_child(child)
			child.queue_free()

	var decor_directory := build_default_decor_directory()
	for entry in PlayerData.tank_layout:
		var item_id: String = entry.get("item_id", "")
		if not decor_directory.has(item_id):
			push_warning("TankManager: unknown decor item_id '%s' in tank_layout, skipping." % item_id)
			continue
		var item: DecorItem = decor_directory[item_id]
		var pos := Vector2(entry.get("position_x", 0.0), entry.get("position_y", 0.0))
		_instantiate_decoration(item, pos)


## Reads the live tank state directly (single source of truth — no
## separately-tracked list to keep in sync with drag-repositioning) so
## SaveManager can persist whatever's actually placed right now.
func get_placed_decor_snapshot() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for child in tank.get_contents_node().get_children():
		if child is Decoration:
			var d: Decoration = child
			result.append({
				"item_id": d.item.id,
				"position_x": d.position.x,
				"position_y": d.position.y,
			})
	return result


## Reads live Fish nodes' current stats — SaveManager needs this before
## writing a save, otherwise PlayerData.owned_fish stays frozen at
## spawn-time values and every hunger/happiness/cleanliness change during
## play would be silently lost (TASKS.md 8.2).
func get_owned_fish_snapshot() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for fish in _spawned:
		if not is_instance_valid(fish):
			continue
		result.append({
			"species_id": fish.species.id,
			"name": fish.display_name,
			"hunger": fish.stats.hunger,
			"happiness": fish.stats.happiness,
			"cleanliness_sensitivity": fish.stats.cleanliness_sensitivity,
		})
	return result
