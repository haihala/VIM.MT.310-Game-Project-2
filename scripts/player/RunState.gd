extends PlayerState

onready var particles = get_node("../../RunningParticles")
onready var footstep_player = get_node("../../FootstepPlayer")

func enter():
	.enter()
	
	particles.emitting = true
	footstep_player.play_footsteps = true

func exit():
	particles.emitting = false
	footstep_player.play_footsteps = false
