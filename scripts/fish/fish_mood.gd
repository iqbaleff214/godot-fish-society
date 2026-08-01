class_name FishMood
extends RefCounted
## Pure mood-state derivation from hunger/happiness (TASKS.md 3.4).
## No fish state is ever "dead" — the worst case is SICK, always recoverable
## by feeding/petting/cleaning (Pillar 1: cozy, low-pressure care).
##
## Mood thresholds (evaluated in order, first match wins):
##   happiness < 20                    -> SICK
##   happiness < 50 or hunger < 20     -> SAD
##   hunger < 50                       -> HUNGRY
##   hunger >= 80 and happiness >= 80  -> HAPPY
##   otherwise                         -> NEUTRAL

enum Mood { HAPPY, NEUTRAL, HUNGRY, SAD, SICK }


static func derive(hunger: float, happiness: float) -> Mood:
	if happiness < 20.0:
		return Mood.SICK
	if happiness < 50.0 or hunger < 20.0:
		return Mood.SAD
	if hunger < 50.0:
		return Mood.HUNGRY
	if hunger >= 80.0 and happiness >= 80.0:
		return Mood.HAPPY
	return Mood.NEUTRAL
