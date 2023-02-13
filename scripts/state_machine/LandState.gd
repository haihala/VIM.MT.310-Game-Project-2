extends AnimatedState

onready var particles = get_node("../../CharacterParticles")
onready var sound_player = get_node("../../CharacterAudio")

func enter():
	.enter()
	particles.land()
	sound_player.footstep()
	
