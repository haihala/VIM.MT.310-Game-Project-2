extends Area2D

export var new_y : float
export var boss : PackedScene
export (Array, Vector2) var boss_spawn_points

onready var camera = get_node("/root/MainScene/Common/Camera")

func _on_CamTeleportTrigger_body_entered(body):
	if body.name == "Player":
		for spawn_point in boss_spawn_points:
			camera.position.y = new_y
			camera.lock = true
			var node = boss.instance()
			node.position = spawn_point
			get_parent().call_deferred("add_child", node)
