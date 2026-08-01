class_name QuestsUI
extends Control
## Quests panel (TASKS.md 7.5): one row per PlayerData.quest_definitions
## entry, progress bar sourced from PlayerData.quest_progress, completed
## quests visually distinct (green title + "[DONE]" prefix).

signal closed

@onready var dimmer: ColorRect = $Dimmer
@onready var quest_list: VBoxContainer = $Panel/Margin/VBox/QuestList
@onready var close_button: Button = $Panel/Margin/VBox/CloseButton

const COMPLETED_COLOR := Color(0.4, 1.0, 0.4)


func _ready() -> void:
	visible = false
	close_button.pressed.connect(close)
	dimmer.gui_input.connect(_on_dimmer_input)


func open() -> void:
	visible = true
	_refresh_list()


func close() -> void:
	visible = false
	closed.emit()


func _on_dimmer_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()


func _refresh_list() -> void:
	# remove_child() + queue_free(), not plain free() — see ShopUI's
	# _refresh_list for why.
	for child in quest_list.get_children():
		quest_list.remove_child(child)
		child.queue_free()

	for quest: QuestDefinition in PlayerData.quest_definitions:
		_add_quest_row(quest)


func _add_quest_row(quest: QuestDefinition) -> void:
	var progress: Dictionary = PlayerData.quest_progress.get(quest.id, {"count": 0, "completed": false})
	var count: int = progress.get("count", 0)
	var completed: bool = progress.get("completed", false)

	var row := VBoxContainer.new()

	var title_label := Label.new()
	title_label.text = ("[DONE] " if completed else "") + quest.title
	if completed:
		title_label.modulate = COMPLETED_COLOR
	row.add_child(title_label)

	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = quest.target_count
	bar.value = mini(count, quest.target_count)
	row.add_child(bar)

	quest_list.add_child(row)
