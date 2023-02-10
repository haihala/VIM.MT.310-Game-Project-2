extends AnimatedState

class_name RunState

var vel : Vector2 = Vector2()
export var max_speed : float = 150
export var ground_speed_influence : float = 200
export var ground_friction : float = 10
export var air_speed_influence : float = 5
export var air_friction : float = 1

onready var particles = get_node("../../RunningParticles")
onready var footstep_player = get_node("../../FootstepSoundPlayer")
onready var parent = get_node("../..")

func enter():
	.enter()
	
	particles.emitting = true
	footstep_player.volume_db = -20

func active(_delta):
	if !footstep_player.playing:
		footstep_player.play_random()
	handle_movement()

func exit():
	particles.emitting = false
	footstep_player.volume_db = 0

func handle_movement():
	var influence
	var friction
	
	if parent.is_on_floor():
		influence = ground_speed_influence
		friction = ground_friction
	else:
		influence = air_speed_influence
		friction = air_friction

	# Add influence
	vel.x += parent.forward * influence
	
	# Friction
	if abs(vel.x) < friction:
		vel.x = 0
	else:
		vel.x = sign(vel.x)*(abs(vel.x)-friction)
	
	# Enforce top speed
	vel.x = clamp(vel.x, -max_speed, max_speed)
	vel = parent.move_and_slide(vel, Vector2.UP)
