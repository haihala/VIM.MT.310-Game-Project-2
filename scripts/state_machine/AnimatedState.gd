extends State

class_name AnimatedState

export var animation: String
onready var sprite = get_node("../../AnimatedSprite")

func enter():
	if sprite.animation == animation:
		sprite.frame = 0
	else:
		sprite.play(animation)
