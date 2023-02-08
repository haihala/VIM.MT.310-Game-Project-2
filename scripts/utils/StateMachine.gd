extends Node

class_name StateMachine

var locked = false

onready var available_states = self.get_children()

var current

func set_state(new_state):
	if locked:
		return push_warning("State machine is locked")
	
	if not available_states.has(new_state):
		return push_error("Unrecognized state")
	
	if new_state == current:
		return push_error("Cannot reactivate current state")

	if current:
		current.exit()
	current = new_state
	current.enter()
