class_name QuestTracker
extends RefCounted
## Pure quest-progress tracking (TASKS.md 6.2). Given a quest's current
## progress {"count": int, "completed": bool} and an incoming event, returns
## the updated progress. A quest already marked completed no longer
## accumulates count or re-triggers — completion happens exactly once.

static func record_event(progress: Dictionary, quest: QuestDefinition, event_type: QuestDefinition.TrackedEvent) -> Dictionary:
	if progress.get("completed", false):
		return progress
	if quest.tracked_event != event_type:
		return progress
	var count: int = progress.get("count", 0) + 1
	var completed := count >= quest.target_count
	return {"count": count, "completed": completed}
