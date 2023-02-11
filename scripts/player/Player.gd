extends KinematicBody2D

var health : int = 3
var grounded : bool = false

# Movement
var vel : Vector2 = Vector2()
var speed : float = 200
var ground_speed_influence : float = 200
var ground_friction : float = 10
var air_speed_influence : float = 5
var air_friction : float = 1

onready var state_machine = $StateMachine
onready var sprite = $AnimatedSprite
onready var coin_pickup_player = $CoinPickupPlayer
onready var ui = get_node("../CanvasLayer/UI")
onready var health_bar = get_node("../CanvasLayer/UI/HealthBar")
onready var camera = get_node("../Camera")

var state_after_animation

func _ready():
	state_machine.set_state($StateMachine/Idle)
	sprite.connect("animation_finished", self, "animation_finished")

func _physics_process (delta):
	handle_landing()
	handle_falling()
	handle_movement(delta)
	handle_attacking()
	flip_character()

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
				state_machine.set_state($StateMachine/Jump)
				state_after_animation = $StateMachine/Fall
				grounded = false
				vel.y -= Constants.jump_impulse
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
	vel.y += Constants.gravity*delta
	vel = move_and_slide(vel, Vector2.UP)

func handle_landing():
	if is_on_floor() and not grounded:
		# Just landed
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

func handle_running(direction):
	if is_on_floor():
		if direction != 0 and state_machine.current == $StateMachine/Idle:
			state_machine.set_state($StateMachine/Run)

		if direction == 0 and state_machine.current == $StateMachine/Run:
			state_machine.set_state($StateMachine/Idle)

func handle_attacking():
	if Input.is_action_pressed("attack"):
		if state_machine.current != $StateMachine/Attack:
			if is_on_floor():
				# Only attacking on the floor for now
				state_machine.set_state($StateMachine/Attack)
				state_after_animation = $StateMachine/Idle

func flip_character():
	if abs(vel.x) > 0:
		SpriteUtils.flip_sprite(sprite, vel.x < 0)
		$Hitbox.scale.x = sign(vel.x)


func can_move():
	var mid_attack = state_machine.current == $StateMachine/Attack
	var mid_landing = state_machine.current == $StateMachine/Land
	return not (is_dead() or mid_landing or mid_attack)

func is_dead():
	return state_machine.current == $StateMachine/Die

func die ():
	# Can't die twice
	if not is_dead():
		state_machine.set_state($StateMachine/Die)
		$OnDeathSound.play()
		# Wait one extra second
		yield(get_tree().create_timer(4), "timeout")
		
		# There is a warning if the output is not collected to a variable
		var _reload_output = get_tree().reload_current_scene()

func take_damage():
	if health > 0:
		health -= 1
		health_bar.update_hearts(health)
		camera.shake()

	if health > 0:
		state_machine.set_state($StateMachine/Hit)
		state_after_animation = $StateMachine/Idle
		$OnHitSound.play_random()
	else:
		die()

func animation_finished():
	if state_after_animation:
		state_machine.set_state(state_after_animation)
		state_after_animation = null
		
