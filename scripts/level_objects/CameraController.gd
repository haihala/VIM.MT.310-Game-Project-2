extends Camera2D

onready var player = get_node("../Player")

var magnitude = 0
var dampening = 0
var lock = false

# tracks the player along the X axis
func _process (_delta):
	if not lock:
		position.x = player.position.x

	randomize()
	var angle = deg2rad(randi()%360)
	offset.x = cos(angle)*magnitude
	offset.y = sin(angle)*magnitude
	
	magnitude = magnitude*dampening
	if magnitude < 1:
		magnitude = 0


func shake(amount = 20, damp = 0.9):
	magnitude = amount
	dampening = damp
