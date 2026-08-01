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


## Loads every DecorItem .tres under resources/decor_items/ (TASKS.md 5.3).
static func load_all() -> Array[DecorItem]:
	var result: Array[DecorItem] = []
	var dir := DirAccess.open("res://resources/decor_items")
	if dir == null:
		return result
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var item: DecorItem = load("res://resources/decor_items/" + file_name)
			if item != null:
				result.append(item)
		file_name = dir.get_next()
	dir.list_dir_end()
	return result
