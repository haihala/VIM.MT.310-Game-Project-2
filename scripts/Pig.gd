extends RigidBody2D

onready var player = get_node("/root/MainScene/Player")
onready var sprite = $AnimatedSprite

func _physics_process(_delta):
	Utils.flip_sprite(sprite, position.x < player.position.x)
