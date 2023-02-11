extends Node2D

export(Array, PackedScene) var scenes
var active : PackedScene

func _ready():
	change_scene(scenes[0])

func change_scene(new_scene):
	var scene = new_scene.instance()
	active = new_scene
	for previous_scene in get_children():
		previous_scene.queue_free()
	add_child(scene)
