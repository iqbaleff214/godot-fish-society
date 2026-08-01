class_name FeedingManager
extends Node
## Feed action: click in the tank's water to drop food; the nearest fish
## below HUNGER_THRESHOLD swims to it and eats (TASKS.md 4.1).
## MVP placeholder: any click in the water drops food. Once a food/inventory
## selection UI exists (5.3/7.2), this should gate on "a food item is
## selected" first rather than firing on every click.

const FOOD_SCENE: PackedScene = preload("res://scenes/tank/Food.tscn")
const HUNGER_THRESHOLD := 90.0

@export var tank_path: NodePath = ^"../Tank"
@onready var tank: Tank = get_node(tank_path)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	var mb := event as InputEventMouseButton
	if not (mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT):
		return
	var local_pos := tank.to_local(tank.get_global_mouse_position())
	if not tank.get_water_bounds().has_point(local_pos):
		return
	drop_food(local_pos)


func drop_food(at_position: Vector2) -> void:
	var target := FeedingLogic.select_target_fish(at_position, _get_fish_in_tank(), HUNGER_THRESHOLD)
	if target == null:
		return

	var food: Node2D = FOOD_SCENE.instantiate()
	tank.get_contents_node().add_child(food)
	food.position = at_position

	target.go_eat(at_position, food)


func _get_fish_in_tank() -> Array[Fish]:
	var result: Array[Fish] = []
	for child in tank.get_contents_node().get_children():
		if child is Fish:
			result.append(child)
	return result
