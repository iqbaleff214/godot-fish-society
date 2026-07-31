class_name Decoration
extends Node2D
## One placed DecorItem instance: visual, footprint, drag-to-move,
## overlap validation against sibling decor, and removal (TASKS.md 2.3).
## Intended to live under Tank.get_contents_node() alongside fish so
## Y-sort (2.4) orders them together.

signal removed(decoration: Decoration)

@export var item: DecorItem

@onready var visual: Sprite2D = $Visual  # TODO: asset — decoration sprite (currently reuses DecorItem.texture placeholder)
@onready var click_area: Area2D = $ClickArea
@onready var collision_shape: CollisionShape2D = $ClickArea/CollisionShape2D

var _dragging := false
var _drag_offset := Vector2.ZERO
var _last_valid_position := Vector2.ZERO


func _ready() -> void:
	if not click_area.input_event.is_connected(_on_click_area_input_event):
		click_area.input_event.connect(_on_click_area_input_event)
	if item != null:
		setup(item)


func setup(decor_item: DecorItem) -> void:
	item = decor_item
	_last_valid_position = position

	visual.texture = item.texture
	visual.centered = false
	visual.position = item.footprint.position

	var shape := RectangleShape2D.new()
	shape.size = item.footprint.size
	collision_shape.shape = shape
	collision_shape.position = item.footprint.position + item.footprint.size / 2.0


func get_footprint_rect() -> Rect2:
	return Rect2(position + item.footprint.position, item.footprint.size)


func request_remove() -> void:
	removed.emit(self)
	queue_free()


func _get_sibling_footprints() -> Array[Rect2]:
	var footprints: Array[Rect2] = []
	var parent := get_parent()
	if parent == null:
		return footprints
	for sibling in parent.get_children():
		if sibling is Decoration and sibling != self:
			footprints.append(sibling.get_footprint_rect())
	return footprints


func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton):
		return
	var mb := event as InputEventMouseButton
	if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		_dragging = true
		_drag_offset = get_global_mouse_position() - global_position
	elif mb.pressed and mb.button_index == MOUSE_BUTTON_RIGHT:
		request_remove()


func _unhandled_input(event: InputEvent) -> void:
	if not _dragging:
		return
	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position() - _drag_offset
		var valid := DecorationPlacement.is_valid_placement(get_footprint_rect(), _get_sibling_footprints())
		visual.modulate = Color(1, 1, 1) if valid else Color(1, 0.4, 0.4)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if not mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_dragging = false
			_end_drag()


func _end_drag() -> void:
	var valid := DecorationPlacement.is_valid_placement(get_footprint_rect(), _get_sibling_footprints())
	if valid:
		_last_valid_position = position
	else:
		position = _last_valid_position
	visual.modulate = Color(1, 1, 1)
