extends GutTest
## Unit tests for TankManager.resolve_spawn_list (TASKS.md 3.5).
## Pure function — no scene tree / node instancing involved.


func test_resolve_spawn_list_resolves_known_species() -> void:
	var species := FishSpecies.new()
	species.id = "guppy"
	species.display_name = "Guppy"
	var directory := {"guppy": species}
	var owned: Array[Dictionary] = [{"species_id": "guppy", "name": "Bubbles"}]

	var resolved := TankManager.resolve_spawn_list(owned, directory)

	assert_eq(resolved.size(), 1)
	assert_eq(resolved[0]["species"], species)
	assert_eq(resolved[0]["name"], "Bubbles")


func test_resolve_spawn_list_defaults_name_to_species_display_name() -> void:
	var species := FishSpecies.new()
	species.id = "goldfish"
	species.display_name = "Goldfish"
	var directory := {"goldfish": species}
	var owned: Array[Dictionary] = [{"species_id": "goldfish"}]

	var resolved := TankManager.resolve_spawn_list(owned, directory)

	assert_eq(resolved[0]["name"], "Goldfish")


func test_resolve_spawn_list_skips_unknown_species() -> void:
	var directory := {}
	var owned: Array[Dictionary] = [{"species_id": "unknown_fish", "name": "Ghost"}]

	var resolved := TankManager.resolve_spawn_list(owned, directory)

	assert_eq(resolved.size(), 0)


func test_resolve_spawn_list_handles_multiple_entries_and_skips_mixed_in_unknowns() -> void:
	var a := FishSpecies.new()
	a.id = "a"
	a.display_name = "A"
	var b := FishSpecies.new()
	b.id = "b"
	b.display_name = "B"
	var directory := {"a": a, "b": b}
	var owned: Array[Dictionary] = [
		{"species_id": "a", "name": "Alpha"},
		{"species_id": "missing", "name": "Ghost"},
		{"species_id": "b", "name": "Beta"},
	]

	var resolved := TankManager.resolve_spawn_list(owned, directory)

	assert_eq(resolved.size(), 2)
	assert_eq(resolved[0]["name"], "Alpha")
	assert_eq(resolved[1]["name"], "Beta")


func test_resolve_spawn_list_empty_owned_returns_empty() -> void:
	var resolved := TankManager.resolve_spawn_list([], {})
	assert_eq(resolved.size(), 0)
