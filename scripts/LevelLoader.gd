extends Node2D

export var initial : PackedScene
var active : PackedScene

func _ready():
	load_level(initial)

func load_level(new_scene, player_position = Vector2(0, 0)):
	active = new_scene
	var scene = new_scene.instance()
	for previous_scene in get_children():
		previous_scene.queue_free()

	call_deferred("add_child", scene)

	# Teleport players back to origin as levels expect you to start there
	for player in get_tree().get_nodes_in_group("player"):
		player.reset(player_position)

func reload():
	load_level(active)
