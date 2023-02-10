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
	health -= 1
	react_to_hit()
	if health:
		$OnHitSound.play_random()
	else:
		$OnDeathSound.play()

func react_to_hit():
	state_machine.set_state($StateMachine/Hit)
	apply_impulse(Vector2(0, 0), Vector2(0, -500))

func die():
	state_machine.set_state($StateMachine/Die)

func animation_done():
	if health:
		if state_machine.current != $StateMachine/Idle:
			state_machine.set_state($StateMachine/Idle)
	else:
		if state_machine.current == $StateMachine/Die:
			yield(get_tree().create_timer(2), "timeout")
			queue_free()
		else:
			die()
