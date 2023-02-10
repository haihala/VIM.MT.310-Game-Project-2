extends Node

class_name State

## Called when this is pushed onto the stack
func enter():
	pass

## Called each tick when this is active
func active(_delta):
	pass

## Called when this is removed from the stack
func exit():
	pass
