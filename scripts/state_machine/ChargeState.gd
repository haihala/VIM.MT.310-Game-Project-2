extends AnimatedState

var loops_until_takeoff = 3
var loops = 0

func done_charging():
	return loops == loops_until_takeoff

func enter():
	.enter()
	sprite.connect("animation_finished", self, "add_loop")
	loops = 0

func add_loop():
	loops += 1
	if done_charging():
		sprite.disconnect("animation_finished", self, "add_loop")

func exit():
	.exit()

	if sprite.is_connected("animation_finished", self, "add_loop"):
		sprite.disconnect("animation_finished", self, "add_loop")
