extends Node

class_name StateMachine

onready var available_states = self.get_children()

var current

func _physics_process(delta):
	if current:
		current.active(delta)

func set_state(new_state, reactivate_ok = false):
	if not available_states.has(new_state):
		return push_error("Unrecognized state")
	
	if new_state == current and not reactivate_ok:
		return push_error("Cannot reactivate current state")

	if current:
		current.exit()
	current = new_state
	current.enter()
