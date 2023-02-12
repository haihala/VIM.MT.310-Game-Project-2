extends KinematicBody2D


func get_hit():
	$DestructionParticles.emit()
	$Sprite.hide()
	$DestructionSoundPlayer.play_random()
	yield(get_tree().create_timer(2), "timeout")
	queue_free() 
