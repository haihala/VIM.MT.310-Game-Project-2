extends RigidBody2D

onready var player = get_node("/root/MainScene/Player")
onready var sprite = $AnimatedSprite

var health = 3
var dead = false

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
	sprite.play("hit")
	apply_impulse(Vector2(0, 0), Vector2(0, -500))

func die():
	sprite.play("die")
	dead = true

func animation_done():
	if health:
		sprite.play("idle")
	else:
		if dead:
			yield(get_tree().create_timer(2), "timeout")
			queue_free()
		else:
			die()
