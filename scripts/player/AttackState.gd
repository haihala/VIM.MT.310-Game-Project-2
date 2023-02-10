extends PlayerState

onready var hitbox = get_node("../../Hitbox")

func enter():
	.enter()
	hitbox.hit()
	# TODO: Play sound
