extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	hide()

func say(animation):
	show()
	play(animation)

func _on_SpeechBubble_animation_finished():
	hide()
