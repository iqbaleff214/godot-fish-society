class_name TankManager
extends Node
## Spawns/despawns Fish instances into a Tank from PlayerData.owned_fish
## (TASKS.md 3.5), and places DecorItems out of PlayerData.inventory into
## the tank (TASKS.md 5.4) — matches GDD § 7.1's "spawns fish/decor" for
## this file. Add as a sibling of a Tank node; resolves it via tank_path
## by default ("../Tank").

const FISH_SCENE: PackedScene = preload("res://scenes/tank/Fish.tscn")
const DECORATION_SCENE: PackedScene = preload("res://scenes/tank/Decoration.tscn")

@export var tank_path: NodePath = ^"../Tank"
@onready var tank: Tank = get_node(tank_path)

## species_id (String) -> FishSpecies. Auto-populated from
## resources/fish_species/*.tres on _ready() if left empty.
var species_directory: Dictionary = {}

var _spawned: Array[Fish] = []


func _ready() -> void:
	if species_directory.is_empty():
		species_directory = build_default_species_directory()
	load_from_player_data()


## Pure resolution step: turns PlayerData-shaped owned-fish entries into
## {species, name} pairs ready to spawn, skipping unknown species_ids.
## Kept static/side-effect-free so it's unit-testable without a scene tree.
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
		})
	return resolved


static func build_default_species_directory() -> Dictionary:
	var directory: Dictionary = {}
	for species in FishSpecies.load_all():
		if species.id != "":
			directory[species.id] = species
	return directory


func load_from_player_data() -> void:
	despawn_all()
	var owned: Array = PlayerData.owned_fish
	for spawn_info in resolve_spawn_list(owned, species_directory):
		_spawn(spawn_info.species, spawn_info.name)


func spawn_fish(species: FishSpecies, fish_name: String) -> Fish:
	return _spawn(species, fish_name)


func despawn_all() -> void:
	for fish in _spawned:
		if is_instance_valid(fish):
			fish.queue_free()
	_spawned.clear()


func _spawn(species: FishSpecies, fish_name: String) -> Fish:
	var fish: Fish = FISH_SCENE.instantiate()
	tank.get_contents_node().add_child(fish)
	fish.display_name = fish_name
	fish.set_tank(tank)
	fish.setup(species)
	_spawned.append(fish)
	return fish


## Takes item out of PlayerData.inventory and places it in the tank
## (TASKS.md 5.4). Returns null (no-op) if the item wasn't actually in
## inventory — e.g. double-clicked or already placed elsewhere.
func place_decor_from_inventory(item: DecorItem, at_position: Vector2) -> Decoration:
	if not PlayerData.remove_from_inventory(item):
		return null
	var decoration: Decoration = DECORATION_SCENE.instantiate()
	tank.get_contents_node().add_child(decoration)
	decoration.position = at_position
	decoration.setup(item)
	decoration.removed.connect(_on_decoration_removed)
	EventBus.decor_placed.emit(item)
	return decoration


## A Decoration placed via place_decor_from_inventory() returns to
## inventory when removed (TASKS.md 5.4's "removing a placed item returns
## it to inventory"). Decoration.request_remove() emits this before
## queue_free(), so decoration.item is still valid here.
func _on_decoration_removed(decoration: Decoration) -> void:
	PlayerData.add_to_inventory(decoration.item)
