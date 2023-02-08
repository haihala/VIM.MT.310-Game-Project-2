class_name SpriteUtils

static func flip_sprite(sprite, flipped):
	if sprite.flip_h != flipped:
		sprite.offset.x = -sprite.offset.x
	
	sprite.flip_h = flipped
