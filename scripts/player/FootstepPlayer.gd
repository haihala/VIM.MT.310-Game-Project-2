extends AudioStreamPlayer2D

var play_footsteps : bool = false

var footsteps = []
func _ready():
	for i in range(10):
		footsteps.append(load("res://assets/kenney_rgpaudio/footstep0%s.ogg" % i))
	
func _process(_delta):
	if play_footsteps and not self.playing:
		randomize()
		self.stream = footsteps[randi() % len(footsteps)]
		self.play()
