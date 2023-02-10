extends Area2D

var enemies_in_range = []
var enemies_hit_this_swing = []
var active = false

func hit():
	active = true
	for enemy in enemies_in_range:
		enemy.take_damage()
		enemies_hit_this_swing.append(enemy)

func end_attack():
	active = false
	enemies_hit_this_swing = []

# Only enemies are on the layer this can hit
func _on_Hitbox_body_entered(body):
	if active and not body in enemies_hit_this_swing:
		body.take_damage()
		enemies_hit_this_swing.append(body)
	enemies_in_range.append(body)



func _on_Hitbox_body_exited(body):
	var index = enemies_in_range.find(body)
	if index != -1:
		enemies_in_range.remove(index)
