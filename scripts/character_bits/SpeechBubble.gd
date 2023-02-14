extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	hide()

func say(line):
	show()
	play(line)
	frame = 0

func _on_SpeechBubble_animation_finished():
	hide()
