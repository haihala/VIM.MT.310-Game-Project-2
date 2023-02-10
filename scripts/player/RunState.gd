extends PlayerState

onready var particles = get_node("../../RunningParticles")
onready var footstep_player = get_node("../../FootstepPlayer")


func enter():
	.enter()
	
	particles.emitting = true
	footstep_player.play_footsteps = true
	footstep_player.volume_db = -20

func exit():
	particles.emitting = false
	footstep_player.play_footsteps = false
	footstep_player.volume_db = 0
