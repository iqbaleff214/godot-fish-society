class_name Fish
extends Node2D
## Base fish scene driven by a FishSpecies resource (TASKS.md 3.1).
## Owns the Idle/Swim/Eat/React state machine (FishStateMachine), swim
## steering (FishSteering), stats (FishStats), and mood (FishMood).

signal state_changed(new_state: FishStateMachine.State)

const SWIM_SPEED := 40.0
const IDLE_MIN_SECONDS := 1.0
const IDLE_MAX_SECONDS := 3.0
const ARRIVAL_DISTANCE := 2.0

@export var species: FishSpecies

## Player-assigned name (GDD 4.2). Kept separate from Node.name, which has
## its own engine-level character/uniqueness rules.
var display_name: String = ""

@onready var visual: AnimatedSprite2D = $Visual  # TODO: asset — replace placeholder SpriteFrames animation
@onready var mood_icon: Label = $MoodIcon  # TODO: asset — mood icon set (currently a text glyph placeholder)

var stats: FishStats
var current_state: FishStateMachine.State = FishStateMachine.State.IDLE
var current_mood: FishMood.Mood = FishMood.Mood.NEUTRAL

var _tank: Tank
var _swim_target: Vector2 = Vector2.ZERO
var _idle_timer: float = 0.0


func _ready() -> void:
	if species != null:
		setup(species)


func setup(fish_species: FishSpecies) -> void:
	species = fish_species
	stats = FishStats.new(species)

	# current_state starts at IDLE by default (not via transition_to(), which
	# rejects IDLE->IDLE), so _idle_timer needs its own explicit kickoff here —
	# otherwise it stays at 0.0 and the fish skips straight to SWIM on frame 1.
	_idle_timer = randf_range(IDLE_MIN_SECONDS, IDLE_MAX_SECONDS)

	visual.sprite_frames = species.sprite_frames
	if visual.sprite_frames != null and visual.sprite_frames.has_animation("default"):
		visual.play("default")
		var frame_tex := visual.sprite_frames.get_frame_texture("default", 0)
		if frame_tex != null and frame_tex.get_size() != Vector2.ZERO:
			visual.scale = species.size / frame_tex.get_size()

	_refresh_mood()


func set_tank(tank: Tank) -> void:
	_tank = tank


func transition_to(new_state: FishStateMachine.State) -> bool:
	if not FishStateMachine.can_transition(current_state, new_state):
		return false
	current_state = new_state
	state_changed.emit(new_state)
	match new_state:
		FishStateMachine.State.IDLE:
			_idle_timer = randf_range(IDLE_MIN_SECONDS, IDLE_MAX_SECONDS)
		FishStateMachine.State.SWIM:
			_pick_swim_target()
	return true


func _process(delta: float) -> void:
	match current_state:
		FishStateMachine.State.IDLE:
			_idle_timer -= delta
			if _idle_timer <= 0.0:
				transition_to(FishStateMachine.State.SWIM)
		FishStateMachine.State.SWIM:
			_process_swim(delta)


func _process_swim(delta: float) -> void:
	if position.distance_to(_swim_target) <= ARRIVAL_DISTANCE:
		transition_to(FishStateMachine.State.IDLE)
		return
	var previous := position
	position = FishSteering.move_toward_point(position, _swim_target, SWIM_SPEED * delta)
	if _tank != null:
		position = FishSteering.clamp_to_bounds(position, _tank.get_water_bounds())
	var dx := position.x - previous.x
	if dx != 0.0:
		visual.flip_h = dx < 0.0


func _pick_swim_target() -> void:
	if _tank == null:
		_swim_target = position
		return
	var b := _tank.get_water_bounds()
	_swim_target = Vector2(
		randf_range(b.position.x, b.position.x + b.size.x),
		randf_range(b.position.y, b.position.y + b.size.y)
	)


func eat() -> void:
	if not transition_to(FishStateMachine.State.EAT):
		return
	stats.apply_feed()
	_refresh_mood()
	# TODO: asset — eat animation/duration; placeholder returns to Idle immediately
	transition_to(FishStateMachine.State.IDLE)


func pet() -> void:
	if not transition_to(FishStateMachine.State.REACT):
		return
	stats.apply_pet()
	_refresh_mood()
	# TODO: asset — reaction animation/duration; placeholder returns to Idle immediately
	transition_to(FishStateMachine.State.IDLE)


func apply_cleanliness(tank_cleanliness: float) -> void:
	stats.apply_cleanliness(tank_cleanliness)
	_refresh_mood()


func decay_stats(delta_seconds: float) -> void:
	stats.decay(delta_seconds)
	_refresh_mood()


func _refresh_mood() -> void:
	current_mood = FishMood.derive(stats.hunger, stats.happiness)
	mood_icon.text = _mood_glyph(current_mood)
	match current_mood:
		FishMood.Mood.HAPPY:
			visual.speed_scale = 1.4
		FishMood.Mood.SAD, FishMood.Mood.SICK:
			visual.speed_scale = 0.5
		_:
			visual.speed_scale = 1.0


func _mood_glyph(mood: FishMood.Mood) -> String:
	match mood:
		FishMood.Mood.HAPPY:
			return "^_^"
		FishMood.Mood.HUNGRY:
			return "!"
		FishMood.Mood.SAD:
			return "..."
		FishMood.Mood.SICK:
			return "x_x"
		_:
			return ""
