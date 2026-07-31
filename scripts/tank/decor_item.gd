class_name DecorItem
extends Resource
## Data definition for a placeable tank decoration (TASKS.md 1.2).
## New decor is added by duplicating a .tres of this type — no script changes needed.

enum Category { PLANT, DECOR, GRAVEL, BACKGROUND }
enum CurrencyType { COIN, GEM }

@export var id: String = ""
@export var display_name: String = ""
@export var texture: Texture2D
@export var footprint: Rect2 = Rect2(Vector2.ZERO, Vector2(32, 32))
@export var category: Category = Category.DECOR
@export var price: int = 0
@export var currency_type: CurrencyType = CurrencyType.COIN
@export var level_requirement: int = 1
