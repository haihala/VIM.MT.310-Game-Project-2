extends State

class_name PlayerState

export var animation: String
onready var sprite = get_node("../../AnimatedSprite")

func enter():
	if sprite.animation != animation:
		sprite.play(animation)
