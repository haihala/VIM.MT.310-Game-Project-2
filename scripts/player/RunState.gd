extends AnimatedState

onready var particles = get_node("../../RunningParticles")
onready var footstep_player = get_node("../../FootstepPlayer")


func enter():
	.enter()
	
	particles.emitting = true
	footstep_player.volume_db = -20

func active(_delta):
	if !footstep_player.playing:
		footstep_player.play_random()

func exit():
	particles.emitting = false
	footstep_player.volume_db = 0
