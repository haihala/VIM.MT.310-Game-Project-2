extends AudioStreamPlayer2D

var clips = []
var index

func _ready():
	for i in range(1, 4):
		clips.append(load("res://assets/Minifantasy_Dungeon_SFX/07_human_atk_sword_%s.wav" % i))
	

func play_random():
	randomize()
	# This ensures you get a different clip on each swing
	var new_index = randi() % len(clips)
	while new_index == index:
		new_index = randi() % len(clips)
	index = new_index
	
	self.stream = clips[index]
	play()
