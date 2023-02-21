extends Node2D

export var speed = 150
var active = true
var despawned = false

func _physics_process(delta):
	# Because of how the facings work, this has to be -
	if not despawned:
		position.x -= speed*delta

func _on_Collider_body_entered(body):
	if body.name == "Player" and not despawned:
		hit(body)

func _on_Collider_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if despawned:
		return

	if body.name == "TileMap":
		despawned = true
		$Sprite.hide()
		$DespawnSound.play()
		$DestructionParticles.restart()
		var _unused = $DespawnSound.connect("finished", self, "queue_free")
	else:
		hit(body)


func hit(body):
	if body.has_method("get_hit") and active:
		HitStop.hit_stop(get_tree(), 0.4)
		body.get_hit()
		active = false
