extends AnimatedState

onready var particles = get_node("../../CharacterParticles")
onready var sound_player = get_node("../../CharacterAudio")

export var interval : float = 0.5
var last_sound

func enter():
	.enter()
	particles.start_running()
	play_footstep()

func active(_delta):
	if play_next():
		play_footstep()

func play_next():
	var time = OS.get_system_time_msecs()
	return last_sound + 1000*interval < time

func play_footstep():
	print("Playing footstep")
	sound_player.footstep(-10)
	last_sound = OS.get_system_time_msecs()

func exit():
	particles.stop_running()
