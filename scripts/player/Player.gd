extends KinematicBody2D

var health : int = 3
var grounded : bool = false

# Movement
var vel : Vector2 = Vector2()
var speed : float = 200
var ground_speed_influence : float = 200
var ground_friction : float = 10
var air_speed_influence : float = 20
var air_friction : float = 1
var knockback_multiplier = 1

onready var state_machine = $StateMachine
onready var sprite = $AnimatedSprite
onready var ui = get_node("../CanvasLayer/UI")
onready var health_bar = get_node("../CanvasLayer/UI/HealthBar")
onready var camera = get_node("../Camera")

var state_after_animation
var delta_x = 0
var jumping = false

func _ready():
	state_machine.set_state($StateMachine/Idle)

func _physics_process (delta):
	if not is_dead():
		handle_landing()
		handle_falling()
		movement_input()
		handle_attacking()
	handle_movement(delta)
	flip_character()

func movement_input():
	if Input.is_action_pressed("move_left"):
		delta_x -= 1
	if Input.is_action_pressed("move_right"):
		delta_x += 1
	handle_running_state_transitions(delta_x)

	jumping = is_on_floor() and Input.is_action_pressed("jump")


func handle_movement(delta):
	if jumping:
		state_machine.set_state($StateMachine/Jump)
		state_after_animation = $StateMachine/Fall
		grounded = false
		vel.y -= Constants.jump_impulse
		jumping = false

	var influence = air_speed_influence
	var friction = air_friction

	if is_on_floor() or is_dead():	# Also use higher friction if dead
		influence = ground_speed_influence
		friction = ground_friction

	vel.x += (delta_x * influence)
	
	# Friction
	if abs(vel.x) < friction:
		vel.x = 0
	else:
		vel.x = sign(vel.x)*(abs(vel.x)-friction)
	
	# Enforce top speed
	vel.x = clamp(vel.x, -speed, speed)
	vel.y += Constants.gravity*delta
	vel = move_and_slide(vel, Vector2.UP)
	delta_x = 0	# Set this here, as that means when the player dies they don't slide

func handle_landing():
	if is_on_floor() and not grounded:
		# Just landed and didn't die mid-air
		state_machine.set_state($StateMachine/Land)
		camera.shake(2)
		grounded = true
		state_after_animation = $StateMachine/Idle

func handle_falling():
	if not is_on_floor() and grounded:
		# Just left the ground
		grounded = false
		if state_machine.current != $StateMachine/Jump:
			state_machine.set_state($StateMachine/Fall)

func handle_running_state_transitions(direction):
	if is_on_floor():
		if direction != 0 and state_machine.current == $StateMachine/Idle:
			state_machine.set_state($StateMachine/Run)

		if direction == 0 and state_machine.current == $StateMachine/Run:
			state_machine.set_state($StateMachine/Idle)

func handle_attacking():
	if Input.is_action_pressed("attack"):
		if state_machine.current != $StateMachine/Attack and grounded:
			# Only attacking on the floor for now
			state_machine.set_state($StateMachine/Attack)
			state_after_animation = $StateMachine/Idle

func flip_character():
	if abs(vel.x) > 0:
		SpriteUtils.flip_sprite(sprite, vel.x < 0)
		$Hitbox.scale.x = sign(vel.x)

func can_move():
	return (not is_dead()) and (not state_machine.current in [$StateMachine/Attack, $StateMachine/Land])

func is_dead():
	return health <= 0


func get_hit():
	if is_dead():
		return
	
	if health > 1:
		take_damage()
	else:
		die()

	health_bar.update_hearts(health)

func take_damage():
	health -= 1
	
	state_machine.set_state($StateMachine/Hit)
	state_after_animation = $StateMachine/Idle
	camera.shake()
	$CharacterAudio.hit()
	$SpeechBubble.say("grumble")

func die ():
	health = 0
	
	state_machine.set_state($StateMachine/Hit)
	state_after_animation = $StateMachine/Die
	camera.shake(20, 0.97)
	$CharacterAudio.death()
	$SpeechBubble.say("no")
	
	var _unused = get_tree().create_timer(4).connect("timeout", self, "respawn")

func respawn():
	# There is a warning if the output is not collected to a variable
	var _unused = get_tree().reload_current_scene()
	

func animation_finished():
	if state_after_animation:
		state_machine.set_state(state_after_animation)
		state_after_animation = null
		
