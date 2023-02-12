extends AnimatedState

onready var particles = get_node("../../LandingParticles")
onready var footstep_player = get_node("../../FootstepPlayer")

func enter():
	.enter()
	if not particles.emitting:
		particles.restart()
	footstep_player.play_random()
	
