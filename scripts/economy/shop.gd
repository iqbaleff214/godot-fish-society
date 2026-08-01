class_name Shop
extends RefCounted
## Pure shop catalog filtering + affordability checks (TASKS.md 5.3).
## Actual currency deduction / inventory or fish-list mutation happens in
## ShopManager once a purchase is confirmed — this class only decides
## what's visible/purchasable given a player's level and balance.

static func is_unlocked(level_requirement: int, player_level: int) -> bool:
	return player_level >= level_requirement


static func filter_unlocked_fish(catalog: Array, player_level: int) -> Array[FishSpecies]:
	var result: Array[FishSpecies] = []
	for species: FishSpecies in catalog:
		if is_unlocked(species.level_requirement, player_level):
			result.append(species)
	return result


static func filter_unlocked_decor(catalog: Array, player_level: int) -> Array[DecorItem]:
	var result: Array[DecorItem] = []
	for item: DecorItem in catalog:
		if is_unlocked(item.level_requirement, player_level):
			result.append(item)
	return result


static func can_afford(price: int, currency_type: DecorItem.CurrencyType, coins: int, gems: int) -> bool:
	if currency_type == DecorItem.CurrencyType.GEM:
		return gems >= price
	return coins >= price
