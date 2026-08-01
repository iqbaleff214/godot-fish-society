extends Node
## Autoload: decoupled signal bus so UI/audio/quests can react without tight coupling.
## Signals added per-feature as later tasks need them (see TASKS.md Phase 1).

signal fish_fed(fish: Fish)  # TASKS.md 4.1
signal currency_changed(type: DecorItem.CurrencyType, new_amount: int)  # TASKS.md 5.1
