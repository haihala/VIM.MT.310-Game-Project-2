extends KinematicBody2D

var vel : Vector2

func _physics_process(delta):
	vel.y += Constants.gravity * delta
	vel = move_and_slide(vel, Vector2.UP)

func get_hit():
	$DestructionParticles.emit()
	$Sprite.hide()
	$DestructionSoundPlayer.play_random()
	$CollisionShape2D.set_deferred("disabled", true)
	var _unused = $DespawnTimer.connect("timeout", self, "queue_free")
	$DespawnTimer.start()
