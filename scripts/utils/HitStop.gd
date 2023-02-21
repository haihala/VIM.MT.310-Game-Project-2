class_name HitStop

static func hit_stop(tree, duration):
	Engine.time_scale = 0.1
	yield(tree.create_timer(duration*0.1), "timeout")
	Engine.time_scale = 1
