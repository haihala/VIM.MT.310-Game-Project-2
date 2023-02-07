extends KinematicBody2D

var score : int = 0
var dead : bool = false
var desired_animation : String = ""
var grounded : bool = false

# Movement
var vel : Vector2 = Vector2()
var speed : float = 200
var ground_speed_influence : float = 200
var ground_friction : float = 10
var air_speed_influence : float = 5
var air_friction : float = 1

# Jumping
# Calculate jump properties from easily reasonable concepts
# Tweak theses
export var jump_height : float = 3	# In tiles
export var jump_duration : float = 0.6	# In seconds

# Use these in code
var time_to_apex = jump_duration/2	# Equations assume we'll only consider one-way travel
var jump_height_pixels = jump_height * 16;	# Tiles are 32 by 32, but for some reason this needs to be doubled
var gravity : float = 2*jump_height_pixels / pow(time_to_apex, 2)
var jump_impulse : float = (gravity * time_to_apex) + (jump_height_pixels / time_to_apex)

onready var sprite = $AnimatedSprite
onready var landing_particles = $LandingParticles
onready var running_particles = $RunningParticles
onready var coin_pickup_player = $CoinPickupPlayer
onready var footstep_player = $FootstepPlayer
onready var ui = get_node("/root/MainScene/CanvasLayer/UI")

var footsteps = []
func _ready():
	for i in range(10):
		footsteps.append(load("res://assets/kenney_rgpaudio/footstep0%s.ogg" % i))

func _physics_process (delta):
	handle_movement(delta)
	handle_landing()

func handle_movement(delta):
	var influence = 0
	var friction = speed	# Default to a high number in case the player dies
	var delta_x = 0
	
	if not dead:
		if Input.is_action_pressed("move_left"):
			delta_x -= 1
		if Input.is_action_pressed("move_right"):
			delta_x += 1
		
		if is_on_floor():
			if Input.is_action_pressed("jump"):
				vel.y -= jump_impulse
				jump_animation()
			influence = ground_speed_influence
			friction = ground_friction
		else:
			influence = air_speed_influence
			friction = air_friction

	# Add influence
	vel.x += (delta_x * influence)
	
	# Friction
	if abs(vel.x) < friction:
		vel.x = 0
	else:
		vel.x = sign(vel.x)*(abs(vel.x)-friction)
	
	# Enforce top speed
	vel.x = clamp(vel.x, -speed, speed)
	vel.y += gravity*delta
	vel = move_and_slide(vel, Vector2.UP)

func handle_landing():
	if is_on_floor():
		if not grounded:
			# Just landed
			desired_animation = "land"
			if not landing_particles.emitting:
				landing_particles.restart()
			# Hold the animation for a while, idle won't take over unless grounded is true
			yield(get_tree().create_timer(0.1), "timeout")
			grounded = true
	else:
		grounded = false

func jump_animation():
	desired_animation = "jump"
	# Wait for half the time it gets to get to the apex
	yield(get_tree().create_timer(time_to_apex/2), "timeout")
	desired_animation = "fall"

func _process(_delta):
	update_sprite()
	update_particles()
	update_footsteps()

func update_sprite():
	if abs(vel.x) > 0:
		Utils.flip_sprite(sprite, vel.x < 0)

	if dead:
		desired_animation = "die"
	elif grounded:
		if abs(vel.x) > 0:
			desired_animation = "run"
		else:
			desired_animation = "idle"

	if sprite.animation != desired_animation:
		sprite.play(desired_animation)

func update_particles():
	var should_emit = desired_animation == "run"
	running_particles.emitting = should_emit

func update_footsteps():
	if is_on_floor() and vel.x != 0:
		if not footstep_player.playing:
			randomize()
			footstep_player.stream = footsteps[randi() % len(footsteps)]
			footstep_player.play()
	else:
		footstep_player.stop()

func die ():
	# Can't die twice
	if not dead:
		dead = true
		# Wait some time so the animation plays out
		yield(get_tree().create_timer(4), "timeout")
		var _reload_output = get_tree().reload_current_scene()


# called when we run into a coin
func collect_coin (value):
	score += value
	coin_pickup_player.play()
	ui.set_score_text(score)
