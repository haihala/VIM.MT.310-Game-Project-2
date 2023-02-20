extends Node2D

export var speed = 150
var active = true

func _physics_process(delta):
	# Because of how the facings work, this has to be -
	position.x -= speed*delta

func _on_Collider_body_entered(body):
	if body.name == "Player":
		hit(body)

func _on_Collider_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.name == "TileMap":
		queue_free()
	else:
		hit(body)

func hit(body):
	if body.has_method("get_hit") and active:
		body.get_hit()
		active = false
