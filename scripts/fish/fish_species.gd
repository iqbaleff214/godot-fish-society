class_name FishSpecies
extends Resource
## Data definition for a fish (or other tank-life) species (TASKS.md 1.1).
## New species are added by duplicating a .tres of this type — no script changes needed.

enum Rarity { COMMON, UNCOMMON, RARE, EXOTIC }

@export var id: String = ""
@export var display_name: String = ""
@export var sprite_frames: SpriteFrames
@export var size: Vector2 = Vector2(32, 18)
@export var rarity: Rarity = Rarity.COMMON
@export var base_price: int = 0
## level_requirement/currency_type added for TASKS.md 5.3 (shop level-gating
## and GDD § 5's "Rare fish purchased with gems" — reuses DecorItem's
## CurrencyType enum rather than duplicating it).
@export var level_requirement: int = 1
@export var currency_type: DecorItem.CurrencyType = DecorItem.CurrencyType.COIN
@export var hunger_decay_rate: float = 1.0
@export var happiness_decay_rate: float = 1.0
@export var is_cleaning_crew: bool = false


## Loads every FishSpecies .tres under resources/fish_species/ (TASKS.md 5.3/3.5
## share this enumeration — kept here as the single source of truth for it).
static func load_all() -> Array[FishSpecies]:
	var result: Array[FishSpecies] = []
	var dir := DirAccess.open("res://resources/fish_species")
	if dir == null:
		return result
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var species: FishSpecies = load("res://resources/fish_species/" + file_name)
			if species != null:
				result.append(species)
		file_name = dir.get_next()
	dir.list_dir_end()
	return result
