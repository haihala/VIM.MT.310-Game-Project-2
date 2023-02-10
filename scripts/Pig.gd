extends RigidBody2D

onready var player = get_node("/root/MainScene/Player")
onready var sprite = $AnimatedSprite
onready var state_machine = $StateMachine

var health = 3

func _ready():
	sprite.connect("animation_finished", self, "animation_done")

func _physics_process(_delta):
	SpriteUtils.flip_sprite(sprite, position.x < player.position.x)

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
