class_name Tank
extends Node2D
## Tank container: water/swim bounds + floor line + a shared, Y-sorted
## content layer that decor (2.3) and fish (3.5) are both parented under
## so they occlude each other correctly (TASKS.md 2.1, 2.4).

@export var water_bounds: Rect2 = Rect2(Vector2.ZERO, Vector2(400, 200))
@export var floor_y: float = 200.0

@onready var glass: Polygon2D = $Glass  # TODO: asset — tank glass/backdrop art (placeholder flat color)
@onready var contents: Node2D = $Contents


func get_water_bounds() -> Rect2:
	return water_bounds


func get_floor_y() -> float:
	return floor_y


func get_contents_node() -> Node2D:
	return contents
