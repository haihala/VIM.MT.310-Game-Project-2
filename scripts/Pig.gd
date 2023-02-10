extends RigidBody2D

onready var player = get_node("/root/MainScene/Player")
onready var sprite = $AnimatedSprite

func _physics_process(_delta):
	SpriteUtils.flip_sprite(sprite, position.x < player.position.x)
	
	

func take_damage():
	print("Hit")
	apply_impulse(Vector2(0, 0), Vector2(0, -500))
