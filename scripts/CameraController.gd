extends Camera2D

onready var player = get_node("/root/MainScene/Player")

# tracks the player along the X axis
func _process (delta):
	position.x = player.position.x
