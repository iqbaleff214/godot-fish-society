# Placeholder Asset Inventory

Generated for TASKS.md 9.2. Every visual/audio placeholder in the project is
tagged `TODO: asset —` at its call site (a code comment, a `.tres`'s
`resource_name`, or a node's `editor_description`/`tooltip_text` where no
script exists to hold a comment). Re-run `grep -rn "TODO: asset" .` to
regenerate this list as new placeholders are added or replaced — each item
below should disappear from the grep once its real asset lands.

**Scope note:** this covers game-world art (fish, tank, decor, food) and
thematically-specific UI (mood icons, notification bell) — the standing
placeholder convention's own "engine default fonts" allowance means generic
UI chrome (Shop/Quests/Decorate buttons, panel labels, etc.) intentionally
isn't tagged; those are functional controls, not art to be swapped later.
Audio (GDD § 8: ambient bubbling, feed/click SFX, background music, "happy
fish" chime) was never implemented at all in Phase 1 — the legend's own
"no SFX/music files yet" already covers that as an acknowledged gap, not a
silently-missed placeholder.

## Fish species sprites (8) — `resources/fish_species/*.tres`

Each is a flat-tinted `GradientTexture2D` blob standing in for real sprite
art (GDD § 8: "2–4 frame swim animation, side-profile, exaggerated cute
proportions"). Tagged via `resource_name`.

- guppy.tres
- neon_tetra.tres
- goldfish.tres
- cherry_shrimp.tres
- betta.tres
- corydoras.tres
- angelfish.tres
- clownfish.tres

## Decor item textures (8) — `resources/decor_items/*.tres`

Same `GradientTexture2D` placeholder approach. Tagged via `resource_name`.

- blue_backdrop.tres (background)
- natural_gravel.tres
- green_plant.tres
- red_plant.tres
- castle.tres
- driftwood.tres
- treasure_chest.tres
- rock_pile.tres

## Tank — `scripts/tank/tank.gd`

- `Glass` (`Polygon2D`) — flat-color placeholder for the tank glass/backdrop art.
- `DirtOverlay` (`Polygon2D`) — flat tint placeholder for an algae/dirt overlay texture.

## Decoration — `scripts/tank/decoration.gd`

- `Visual` (`Sprite2D`) — currently just re-displays the owning `DecorItem`'s
  placeholder texture; will want its own presentation once real decor art exists.

## Fish — `scripts/fish/fish.gd`

- `Visual` (`AnimatedSprite2D`) — placeholder `SpriteFrames` (see species list above).
- `MoodIcon` (`Label`) — text-glyph placeholder (`^_^`, `!`, `...`, `x_x`) for a real mood icon set.
- `eat()` — placeholder: no eat animation/duration, resolves instantly.
- `pet()` — placeholder: no reaction animation/duration, resolves instantly.

## Food — `scenes/tank/Food.tscn`

- Flat-color dot placeholder for a food sprite; real "falling" motion/animation deferred too.

## HUD — `scenes/ui/HUD.tscn`

- `NotificationBell` (`Button`) — stub only, no icon and no behavior yet (Phase 2/3).
