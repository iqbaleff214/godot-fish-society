# How to Play — Fish Society

A quick player's guide to what's actually in the game right now (Phase 1 / MVP). All art is placeholder — see [TODO_ASSETS.md](TODO_ASSETS.md) — but everything described here works.

## The Goal

Take care of your fish tank: feed and pet your fish, keep the glass clean, decorate the tank, and grow your collection by earning coins and gems. Fish never die from neglect — the worst that happens is they get sad/sick-looking until you look after them again.

## Getting Started

Press **Play** — you'll start with one Guppy and an empty wallet. The tank view is always the main screen.

## Caring for Your Fish

These all happen by clicking directly in the tank, and only work when you're **not** in Decorate Mode (see below):

- **Pet a fish** — click directly on it. Small happiness boost.
- **Feed** — click anywhere in the open water. A bit of food drops, and the nearest hungry fish swims over to eat (this doesn't cost anything right now).
- **Clean the tank** — click and hold on the glass for about half a second. Restores tank cleanliness (fish with the "cleaning crew" trait, like shrimp, help keep it clean passively too).

Each fish shows a small mood icon above it based on its hunger/happiness:

| Icon | Mood | What it means |
|---|---|---|
| `^_^` | Happy | Well fed and content — earns you the most passive coins |
| *(none)* | Neutral | Doing fine |
| `!` | Hungry | Needs feeding |
| `...` | Sad | Needs feeding, petting, or a cleaner tank |
| `x_x` | Sick | Really needs attention — but it always recovers once cared for |

## The HUD

Along the top:
- **Coins** / **Gems** — your two currencies. Coins are earned from quests and passively from happy fish over time (collected automatically when you return to the game). Gems are rarer and used for premium items.
- **Level** and **XP bar** — you gain XP from caring for your fish and completing quests. Leveling up unlocks higher-tier shop items.
- **Bell icon** — currently just a placeholder, doesn't do anything yet.

Buttons: **Shop**, **Decorate**, **Quests**.

## Shop

Click **Shop** to browse two tabs:
- **Fish** — buy new species. Common fish cost coins; rarer fish cost gems.
- **Decor** — plants, gravel, backgrounds, and decorations.

Items you don't have the level for yet show up greyed out with the level requirement listed. Buying a fish adds it straight to your tank; buying decor adds it to your inventory (not placed yet — see Decorate Mode).

## Decorate Mode

Click **Decorate** to enter it. While decorating:
- The HUD's top bar and buttons hide to keep things uncluttered.
- Pick an item from your inventory list to place it in the tank.
- **Drag** any placed decoration to reposition it — it'll snap back if you try to overlap another item.
- **Right-click** a placed decoration to remove it and send it back to your inventory.
- Click **Done Decorating** to exit. (Feeding/petting/cleaning are disabled while decorating, and vice versa — only one "mode" is active at a time.)

## Quests

Click **Quests** to see your active checklist and progress bars. Completed quests are shown in green with a `[DONE]` tag and their reward (coins + XP) is granted automatically the moment you finish them.

## Saving

There's no manual save button — the game saves automatically:
- After every purchase
- Whenever you exit Decorate Mode
- Every 2 minutes as a safety net
- When you quit the game

So worst case, force-quitting mid-session loses only your last couple of minutes.

## What's Not In Yet

Minigames, visiting friends' tanks, and purchasable food are all planned for later (see [TASKS.md](TASKS.md)) but not part of this build.
