class_name Tank
extends Node2D
## Tank container: water/swim bounds + floor line + a shared, Y-sorted
## content layer that decor (2.3) and fish (3.5) are both parented under
## so they occlude each other correctly (TASKS.md 2.1, 2.4). Also owns
## tank-level cleanliness — decays over time, restored by the clean action,
## with cleaning-crew fish providing passive bonus regen (TASKS.md 4.2).

const CLEAN_HOLD_SECONDS := 0.5

@export var water_bounds: Rect2 = Rect2(Vector2.ZERO, Vector2(400, 200))
@export var floor_y: float = 200.0

@onready var glass: Polygon2D = $Glass  # TODO: asset — tank glass/backdrop art (placeholder flat color)
@onready var dirt_overlay: Polygon2D = $DirtOverlay  # TODO: asset — algae/dirt overlay (placeholder flat tint; alpha follows cleanliness)
@onready var glass_click_area: Area2D = $GlassClickArea
@onready var contents: Node2D = $Contents

var cleanliness_tracker := TankCleanliness.new()

var _is_holding_clean: bool = false
var _clean_hold_time: float = 0.0


func _ready() -> void:
	if not glass_click_area.input_event.is_connected(_on_glass_click_area_input_event):
		glass_click_area.input_event.connect(_on_glass_click_area_input_event)
	_refresh_dirt_overlay()


func _process(delta: float) -> void:
	cleanliness_tracker.decay(delta, _count_cleaning_crew())
	if _is_holding_clean:
		_clean_hold_time += delta
		if _clean_hold_time >= CLEAN_HOLD_SECONDS:
			clean_tank()
			_is_holding_clean = false
	_refresh_dirt_overlay()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_holding_clean:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if not mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_is_holding_clean = false
			_clean_hold_time = 0.0


func get_water_bounds() -> Rect2:
	return water_bounds


func get_floor_y() -> float:
	return floor_y


func get_contents_node() -> Node2D:
	return contents


func get_cleanliness() -> float:
	return cleanliness_tracker.cleanliness


func clean_tank() -> void:
	cleanliness_tracker.clean()
	_refresh_dirt_overlay()
	EventBus.tank_cleaned.emit()


func _refresh_dirt_overlay() -> void:
	dirt_overlay.modulate.a = (100.0 - cleanliness_tracker.cleanliness) / 100.0 * 0.6


func _count_cleaning_crew() -> int:
	var count := 0
	for child in contents.get_children():
		if child is Fish and child.species != null and child.species.is_cleaning_crew:
			count += 1
	return count


func _on_glass_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# GlassClickArea deliberately spans the whole tank (you can wipe the
	# glass anywhere), so it can overlap Fish/Decoration click areas at the
	# same point. Bail if one of those more-specific handlers already
	# claimed this input. (No UI tool-selection exists yet — TASKS.md 5.3/7.x
	# — to explicitly disambiguate "feed" vs "clean" vs "pet" intent; this
	# ordering guard is the best available MVP-placeholder resolution.)
	if get_viewport().is_input_handled():
		return
	if not (event is InputEventMouseButton):
		return
	var mb := event as InputEventMouseButton
	if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		# Consume so this click doesn't also fall through to FeedingManager's
		# catch-all _unhandled_input and drop food at the same spot.
		get_viewport().set_input_as_handled()
		_is_holding_clean = true
		_clean_hold_time = 0.0
