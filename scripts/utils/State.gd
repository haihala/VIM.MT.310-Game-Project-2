extends Node

class_name State

## Called when this is pushed onto the stack
func enter():
	pass

## Called when this is removed from the stack
func exit():
	pass
	
## Called when the state above this gets removed from the stack
func re_enter():
	enter()

## Called when another state is pushed on the stack on top of this
func suspend():
	exit()
