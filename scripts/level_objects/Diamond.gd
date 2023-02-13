extends Area2D

onready var level_loader = get_node("/root/MainScene/LevelLoader")
export var new_scene : PackedScene

func _on_Diamond_body_entered(body):
	if body.name == "Player":
		level_loader.load_level(new_scene)
