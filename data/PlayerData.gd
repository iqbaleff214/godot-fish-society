extends Node
## Autoload: single source of truth for player save data
## (currency, level/XP, owned fish/decor, quest progress).
## Fields added per-feature as later tasks need them (see TASKS.md Phase 1).

## Each entry: {"species_id": String, "name": String}. Stats aren't persisted
## yet (TASKS.md 3.5 stubs to FishStats defaults) — that's task 8's job.
var owned_fish: Array[Dictionary] = []
