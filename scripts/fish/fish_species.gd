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
@export var hunger_decay_rate: float = 1.0
@export var happiness_decay_rate: float = 1.0
@export var is_cleaning_crew: bool = false
