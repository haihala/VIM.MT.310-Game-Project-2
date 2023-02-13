extends Node2D


func emit():
	for child in get_children():
		child.restart()
