extends GutTest
## Unit tests for QuestTracker (TASKS.md 6.2).


func _make_quest(event: QuestDefinition.TrackedEvent, target: int) -> QuestDefinition:
	var q := QuestDefinition.new()
	q.tracked_event = event
	q.target_count = target
	return q


func test_record_event_ignores_non_matching_event() -> void:
	var quest := _make_quest(QuestDefinition.TrackedEvent.FISH_FED, 3)
	var progress := {"count": 0, "completed": false}
	var result := QuestTracker.record_event(progress, quest, QuestDefinition.TrackedEvent.FISH_PETTED)
	assert_eq(result, progress)


func test_record_event_increments_count_on_matching_event() -> void:
	var quest := _make_quest(QuestDefinition.TrackedEvent.FISH_FED, 3)
	var progress := {"count": 0, "completed": false}
	var result := QuestTracker.record_event(progress, quest, QuestDefinition.TrackedEvent.FISH_FED)
	assert_eq(result["count"], 1)
	assert_false(result["completed"])


func test_record_event_completes_at_target_count() -> void:
	var quest := _make_quest(QuestDefinition.TrackedEvent.FISH_FED, 3)
	var progress := {"count": 2, "completed": false}
	var result := QuestTracker.record_event(progress, quest, QuestDefinition.TrackedEvent.FISH_FED)
	assert_eq(result["count"], 3)
	assert_true(result["completed"])


func test_record_event_does_not_progress_past_completion() -> void:
	var quest := _make_quest(QuestDefinition.TrackedEvent.FISH_FED, 3)
	var progress := {"count": 3, "completed": true}
	var result := QuestTracker.record_event(progress, quest, QuestDefinition.TrackedEvent.FISH_FED)
	assert_eq(result, progress)
	assert_eq(result["count"], 3)


func test_full_sequence_completes_exactly_once() -> void:
	var quest := _make_quest(QuestDefinition.TrackedEvent.FISH_FED, 3)
	var progress := {"count": 0, "completed": false}
	var completions := 0
	for i in range(5):
		var before_completed: bool = progress.get("completed", false)
		progress = QuestTracker.record_event(progress, quest, QuestDefinition.TrackedEvent.FISH_FED)
		if progress["completed"] and not before_completed:
			completions += 1
	assert_eq(completions, 1)
	assert_eq(progress["count"], 3)
