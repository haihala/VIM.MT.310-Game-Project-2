extends Area2D

export var new_y : float
export var lock_after : bool

onready var camera = get_node("/root/MainScene/Common/Camera")

func _on_CamTeleportTrigger_body_entered(body):
	if body.name == "Player":
		camera.position.y = new_y
		if lock_after:
			camera.lock = true
