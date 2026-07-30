# Fish Society — Game Design Document

**Version:** 0.1 (Draft)
**Engine:** Godot 4.7 (Forward+ renderer)
**Genre:** 2D Life-Simulation / Virtual Pet
**Platform (target):** PC/Web first (desktop + browser export), mobile-friendly UI from the start
**Inspiration:** Pet Society (Playfish), Tamagotchi, Animal Crossing (decorating loop), Aquarium/fish-tank sims

---

## 1. Elevator Pitch

Fish Society is a cozy 2D life-sim where players own and decorate a fish tank, care for a growing collection of fish, and visit friends' tanks. It takes the "own a pet, decorate its home, hang out with friends" loop of Pet Society and re-skins it entirely around aquarium life — fish, corals, snails, shrimp — instead of cats and dogs.

## 2. Vision & Pillars

Every feature should be checked against these three pillars. If it doesn't support at least one, cut it.

1. **Cozy, low-pressure care** — Fish should never "die" from neglect in a way that punishes the player harshly. Neglect leads to sad/dirty states, not permanent loss. No fail states, no game over.
2. **Personal expression through decorating** — The tank is the player's canvas. Depth comes from combining decorations, layouts, and fish species, not from grinding stats.
3. **Social show-and-tell** — The best part of Pet Society was visiting friends. Fish Society should make other players' tanks worth visiting (leaderboards optional, admiration/gifting mandatory).

## 3. Core Gameplay Loop

**Short loop (per session, 2–10 min):**
1. Open tank → see fish state (hunger/happy/clean) via icons.
2. Feed fish, clean tank, collect coins generated since last visit.
3. Play a quick minigame or two for bonus coins/XP.
4. Spend coins on new decor/fish in the shop.
5. Visit 1–2 friends' tanks, leave a "like"/gift, maybe feed their fish once.

**Mid loop (per week):**
- Unlock new fish species / decoration sets via level-up.
- Complete simple quests ("feed 3 different fish species", "own 5 plants").
- Expand tank size (more room to decorate, more fish slots).

**Long loop (weeks/months):**
- Collection completion (fish species, decor sets, rare/event items).
- Tank prestige/reputation score from friend visits and likes.
- Seasonal/event content (limited-time fish & decor).

## 4. Core Systems

### 4.1 The Tank
- The tank is the player's primary "room," rendered as a 2D side-view aquarium (like a cross-section), similar to how Pet Society rendered a room.
- Tank has a **floor area** (where decor/plants/gravel go) and **free water space** (where fish swim, decor like driftwood/rocks can float mid-column).
- Tank size is a progression gate: starter tank → medium → large, each unlocked by player level or currency. Larger tanks = more decoration slots + more fish slots.
- Grid-free placement (like Pet Society/Animal Crossing furniture placement) with simple collision so decor doesn't overlap. Fish swim freely, ignore collision with decor (only avoid tank glass bounds).

### 4.2 Fish (the "pets")
Each fish is an entity with:
- **Species** (defines base sprite, animation set, size, swim behavior, rarity, base price).
- **Name** (player-assigned).
- **Stats:** Hunger, Happiness, Cleanliness-sensitivity (0–100 each, decay over real time).
- **Age/Growth stage** (optional stretch feature — fish sprite scales up over time from "juvenile" to "adult").
- **Mood state** derived from stats: Happy / Neutral / Hungry / Sad / Sick — drives a small icon over the fish and its animation (energetic swim vs. sluggish/hiding).

Fish never die. Prolonged neglect caps happiness/coin generation and eventually the fish "hides" behind decor until cared for again — a soft punishment, not a hard one, per Pillar 1.

**Care actions:**
- **Feed** — click fish food item, drop into tank, nearest hungry fish swims to eat it. Restores Hunger, small Happiness bump.
- **Clean** — wipe algae off glass / scoop debris via a short minigame or a simple drag gesture. Restores tank Cleanliness, which passively affects all fish Happiness.
- **Pet/Interact** — click a fish directly for a small Happiness bump and a cute reaction animation (bonus, low dev cost, high charm value).

### 4.3 Currency & Economy
- **Coins** — soft currency. Earned passively over time (per happy fish per hour, capped), from minigames, from quests, from visiting friends.
- **Gems** (premium/rare currency) — from leveling up, achievements, or events. Used for premium decor/fish skins. (If monetization is ever added, gems are the IAP currency — but design it now as a rare-earn currency regardless.)
- **Shop** — categorized catalog: Fish, Plants, Decor (rocks/castles/etc.), Gravel/Substrate, Backgrounds, Food types. Each item has a coin or gem price, and a level-gate.

### 4.4 Progression
- **Player level**, driven by XP from care actions, minigames, quests, decorating milestones.
- Leveling unlocks: new tank sizes, new shop items, new fish species, new minigames.
- **Quests/Tasks** — simple daily/weekly checklist (e.g., "Feed your fish 5 times", "Place 3 new decorations") rewarding coins/XP. Keeps the loop directed without being demanding.

### 4.5 Social — Visiting Friends
- Friend list (design placeholder for whatever backend/auth is chosen later — see Open Questions).
- Visiting a friend's tank: read-only camera pan/zoom of their tank, fish animate normally.
- Visitor actions: **Like** the tank (counts toward host's reputation score), **Feed one fish** (small goodwill action, doesn't consume host resources), **Leave a gift** (costs visitor coins, appears in host's gift inbox next login).
- **Reputation/Popularity score** on player profile, from cumulative likes/visits — cosmetic bragging right, not pay-gated.

### 4.6 Minigames (stretch, but loop needs at least one at MVP+1)
Lightweight, thematically tied to fish care, e.g.:
- **Bubble Pop** — pop rising bubbles for coins before they hit the tank rim.
- **Feeding Frenzy** — time-limited feeding challenge, feed as many fish as possible without overfeeding.
- **Algae Scrub** — reflex/rhythm minigame cleaning tank glass.
Each grants coins/XP, cooldown-limited (e.g., 3 plays per day) to avoid loop dominance over the core care/decorate loop.

## 5. Fish Species & Rarity

| Rarity | Examples | Unlock method |
|---|---|---|
| Common | Guppy, Neon Tetra, Goldfish | Shop, low level |
| Uncommon | Betta, Molly, Corydoras | Shop, mid level |
| Rare | Angelfish, Discus, Clownfish | Shop (gems) or quests |
| Exotic/Event | Axolotl, Seahorse, Jellyfish | Events / achievements |

Non-fish tank life (shrimp, snails, crabs) counts as "fish" for system purposes but serves a secondary role: cleaning crew (small passive Cleanliness regen bonus) — gives them mechanical purpose beyond decoration.

Design each species as a **data resource**, not hardcoded logic (see Section 7.3) so adding new species is a content task, not a code task.

## 6. UI/UX Flow

```
[Title/Login] → [My Tank (main view)]
                    ├── [Shop] (Fish / Decor / Food tabs)
                    ├── [Inventory] (owned unplaced items)
                    ├── [Decorate Mode] (drag/place/rotate/delete)
                    ├── [Quests]
                    ├── [Friends List] → [Visit Friend's Tank]
                    ├── [Minigames Hub]
                    └── [Player Profile] (level, coins, gems, reputation)
```
- Main view is always the tank, fullscreen, camera fixed (no scroll needed at small tank sizes; light pan/zoom once tanks get large).
- Persistent HUD: coin/gem counter, level/XP bar, notification bell (gifts, friend activity).
- Minimal modal stacking — one panel open at a time to keep it mobile-friendly.

## 7. Technical Design (Godot-specific)

### 7.1 Suggested scene structure
```
res://
  scenes/
    main/            MainMenu.tscn, TankView.tscn (root gameplay scene)
    tank/            Tank.tscn (container: water bounds, glass, floor)
                      Fish.tscn (base fish scene, reused per species via data)
                      Decoration.tscn (base placeable item scene)
    ui/               HUD.tscn, Shop.tscn, Inventory.tscn, DecorateMode.tscn,
                      Quests.tscn, FriendsList.tscn, Minigames/*.tscn
  scripts/
    fish/             fish.gd (state machine: Idle/Swim/Eat/React), fish_stats.gd
    tank/              tank_manager.gd (spawns fish/decor, owns save state)
    economy/           currency.gd, shop.gd
    save/              save_manager.gd
  resources/
    fish_species/      *.tres (FishSpecies Resource: sprite, stats, price, rarity)
    decor_items/        *.tres (DecorItem Resource: sprite, footprint, price)
  data/                autoloads: GameState.gd, PlayerData.gd
```

### 7.2 Fish behavior (2D swim AI)
- Simple steering: each fish picks a random target point within tank water bounds, swims toward it (tween or `move_toward` on velocity), idles briefly, repeats.
- Flip sprite horizontally based on movement direction; use `AnimatedSprite2D` for idle/swim/eat states.
- Avoid overlap with tank glass via clamped bounds (`Rect2` water area), not full physics — keep it cheap, this is not a sim needing collision physics between fish.
- Consider a lightweight flocking bias (slight attraction to same-species fish) as a later polish pass — not MVP.

### 7.3 Data-driven content
- Define `FishSpecies` and `DecorItem` as custom `Resource` scripts (`class_name FishSpecies extends Resource`) with exported fields (sprite frames, base price, rarity enum, stat decay rates, footprint size).
- Content designers/devs add new fish/decor by duplicating a `.tres` resource file, no script changes required. This is the single most important technical decision for keeping content scalable solo-dev.

### 7.4 Save system
- MVP: local save via `FileAccess` + JSON or Godot's `ResourceSaver` for a `PlayerSave` resource (tank layout, owned fish w/ stats+names, inventory, currency, level/XP, quest progress).
- Stat decay calculated on load using timestamp delta (store `last_saved_unix_time`), not a background always-running timer — keeps it simple and correct even if the game isn't running.
- Multiplayer/social (friends, visiting) requires a backend — out of scope for local MVP, flagged in Open Questions.

### 7.5 Autoload singletons (proposed)
- `GameState` — current scene/session state.
- `PlayerData` — currency, level, XP, owned fish/decor, quest progress. Single source of truth, saved/loaded here.
- `EventBus` — decoupled signals (e.g., `fish_fed`, `item_purchased`, `level_up`) so UI/audio/quests can react without tight coupling.

## 8. Art & Audio Direction

- **Art style:** Flat-color, soft-outline 2D, high-saturation cozy palette (similar tone to Pet Society/Animal Crossing) — friendly and readable at small sizes for mobile.
- **Fish sprites:** Simple 2–4 frame swim animation, side-profile, exaggerated cute proportions (big eyes) over realism.
- **Tank rendering:** Layered parallax background (back glass/backdrop image, mid water tint overlay, front glass reflection sheen as a subtle overlay), gravel/floor layer, decor sorted by y-position for simple depth.
- **Audio:** Ambient bubbling/water loop, soft plinky feed/click SFX, gentle upbeat background music loop, distinct "happy fish" chime.

## 9. Scope Plan

### MVP (playable core loop, single player, no backend)
- One tank size, place/remove decor, 5–8 starter fish species.
- Feed, clean, pet interactions with stat decay + mood states.
- Coin economy, shop for fish/decor, basic quest list.
- Local save/load.
- Core UI: Tank view, Shop, Inventory, Decorate mode, HUD.

### Phase 2 (content + retention)
- Additional tank sizes, more species/decor, leveling & unlock gates.
- 1–2 minigames.
- Daily/weekly quests, notifications for uncared-for fish.

### Phase 3 (social — requires backend decision)
- Friends list, visiting tanks, likes/gifts, reputation score.
- Possibly cloud save tied to account system.

## 10. Open Questions / Risks

- **Backend for social features:** none chosen yet. Options: custom REST backend, Firebase/Supabase, or a P2P-lite "share a save code" workaround for a lightweight MVP of visiting. Needs a decision before Phase 3 work starts.
- **Monetization:** not required for a personal/portfolio project, but gems currency is designed to support it later without rework if desired.
- **Export targets:** confirm final priority between Web (itch.io style) and Mobile — affects UI scaling and input assumptions (touch vs. mouse) early.
- **Fish count performance:** define a max simultaneous fish-on-screen budget (suggest ~15–20 for MVP tank) to keep swim-AI cheap.

---
*This is a living document — update as systems are prototyped and design decisions firm up.*
