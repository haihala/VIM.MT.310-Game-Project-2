extends AnimatedState

onready var hitbox = get_node("../../Hitbox")
onready var attack_sound_player = get_node("../../WeaponSwingPlayer")

func enter():
	.enter()
	hitbox.hit()
	attack_sound_player.play_random()
