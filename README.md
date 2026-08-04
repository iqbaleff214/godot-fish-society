# Fish Society

A 2D cozy life-sim about owning, decorating, and caring for a fish tank — think *Pet Society*, but for aquarium life.

Full design details live in [GDD.md](GDD.md). Want to just play it? See [HOWTOPLAY.md](HOWTOPLAY.md).

## Status

**Phase 1 (MVP) complete** — the full core loop is playable: fish care (feed/pet/clean), a coin/gem economy with a shop, decorating, quests, leveling, and local save/load. All art is still placeholder — see [TODO_ASSETS.md](TODO_ASSETS.md). Tracked task-by-task in [TASKS.md](TASKS.md).

## Engine

- **Godot:** 4.7 (Forward+ renderer)
- **Physics:** Jolt Physics

## Getting Started

1. Install [Godot 4.7](https://godotengine.org/download).
2. Clone this repo.
3. Open Godot, `Import` → select this folder's `project.godot`.
4. Run the project (`F5`) — it boots straight into the tank (`scenes/tank/TankView.tscn` is the main scene).

New to the game? Read [HOWTOPLAY.md](HOWTOPLAY.md) for controls and rules.

## Running Tests

Unit/integration tests use [GUT](https://github.com/bitwes/Gut) and live in `tests/`. Run them from the editor's GUT panel, or headlessly:

```sh
godot --headless -s addons/gut/gut_cmdln.gd -gexit
```

## Placeholder Assets

Real art/audio hasn't been added yet. Until then, dev uses simple placeholder shapes/sprites. Anywhere a placeholder is used, look for a `TODO` comment marking it for later replacement — search the project for `TODO: asset` to find them all, or see the pre-generated inventory in [TODO_ASSETS.md](TODO_ASSETS.md).

## Project Structure

See [GDD.md § 7.1](GDD.md#71-suggested-scene-structure) for the intended `scenes/` / `scripts/` / `resources/` layout, and [TASKS.md](TASKS.md) for what's actually been built against it so far.
