extends Node

class_name StateMachine

var stack = []
var locked = false

onready var available_states = self.get_children()

func active_state():
	if stack.size() > 0:
		return stack[-1]


func push(new_state):
	if locked:
		return push_warning("State machine is locked")
	
	if not available_states.has(new_state):
		return push_error("Unrecognized state")
	
	if new_state == active_state():
		return push_error("Cannot reactivate current state")

	if active_state():
		active_state().suspend()
	stack.append(new_state)
	active_state().enter()

func pop():
	if locked:
		return push_warning("State machine is locked")

	active_state().exit()
	stack.pop_back()
	if active_state():
		active_state().re_enter()

func clear_stack():
	while active_state():
		active_state().exit()
		stack.pop_back()

func setup_stack(new_stack):
	clear_stack()
	stack = new_stack
	active_state().enter()
