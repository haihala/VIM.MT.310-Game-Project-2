extends Node

export (Array, AudioStream) var footsteps 
export (Array, AudioStream) var on_attack
export (Array, AudioStream) var on_hit
export (Array, AudioStream) var on_death
export var player_template : PackedScene

func footstep(volume=0):
	play_random_clip(footsteps, volume)

func attack(volume=0):
	play_random_clip(on_attack, volume)

func hit(volume=0):
	play_random_clip(on_hit, volume)

func death(volume=0):
	play_random_clip(on_death, volume)

func play_random_clip(candidates, volume):
	randomize()
	var player = get_player()
	player.stream = candidates[randi() % len(candidates)]
	player.volume_db = volume
	player.play()

func get_player():
	var instance = player_template.instance()
	add_child(instance)
	instance.connect("finished", instance, "queue_free")
	return instance
