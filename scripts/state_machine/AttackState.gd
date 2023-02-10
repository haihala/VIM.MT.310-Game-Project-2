extends AnimatedState

class_name AttackState

export var first_active_frame: int
export var last_active_frame: int

onready var hitbox = get_node("../../Hitbox")
onready var attack_sound_player = get_node("../../AttackSoundPlayer")

func enter():
	.enter()
	attack_sound_player.play_random()
	if first_active_frame == 0:
		hitbox.start_attack()

func active(_delta):
	if sprite.frame >= last_active_frame:
		# Early ending
		if hitbox.active:
			hitbox.end_attack()
	elif sprite.frame >= first_active_frame:
		# Late activation for enemy attacks
		if not hitbox.active:
			hitbox.start_attack()

func exit():
	# End the attack if state interrupted, for example when getting hit
	if hitbox.active:
		hitbox.end_attack()
