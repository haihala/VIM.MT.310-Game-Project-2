extends PlayerState

onready var particles = get_node("../../LandingParticles")

func enter():
	.enter()

	if not particles.emitting:
		particles.restart()
