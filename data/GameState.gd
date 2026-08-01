extends Node
## Autoload: current scene/session state (not persisted).
## Fields added per-feature as later tasks need them (see TASKS.md Phase 1).

## True while the player is in Decorate Mode (TASKS.md 7.4). Gates
## Decoration drag/remove (only meaningful in this mode) and Fish
## pet / feed-drop / tank-clean (only meaningful outside it) so a single
## click can't be interpreted as two different actions at once — the
## "no tool-selection UI exists yet" gap flagged since task 4.
var decorate_mode_active: bool = false
