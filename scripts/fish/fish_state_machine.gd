class_name FishStateMachine
extends RefCounted
## Pure Idle/Swim/Eat/React transition table for Fish (TASKS.md 3.1).
## Eat and React can't transition directly into each other (or repeat
## themselves) — both must pass back through Idle or Swim first.

enum State { IDLE, SWIM, EAT, REACT }

const ALLOWED_TRANSITIONS := {
	State.IDLE: [State.SWIM, State.EAT, State.REACT],
	State.SWIM: [State.IDLE, State.EAT, State.REACT],
	State.EAT: [State.IDLE, State.SWIM],
	State.REACT: [State.IDLE, State.SWIM],
}


static func can_transition(from: State, to: State) -> bool:
	return ALLOWED_TRANSITIONS.get(from, []).has(to)
