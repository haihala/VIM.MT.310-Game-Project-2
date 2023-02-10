extends AnimatedState

export var last_active_frame: int

onready var hitbox = get_node("../../Hitbox")
onready var attack_sound_player = get_node("../../WeaponSwingPlayer")

func enter():
	.enter()
	hitbox.hit()
	attack_sound_player.play_random()

func active(_delta):
	if sprite.frame >= last_active_frame and hitbox.active:
		hitbox.end_attack()

func exit():
	if hitbox.active:
		hitbox.end_attack()
