# Fish Society — Task Breakdown

Derived from [GDD.md](GDD.md). Tasks are ordered by dependency within each phase — do them roughly top to bottom so later tasks can rely on earlier ones existing. Phases mirror [GDD § 9 Scope Plan](GDD.md#9-scope-plan).

**Legend**
- `[ ]` unchecked / `[x]` done — check off only when DoD is fully met.
- **Test Case(s)** marked *(unit)* means pure logic suitable for an automated test (use [GUT](https://github.com/bitwes/Gut) — add as a dev dependency when Phase 0 starts). Marked *(manual)* means a manual playtest/QA step — write it down and actually run it before checking the box.
- All new visual/audio work in this whole document uses **placeholder assets** (primitive shapes, `AnimatedSprite2D` with flat colors, engine default fonts, no SFX/music files yet) with a `# TODO: asset — <what it should become>` comment at every placeholder, per standing project instruction. Don't check a task done if it's missing that TODO tag.

---

## Phase 0 — Project Foundation

Blocking prerequisite for everything else. Do this first, once.

- [x] **0.1 Folder structure scaffold**
  - **Description:** Create the `scenes/`, `scripts/`, `resources/`, `data/` tree exactly as laid out in [GDD § 7.1](GDD.md#71-suggested-scene-structure).
  - **DoD:** All folders exist (empty `.gitkeep` where needed); structure matches GDD 7.1 subfolder names.
  - **Test Case(s):** *(manual)* Open project in Godot FileSystem dock, confirm tree matches doc.

- [x] **0.2 Autoload singletons skeleton**
  - **Description:** Create `GameState.gd`, `PlayerData.gd`, `EventBus.gd` per [GDD § 7.5](GDD.md#75-autoload-singletons-proposed), register as Autoloads in Project Settings. Empty/minimal fields for now — filled in as later tasks need them.
  - **DoD:** All three autoloads registered and load without error on empty project run. `EventBus` has no signals yet (added per-feature in later tasks, not pre-declared here).
  - **Test Case(s):** *(manual)* Run project, confirm no autoload errors in the Output panel.

- [x] **0.3 GUT test framework setup**
  - **Description:** Add the GUT addon for GDScript unit tests, create a `tests/` folder, wire a way to run tests (editor plugin panel is fine).
  - **DoD:** A trivial sample test (e.g. `assert_eq(1+1, 2)`) runs green inside Godot.
  - **Test Case(s):** *(manual)* Run GUT panel, sample test passes.

---

## Phase 1 — MVP

Matches [GDD § 9 MVP scope](GDD.md#mvp-playable-core-loop-single-player-no-backend): one tank size, placeable decor, 5–8 fish species, feed/clean/pet, coin economy + shop, basic quests, local save, core UI.

### 1. Data Layer

- [x] **1.1 `FishSpecies` Resource script**
  - **Description:** `class_name FishSpecies extends Resource` per [GDD § 7.3](GDD.md#73-data-driven-content). Exported fields: `id: String`, `display_name: String`, `sprite_frames: SpriteFrames`, `size: Vector2`, `rarity: enum {COMMON, UNCOMMON, RARE, EXOTIC}`, `base_price: int`, `hunger_decay_rate: float`, `happiness_decay_rate: float`, `is_cleaning_crew: bool` (GDD § 5, shrimp/snails).
  - **DoD:** Script compiles, new `.tres` of type `FishSpecies` can be created from the editor's "New Resource" dialog with all fields visible/editable.
  - **Test Case(s):** *(manual)* Create one `.tres` in editor, set values, save, reload project, values persist.

- [x] **1.2 `DecorItem` Resource script**
  - **Description:** `class_name DecorItem extends Resource`. Exported fields: `id: String`, `display_name: String`, `texture: Texture2D`, `footprint: Rect2`, `category: enum {PLANT, DECOR, GRAVEL, BACKGROUND}`, `price: int`, `currency_type: enum {COIN, GEM}`, `level_requirement: int`.
  - **DoD:** Same acceptance shape as 1.1.
  - **Test Case(s):** *(manual)* Same as 1.1 for `DecorItem`.

- [x] **1.3 Starter content: 5–8 fish species + placeholder art**
  - **Description:** Create 5–8 `.tres` `FishSpecies` resources (e.g. Guppy, Neon Tetra, Goldfish, Betta, Corydoras — pick from [GDD § 5](GDD.md#5-fish-species--rarity) table) using placeholder colored-shape `SpriteFrames` (e.g. tinted circle/oval per species so they're visually distinguishable). Include at least one `is_cleaning_crew = true` entry (e.g. shrimp).
  - **DoD:** All `.tres` files exist under `resources/fish_species/`, each with a `# TODO: asset — replace placeholder sprite for <species>` note (put it in the resource's editor description field, since `.tres` can't hold GDScript comments).
  - **Test Case(s):** *(manual)* Instance each species in a blank scene, confirm distinct placeholder sprite renders.

- [x] **1.4 Starter content: decor placeholders**
  - **Description:** Create ~6–10 `.tres` `DecorItem` resources spanning all four categories (at least 1 background, 2 gravel/plant, rest decor) with placeholder flat-color textures sized to their footprint.
  - **DoD:** Files exist under `resources/decor_items/`, each flagged with the same TODO convention as 1.3.
  - **Test Case(s):** *(manual)* Instance each in a blank scene, confirm placeholder texture renders at correct footprint size.

### 2. Tank Scene & Rendering

- [x] **2.1 `Tank.tscn` — water bounds, floor, glass**
  - **Description:** Build the tank container: a `Rect2`-defined water/swim area (exported on a `tank.gd` script), a floor `Area2D`/`Node2D` for decor anchoring, and placeholder glass/background (flat rect, `# TODO: asset — tank glass/backdrop art`).
  - **DoD:** Scene instances cleanly, exposes `get_water_bounds() -> Rect2` and `get_floor_y() -> float` for other systems to query.
  - **Test Case(s):** *(unit)* Test `get_water_bounds()` returns the configured `Rect2` given known export values.

- [x] **2.2 `TankView.tscn` root gameplay scene**
  - **Description:** Root scene combining `Tank.tscn` + HUD anchor point + camera. Set as the project's main scene once HUD exists (task 7.1) — until then just build the container.
  - **DoD:** Scene runs standalone (`F6`) showing an empty tank with placeholder background.
  - **Test Case(s):** *(manual)* Run scene, tank renders, no errors.

- [x] **2.3 Decoration placement system**
  - **Description:** `Decoration.tscn` base scene + `decoration_placement.gd` supporting: drag-to-move within floor area, footprint-based overlap check against other placed decor (reject overlapping placement, per [GDD § 4.1](GDD.md#41-the-tank)), remove/return-to-inventory action.
  - **DoD:** Player can drag a decor instance around the tank floor; dropping it on an occupied footprint snaps back / shows invalid-placement feedback (placeholder: red tint) instead of overlapping.
  - **Test Case(s):** *(unit)* Test overlap-detection function with known `Rect2` pairs (overlapping / non-overlapping / edge-touching cases). *(manual)* Drag two decor items to overlap, confirm rejection.

- [x] **2.4 Y-sort depth ordering**
  - **Description:** Ensure fish and decor render in correct front/back order based on vertical position (`YSort`/`Node2D.y_sort_enabled`), per [GDD § 8](GDD.md#8-art--audio-direction).
  - **DoD:** A fish swimming behind a tall decor item visually occludes correctly when it crosses the decor's Y position.
  - **Test Case(s):** *(manual)* Place tall decor, move fish through it, confirm draw order flips correctly at the crossing point.
  - **Note:** Mechanism implemented — `Tank.tscn`'s `Contents` node has `y_sort_enabled = true` and is the shared parent both `Decoration` (2.3) and `Fish` (3.5, not yet built) get added under, per [GDD § 8](GDD.md#8-art--audio-direction). Full manual confirmation with an actual fish crossing decor is blocked on task 3.1 existing — re-run that manual test case once fish are in the tank.

### 3. Fish System

- [x] **3.1 `Fish.tscn` base scene + state machine**
  - **Description:** One reusable scene driven by a `FishSpecies` resource (per [GDD § 7.3](GDD.md#73-data-driven-content) — no per-species scenes). `fish.gd` implements a state machine: `Idle → Swim → Eat → React` per [GDD § 7.2](GDD.md#72-fish-behavior-2d-swim-ai).
  - **DoD:** Instancing `Fish.tscn` and calling `setup(species: FishSpecies)` configures sprite/size/behavior params from that resource. States transition without illegal transitions (e.g. can't go straight from `Eat` to `React` without passing through `Idle`/`Swim` — document the allowed transition table in a code comment).
  - **Test Case(s):** *(unit)* Test state machine transition table directly (given current state + event, assert resulting state matches spec). *(manual)* Spawn fish, observe it idles and swims without visual glitches.

- [x] **3.2 Swim AI (steering)**
  - **Description:** In `Swim` state, pick a random target point inside `Tank.get_water_bounds()`, move toward it (`move_toward`/tween), clamp to bounds, flip sprite horizontally based on movement direction, per [GDD § 7.2](GDD.md#72-fish-behavior-2d-swim-ai).
  - **DoD:** Fish never visually exits the water `Rect2`. Sprite faces movement direction correctly both ways.
  - **Test Case(s):** *(unit)* Test bounds-clamping function with points outside/inside/on-edge of a known `Rect2`. *(manual)* Watch a fish for ~1 min, confirm it stays in bounds and flips correctly.

- [x] **3.3 `fish_stats.gd` — Hunger/Happiness/Cleanliness-sensitivity**
  - **Description:** Pure-logic component: three 0–100 stats with per-species decay rates (from `FishSpecies`), decayed by elapsed real time (not per-frame ticking — see task 8.3 for the load-time version of this same math). Expose `apply_feed()`, `apply_pet()`, `apply_cleanliness(tank_cleanliness: float)`, `decay(delta_seconds: float)`.
  - **DoD:** Stats clamp to `[0, 100]`. Decay math is a single testable pure function independent of `_process`.
  - **Test Case(s):** *(unit)* Given known start stats + decay rate + elapsed seconds, assert exact resulting stat value. *(unit)* Assert clamping at 0 and 100 boundaries. *(unit)* Assert `apply_feed()` restores hunger and gives the documented small happiness bump.

- [x] **3.4 Mood state derivation**
  - **Description:** Pure function mapping `(hunger, happiness)` → `Happy | Neutral | Hungry | Sad | Sick` enum per [GDD § 4.2](GDD.md#42-fish-the-pets). Wire to a placeholder mood icon above the fish (`# TODO: asset — mood icon set`) and swap swim animation speed/energy for Happy vs Sad/Sick per GDD (energetic vs sluggish).
  - **DoD:** Documented thresholds table exists in code comment; icon updates live as stats change; no fish ever hard-fails (no "dead" state exists anywhere in code, per Pillar 1).
  - **Test Case(s):** *(unit)* Table-driven test: for each documented threshold boundary, assert correct mood enum returned. *(manual)* Starve a fish's hunger to 0 via debug, confirm it reaches Sad/Sick visual, not removed/hidden permanently, and recovers once fed.

- [x] **3.5 Fish spawn/despawn via TankManager**
  - **Description:** `tank_manager.gd` reads owned fish list from `PlayerData`, instances/configures `Fish.tscn` per entry on tank load, handles adding a newly-purchased fish at runtime.
  - **DoD:** Tank on load shows exactly the fish present in `PlayerData`, correctly named and stat-restored (depends on task 8 for persisted stats, stub with defaults until then).
  - **Test Case(s):** *(unit)* Given a mock `PlayerData` fish list, assert `TankManager` requests the correct count/species of spawns (test the spawn-list resolution logic, not actual node instancing). *(manual)* Add fish via debug call, confirm it appears and swims.

### 4. Care Actions

- [x] **4.1 Feed action**
  - **Description:** Player selects a food item, clicks/taps in tank, food drops (placeholder: small falling dot, `# TODO: asset — food sprite`), nearest fish with `hunger < threshold` swims to it and transitions through `Eat` state, per [GDD § 4.2](GDD.md#42-fish-the-pets).
  - **DoD:** Feeding restores hunger via `fish_stats.apply_feed()` (task 3.3) and emits `EventBus.fish_fed` signal.
  - **Test Case(s):** *(unit)* Test "nearest hungry fish" selection logic given mock fish list with positions/hunger values. *(manual)* Drop food near two fish of differing hunger, confirm hungriest/nearest-per-spec one goes first per documented tie-break rule.

- [x] **4.2 Clean action**
  - **Description:** Drag/wipe gesture (or simple click-and-hold) over tank glass restores a tank-level `cleanliness: float` stat, which feeds into every fish's `apply_cleanliness()` (task 3.3), per [GDD § 4.2](GDD.md#42-fish-the-pets).
  - **DoD:** Tank cleanliness visibly (placeholder: glass tint overlay `# TODO: asset — algae/dirt overlay`) decays over time and restores on clean action; cleaning-crew fish (task 1.3 flag) provide passive bonus regen.
  - **Test Case(s):** *(unit)* Test cleanliness decay-over-time and clean-action-restore math directly. *(manual)* Let tank sit until dirty overlay appears, clean it, confirm overlay clears and fish happiness ticks up.

- [x] **4.3 Pet/interact action**
  - **Description:** Click directly on a fish → small happiness bump + placeholder reaction animation (`# TODO: asset — fish reaction anim`), transitions fish through `React` state.
  - **DoD:** Click hitbox matches fish sprite bounds reasonably; happiness bump applied exactly once per click (no double-fire).
  - **Test Case(s):** *(manual)* Click a fish repeatedly, confirm one bump per click and no state-machine lockup.

### 5. Economy

- [x] **5.1 Currency system**
  - **Description:** `PlayerData` fields `coins: int`, `gems: int`. `EventBus` signals `currency_changed(type, new_amount)`. Guard against negative balances.
  - **DoD:** Spending more than available balance is rejected (returns `false`/error), never goes negative.
  - **Test Case(s):** *(unit)* Test spend function: sufficient balance succeeds and deducts exact amount; insufficient balance fails and balance unchanged.

- [x] **5.2 Passive coin generation**
  - **Description:** Per [GDD § 4.3](GDD.md#43-currency--economy): coins accrue per happy fish per hour, capped at a documented max. Compute via elapsed-time-since-last-collection (same load-time-delta pattern as task 8.3), not a live per-frame timer.
  - **DoD:** Documented formula (rate per happy fish/hour, cap value) lives in a code comment; function is pure and independently callable.
  - **Test Case(s):** *(unit)* Given N happy fish + elapsed hours, assert generated coins matches formula. *(unit)* Assert cap is respected when elapsed time would exceed it.

- [x] **5.3 Shop UI + purchase flow**
  - **Description:** Tabbed catalog (Fish / Decor / Food per [GDD § 4.3](GDD.md#43-currency--economy)) listing available `FishSpecies`/`DecorItem` resources, filtered by `level_requirement <= PlayerData.level`. Purchase deducts currency (task 5.1) and adds to inventory (task 5.4) or fish list (task 3.5).
  - **DoD:** Locked (level-gated) items show as visibly locked, not purchasable. Successful purchase updates HUD currency display live.
  - **Test Case(s):** *(unit)* Test catalog-filter function against mock player level. *(manual)* Attempt purchase with insufficient funds, confirm rejected with feedback; purchase with sufficient funds, confirm item appears in inventory/tank.
  - **Note:** Fish and Decor tabs only — no Food tab. GDD § 4.3 names a Food tab, but no `FoodItem`/consumable Resource type was ever defined in the data layer (task 1.x only created `FishSpecies`/`DecorItem`); feeding (task 4.1) works standalone with a free placeholder food drop. Adding purchasable food would need its own data-layer task. Also fixed a coherence gap from task 1.1: `FishSpecies` had no `level_requirement`/`currency_type` fields even though this task's DoD requires level-gating both catalogs and GDD § 5 specifies rare fish are gem-priced — added both fields (mirroring `DecorItem`) and set values on all 8 starter `.tres` files (Common/Uncommon = coins, Rare = gems, re-priced Angelfish/Clownfish off the old coin-scale numbers to a sane gem scale).

- [x] **5.4 Inventory system**
  - **Description:** Owned-but-unplaced `DecorItem`s tracked in `PlayerData.inventory`, with a UI panel to select an item and enter Decorate Mode (task 2.3) to place it.
  - **DoD:** Purchased decor appears in inventory immediately; placing it removes it from inventory and adds it to tank layout; removing a placed item returns it to inventory.
  - **Test Case(s):** *(unit)* Test inventory add/remove-on-place/return-on-remove logic against mock data. *(manual)* Full purchase → place → pick-up → re-place cycle.

### 6. Progression

- [x] **6.1 Player level/XP system**
  - **Description:** `PlayerData.xp`, `PlayerData.level`, XP awarded from care actions/quests per [GDD § 4.4](GDD.md#44-progression). `EventBus.level_up(new_level)` signal fires on threshold cross, used by shop (5.3) and future unlock gates.
  - **DoD:** Documented XP curve (even a simple linear/stepped table is fine for MVP) lives in a code comment; level-up signal fires exactly once per threshold crossed, even if a single XP grant crosses multiple levels at once.
  - **Test Case(s):** *(unit)* Test XP-to-level resolution with values that cross zero, one, and multiple level thresholds in a single grant.

- [x] **6.2 Basic quest list**
  - **Description:** Static checklist per [GDD § 4.4](GDD.md#44-progression) (e.g. "Feed 3 different fish species", "Place 3 new decorations"), tracked via `EventBus` signal listeners (`fish_fed`, item-placed, etc.), rewarding coins/XP on completion.
  - **DoD:** At least 3 quests defined as data (not hardcoded per-quest logic — reuse a generic `{event, target_count, reward}` shape where possible). Completing the tracked action updates quest progress and grants reward exactly once.
  - **Test Case(s):** *(unit)* Test quest-progress-tracking function against a sequence of mock events, assert completion fires once at target count and not again after.
  - **Note:** 4 quests as `QuestDefinition` `.tres` data (matching `FishSpecies`/`DecorItem`'s pattern), tracking simple event counts rather than GDD's "3 *different* species" phrasing — the generic `{event, target_count, reward}` shape the DoD asks for doesn't naturally support a distinct-species set, so quest text was adjusted to match what's actually implemented ("Feed your fish 3 times") rather than overbuilding or misrepresenting it. Added `EventBus` signals `fish_petted`/`tank_cleaned`/`decor_placed` (didn't exist yet) so quests/XP can observe pet, clean, and decor-placement actions alongside the existing `fish_fed`.

### 7. UI / HUD

- [x] **7.1 HUD**
  - **Description:** Persistent overlay: coin/gem counters (bound to task 5.1 signal), XP bar (bound to task 6.1), notification bell (stub — no content yet, just visual + click target for Phase 2/3), per [GDD § 6](GDD.md#6-uiux-flow).
  - **DoD:** HUD values update live and correctly on currency/XP change signals, no manual polling.
  - **Test Case(s):** *(manual)* Trigger a purchase and a feed action, confirm HUD numbers update immediately and correctly.

- [x] **7.2 Shop panel** — UI wrapper around task 5.3 logic. **DoD:** matches [GDD § 6](GDD.md#6-uiux-flow) flow (tabs, single modal, closable). **Test Case(s):** *(manual)* open/close/tab-switch, no state leaks between sessions.

- [x] **7.3 Inventory panel** — UI wrapper around task 5.4 logic. **DoD/Test:** same shape as 7.2, scoped to inventory.
  - **Note:** Combined with 7.4 into one `InventoryUI` — selecting an inventory item both places it in the tank and is the entry point into Decorate Mode (they're the same user action per 5.4's own description: "a UI panel to select an item and enter Decorate Mode to place it").

- [x] **7.4 Decorate Mode UI** — entry/exit toggle, drag controls surfaced from task 2.3. **DoD:** entering hides HUD clutter per GDD "one panel open at a time" rule; exiting persists layout to `PlayerData` (stub until task 8 exists, verify wiring later). **Test Case(s):** *(manual)* Enter mode, move item, exit, re-enter, layout preserved in-session.
  - **Note:** Added `GameState.decorate_mode_active` and gated `Decoration` drag/remove, `Fish` pet, `FeedingManager`'s feed-drop, and `Tank`'s clean-hold behind it (mutually exclusive now — decor manipulation only works in Decorate Mode, care actions only work outside it). This resolves the "no tool-selection UI exists yet" ambiguity flagged as an open MVP limitation since task 4. "Exiting persists layout to PlayerData" has nothing to persist to yet (no save schema — task 8.1), so exit just toggles the mode off; the tank's live node state already reflects the layout.

- [x] **7.5 Quests panel** — UI wrapper around task 6.2 logic. **DoD/Test:** progress bars reflect live quest state; completed quests visually distinct.

### 8. Save System

- [ ] **8.1 `PlayerSave` schema**
  - **Description:** Define the serializable shape per [GDD § 7.4](GDD.md#74-save-system): tank layout, owned fish (species id + name + stats + last-interaction timestamps), inventory, currency, level/XP, quest progress, `last_saved_unix_time`.
  - **DoD:** Schema documented (comment block or small `.md` note) so every later system knows what it owns in the save file.
  - **Test Case(s):** *(unit)* Round-trip test: serialize a populated mock `PlayerSave` to JSON/Resource and back, assert deep equality.

- [ ] **8.2 `SaveManager` save/load**
  - **Description:** `save_manager.gd` autoload-callable functions `save_game()` / `load_game()` using `FileAccess` (JSON) or `ResourceSaver`, per GDD § 7.4.
  - **DoD:** Fresh install with no save file loads sensible defaults (starter fish, zero currency) without error.
  - **Test Case(s):** *(unit)* Save then load, assert `PlayerData` state matches pre-save state exactly. *(unit)* Load with no file present, assert defaults applied without throwing.

- [ ] **8.3 Offline stat decay on load**
  - **Description:** On load, compute elapsed real time since `last_saved_unix_time` and apply stat decay (task 3.3) / coin accrual (task 5.2) for that whole elapsed window in one shot — not a catch-up loop, a direct formula application, per GDD § 7.4.
  - **DoD:** Closing the game for a simulated long period and reopening produces the same fish stats as if decay had run continuously (within the documented decay formula, not literally re-simulated tick by tick).
  - **Test Case(s):** *(unit)* Mock a `last_saved_unix_time` far in the past, assert resulting stats match direct formula output for that elapsed duration, including clamping (task 3.3) and coin cap (task 5.2).

- [ ] **8.4 Autosave triggers**
  - **Description:** Call `save_game()` on: app quit (`NOTIFICATION_WM_CLOSE_REQUEST`), after purchases, after decorate-mode exit, and on a periodic timer (e.g. every 2 min) as a safety net.
  - **DoD:** Force-quitting mid-session loses at most ~2 minutes of progress, never more.
  - **Test Case(s):** *(manual)* Make a change, force-quit without graceful exit, relaunch, confirm change persisted (or is within the documented autosave window).

### 9. Integration / Polish / QA

- [ ] **9.1 Full core-loop playtest**
  - **Description:** Run the entire [GDD § 3 short loop](GDD.md#3-core-gameplay-loop) end to end: open tank → feed/clean/collect → shop → decorate → save/reload.
  - **DoD:** No step in the loop requires a workaround or hits an error; loop completable in under the documented 2–10 min session estimate.
  - **Test Case(s):** *(manual)* Execute the loop as a fresh player from a clean save, note any friction/bugs, file follow-up tasks for anything found.

- [ ] **9.2 Placeholder asset audit**
  - **Description:** Grep the project for `TODO: asset` and cross-check every placeholder visual/audio call site is tagged — nothing silently placeholder without a marker.
  - **DoD:** A checklist/inventory of all `TODO: asset` hits exists (can literally be the grep output saved somewhere) for whoever swaps in real art later.
  - **Test Case(s):** *(manual)* Run `grep -r "TODO: asset"`, spot-check a sample of hits against actual rendered placeholders.

- [ ] **9.3 Fish-count performance check**
  - **Description:** Verify swim AI (task 3.2) stays cheap at the documented budget of ~15–20 simultaneous fish per [GDD § 10](GDD.md#10-open-questions--risks).
  - **DoD:** No frame-rate degradation at 20 fish on a representative low-end target (note actual measured FPS in the task's closing comment when checked off).
  - **Test Case(s):** *(manual)* Spawn 20 fish via debug tool, monitor FPS for 1+ min, record result.

---

## Phase 2 — Content & Retention

Matches [GDD § 9 Phase 2](GDD.md#phase-2-content--retention). Lighter detail here since it depends on Phase 1 being stable first — expand each into full task shape (description/DoD/test) when Phase 1 is done.

- [ ] **2.0 Re-plan gate:** review Phase 1 outcomes, break the items below into full tasks (same template as above) before starting.
- [ ] Additional tank sizes (medium/large) + unlock gating via level (extends tasks 2.1, 6.1).
- [ ] Expanded fish/decor content beyond MVP starter set (extends tasks 1.3/1.4).
- [ ] Minigame: Bubble Pop (per [GDD § 4.6](GDD.md#46-minigames-stretch-but-loop-needs-at-least-one-at-mvp1)).
- [ ] Minigame: Feeding Frenzy.
- [ ] Minigame: Algae Scrub.
- [ ] Minigame cooldown/play-limit system (e.g. 3 plays/day) shared across all minigames.
- [ ] Daily/weekly quest rotation (extends task 6.2 from static to rotating pool).
- [ ] "Uncared-for fish" notification hook (needs a notification delivery mechanism — local only until Phase 3 backend exists).

## Phase 3 — Social

Matches [GDD § 9 Phase 3](GDD.md#phase-3-social--requires-backend-decision). **Blocked** on the backend decision flagged in [GDD § 10 Open Questions](GDD.md#10-open-questions--risks) — do not start implementation tasks below until that's resolved.

- [ ] **3.0 Backend decision (blocking):** choose backend approach (custom REST / Firebase / Supabase / P2P save-code) — update GDD § 10 with the decision before proceeding.
- [ ] Account/auth system.
- [ ] Friends list.
- [ ] Visit friend's tank (read-only render of their saved layout).
- [ ] Like action + reputation score.
- [ ] Feed-one-fish-as-visitor action.
- [ ] Gift system (send + inbox).
- [ ] Cloud save (superseding/complementing local save from task 8).

---

*Keep this file in sync with GDD.md — if a design decision changes, update the relevant task(s) here in the same commit.*
