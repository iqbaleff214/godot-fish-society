extends Node
## Autoload: decoupled signal bus so UI/audio/quests can react without tight coupling.
## Signals added per-feature as later tasks need them (see TASKS.md Phase 1).

signal fish_fed(fish: Fish)  # TASKS.md 4.1
signal fish_petted(fish: Fish)  # TASKS.md 4.3 / 6.2 quest tracking
signal tank_cleaned()  # TASKS.md 4.2 / 6.2 quest tracking
signal decor_placed(item: DecorItem)  # TASKS.md 5.4 / 6.2 quest tracking
signal currency_changed(type: DecorItem.CurrencyType, new_amount: int)  # TASKS.md 5.1
signal level_up(new_level: int)  # TASKS.md 6.1
signal quest_completed(quest: QuestDefinition)  # TASKS.md 6.2
signal item_purchased()  # TASKS.md 5.3 / 8.4 autosave trigger
