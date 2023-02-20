extends Area2D

export var new_y : float
export var boss : PackedScene
export var boss_spawn_point : Vector2

onready var camera = get_node("/root/MainScene/Common/Camera")

func _on_CamTeleportTrigger_body_entered(body):
	if body.name == "Player":
		camera.position.y = new_y
		camera.lock = true
		var node = boss.instance()
		node.position = boss_spawn_point
		get_parent().call_deferred("add_child", node)
