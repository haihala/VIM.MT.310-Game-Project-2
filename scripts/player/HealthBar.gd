extends Sprite

func _ready():
	for index in get_children().size():
		var heart = get_child(index)
		heart.frame = 3-index

func update_hearts(hearts):
	for index in get_children().size():
		var heart = get_child(index)
		
		if index < hearts:
			heart.visible = true
			heart.speed_scale = 3/hearts
		else:
			heart.visible = false
