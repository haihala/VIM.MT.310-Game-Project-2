extends Area2D

var enemies_in_range = []



func hit():
	for enemy in enemies_in_range:
		enemy.take_damage()

# Only enemies are on the layer this can hit
func _on_Hitbox_body_entered(body):
	enemies_in_range.append(body)


func _on_Hitbox_body_exited(body):
	var index = enemies_in_range.find(body)
	enemies_in_range.remove(index)
