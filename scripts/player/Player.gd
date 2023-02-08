extends KinematicBody2D

var score : int = 0
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

onready var state_machine = $StateMachine
onready var sprite = $AnimatedSprite
onready var coin_pickup_player = $CoinPickupPlayer
onready var ui = get_node("/root/MainScene/CanvasLayer/UI")

func _ready():
	state_machine.push($StateMachine/Idle)

func _physics_process (delta):
	handle_landing()
	handle_falling()
	handle_movement(delta)
	flip_sprite()

func handle_movement(delta):
	var influence = 0
	var friction = speed	# Default to a high number in case the player dies
	var delta_x = 0
	
	if can_move():
		if Input.is_action_pressed("move_left"):
			delta_x -= 1
		if Input.is_action_pressed("move_right"):
			delta_x += 1

		handle_running(delta_x)

		if is_on_floor():
			if Input.is_action_pressed("jump"):
				state_machine.push($StateMachine/Jump)
				vel.y -= jump_impulse
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
	if is_on_floor() and not grounded:
		# Just landed
		state_machine.setup_stack([$StateMachine/Idle, $StateMachine/Land])
		grounded = true
		yield(get_tree().create_timer(0.1), "timeout")
		state_machine.pop()

func handle_falling():
	if not is_on_floor() and grounded:
		# Just left the ground
		grounded = false
		yield(get_tree().create_timer(0.1), "timeout")
		state_machine.push($StateMachine/Fall)

func handle_running(direction):
	if is_on_floor():
		if direction != 0 and state_machine.active_state() == $StateMachine/Idle:
			state_machine.push($StateMachine/Run)

		if direction == 0 and state_machine.active_state() == $StateMachine/Run:
			state_machine.pop()

func flip_sprite():
	if abs(vel.x) > 0:
		SpriteUtils.flip_sprite(sprite, vel.x < 0)


func can_move():
	var mid_landing = state_machine.active_state() == $StateMachine/Die
	return not (is_dead() or mid_landing)

func is_dead():
	return state_machine.active_state() == $StateMachine/Die

func die ():
	# Can't die twice
	if not is_dead():
		state_machine.push($StateMachine/Die)
		state_machine.locked = true
		# Wait some time so the animation plays out
		yield(get_tree().create_timer(4), "timeout")
		# There is a warning if the output is not collected to a variable
		var _reload_output = get_tree().reload_current_scene()


# called when we run into a coin
func collect_coin (value):
	score += value
	coin_pickup_player.play()
	ui.set_score_text(score)

