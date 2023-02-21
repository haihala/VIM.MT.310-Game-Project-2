extends Area2D

export var knockback = Vector2(0,-200)
var enemies_in_range = []
var enemies_hit_this_swing = []
var active = false

func start_attack():
	active = true
	for enemy in enemies_in_range:
		hit(enemy)

func end_attack():
	active = false
	enemies_hit_this_swing = []

# Only enemies are on the layer this can hit
func _on_Hitbox_body_entered(body):
	if active and not body in enemies_hit_this_swing:
		hit(body)
	enemies_in_range.append(body)

func _on_Hitbox_body_exited(body):
	var index = enemies_in_range.find(body)
	if index != -1:
		enemies_in_range.remove(index)

func hit(body):
	if body.get("vel") != null:
		var kb_mul = 1
		var maybe_kb_mul = body.get("knockback_multiplier")
		if maybe_kb_mul != null:
			kb_mul = maybe_kb_mul
		body.vel += kb_mul * knockback
	body.get_hit()
	enemies_hit_this_swing.append(body)
	
