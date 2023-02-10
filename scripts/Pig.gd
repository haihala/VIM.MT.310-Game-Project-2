extends RigidBody2D

onready var player = get_node("/root/MainScene/Player")
onready var sprite = $AnimatedSprite
onready var state_machine = $StateMachine

var health = 3

func _ready():
	state_machine.set_state($StateMachine/Idle)
	sprite.connect("animation_finished", self, "animation_done")

func _physics_process(_delta):
	flip_character()
	if state_machine.current == $StateMachine/Idle and abs(player.position.x-position.x) < 100:
		state_machine.set_state($StateMachine/Attack)

func flip_character():
	var facing = sign(position.x - player.position.x)
	$Hitbox.scale.x = facing
	SpriteUtils.flip_sprite(sprite, facing < 0)

func take_damage():
	if state_machine.current == $StateMachine/Die:
		return

	state_machine.set_state($StateMachine/Hit, true)
	apply_impulse(Vector2(0, 0), Vector2(0, -500))
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
		else:
			# After dying animation is done, it gets here
			yield(get_tree().create_timer(2), "timeout")
			queue_free()
