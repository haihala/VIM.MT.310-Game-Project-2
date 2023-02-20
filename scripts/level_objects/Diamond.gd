extends Area2D

onready var level_loader = get_node("/root/MainScene/LevelLoader")
onready var camera = get_node("/root/MainScene/Common/Camera")
export var new_scene : PackedScene = null

func _on_Diamond_body_entered(body):
	if body.name == "Player":
		if new_scene:
			level_loader.load_level(new_scene)
		else:
			get_tree().reload_current_scene()
		camera.position.y = 0
		camera.lock = false
