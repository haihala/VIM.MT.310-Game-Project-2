extends Camera2D

onready var player = get_node("/root/MainScene/Player")

var dampening = 0.9
var max_magnitude = 20
var magnitude = 0

# tracks the player along the X axis
func _process (_delta):
	position.x = player.position.x

	randomize()
	var angle = deg2rad(randi()%360)
	offset.x = cos(angle)*magnitude
	offset.y = sin(angle)*magnitude
	
	magnitude = magnitude*dampening
	if magnitude < 1:
		magnitude = 0


func shake(amount = max_magnitude):
	magnitude = amount
