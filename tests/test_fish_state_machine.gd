extends GutTest
## Unit tests for FishStateMachine transition table (TASKS.md 3.1).


func test_idle_to_swim_allowed() -> void:
	assert_true(FishStateMachine.can_transition(FishStateMachine.State.IDLE, FishStateMachine.State.SWIM))


func test_idle_to_eat_allowed() -> void:
	assert_true(FishStateMachine.can_transition(FishStateMachine.State.IDLE, FishStateMachine.State.EAT))


func test_idle_to_react_allowed() -> void:
	assert_true(FishStateMachine.can_transition(FishStateMachine.State.IDLE, FishStateMachine.State.REACT))


func test_swim_to_eat_allowed() -> void:
	assert_true(FishStateMachine.can_transition(FishStateMachine.State.SWIM, FishStateMachine.State.EAT))


func test_eat_to_idle_allowed() -> void:
	assert_true(FishStateMachine.can_transition(FishStateMachine.State.EAT, FishStateMachine.State.IDLE))


func test_eat_to_swim_allowed() -> void:
	assert_true(FishStateMachine.can_transition(FishStateMachine.State.EAT, FishStateMachine.State.SWIM))


func test_react_to_idle_allowed() -> void:
	assert_true(FishStateMachine.can_transition(FishStateMachine.State.REACT, FishStateMachine.State.IDLE))


func test_eat_to_react_not_allowed() -> void:
	assert_false(FishStateMachine.can_transition(FishStateMachine.State.EAT, FishStateMachine.State.REACT))


func test_react_to_eat_not_allowed() -> void:
	assert_false(FishStateMachine.can_transition(FishStateMachine.State.REACT, FishStateMachine.State.EAT))


func test_eat_to_eat_not_allowed() -> void:
	assert_false(FishStateMachine.can_transition(FishStateMachine.State.EAT, FishStateMachine.State.EAT))


func test_idle_to_idle_not_allowed() -> void:
	assert_false(FishStateMachine.can_transition(FishStateMachine.State.IDLE, FishStateMachine.State.IDLE))
