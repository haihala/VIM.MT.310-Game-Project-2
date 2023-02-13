extends AudioStreamPlayer2D

export var path_template: String
export var low_index: int
export var high_index: int

var clips = []
var last_index

func _ready():
	for i in range(low_index, high_index+1):
		clips.append(load(path_template % i))

func play_random():
	randomize()
	# This ensures you get a different clip on each swing
	var new_index = randi() % len(clips)
	while new_index == last_index:
		new_index = randi() % len(clips)
	
	stream = clips[new_index]
	last_index = new_index
	
	play()
