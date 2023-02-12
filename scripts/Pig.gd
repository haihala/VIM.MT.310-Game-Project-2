extends KinematicBody2D

export var resurrect_after_death : bool

onready var player = get_node("/root/MainScene/Common/Player")
onready var sprite = $AnimatedSprite
onready var state_machine = $StateMachine
onready var speech_bubble = $SpeechBubble

var health = 3
var vel : Vector2 = Vector2()
var speed = 90
var facing = 1
var attack_range = 65

func _ready():
	state_machine.set_state($StateMachine/Idle)
	sprite.connect("animation_finished", self, "animation_done")

func _physics_process(delta):
	flip_character()
	
	if can_act():
		if abs(player.position.x-position.x) < attack_range:
			state_machine.set_state($StateMachine/Attack)
		elif state_machine.current != $StateMachine/Run:
			state_machine.set_state($StateMachine/Run)
	
	if state_machine.current == $StateMachine/Run:
		vel.x = speed * facing
	elif state_machine.current in [$StateMachine/Attack, $StateMachine/Die]:
		vel.x = 0

	vel.y += Constants.gravity * delta
	vel = move_and_slide(vel, Vector2.UP)

func can_act():
	return state_machine.current in [$StateMachine/Idle, $StateMachine/Run]

func flip_character():
	facing = sign(player.position.x- position.x)
	if can_act():
		$Hitbox.scale.x = -facing
		SpriteUtils.flip_sprite(sprite, facing > 0)

func take_damage():
	if state_machine.current == $StateMachine/Die:
		return

	state_machine.set_state($StateMachine/Hit, true)
	vel.y -= 500
	health -= 1

	if health > 0:
		$OnHitSound.play_random()
	else:
		$OnDeathSound.play()

func animation_done():
	if health > 0:
		if state_machine.current != $StateMachine/Idle:
			state_machine.set_state($StateMachine/Idle)
	else:
		# After getting hit animation is done, it gets here
		if state_machine.current != $StateMachine/Die:
			# Starts dying animation
			state_machine.set_state($StateMachine/Die)
			if resurrect_after_death:
				speech_bubble.say("wtf-fast")
		else:
			# After dying animation is done, it gets here
			yield(get_tree().create_timer(2), "timeout")
			if resurrect_after_death:
				health = 3
				speech_bubble.say("wtf-slow")
				state_machine.set_state($StateMachine/Resurrect)
			else:
				queue_free()
