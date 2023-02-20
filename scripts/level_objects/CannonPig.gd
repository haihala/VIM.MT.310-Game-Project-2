extends Node2D

export var cannon_ball : PackedScene

# Idle animation is from a different sized tile sheet
# This causes the pig to move when it changes animations
var pig_offset = 15
export var drop : PackedScene

func _ready():
	var _unused = $Timer.connect("timeout", self, "shoot")
	_unused = $Pig.connect("animation_finished", self, "activate_cannon")
	_unused = $Cannon.connect("animation_finished", self, "fire_ball")

func shoot():
	if $Pig.animation != "match":
		$Pig.position.y += pig_offset
	$Pig.play("match")

func activate_cannon():
	if $Pig.animation == "match":
		$Cannon.play("shoot")
		$Pig.play("idle")
		$Pig.position.y -= pig_offset
		spawn_projectile()

func fire_ball():
	if $Cannon.animation == "shoot":
		$Cannon.play("idle")

func spawn_projectile():
	var instance = cannon_ball.instance()
	add_child(instance)

func get_hit():
	$Timer.disconnect("timeout", self, "shoot")
	$Pig.disconnect("animation_finished", self, "activate_cannon")
	$Cannon.disconnect("animation_finished", self, "fire_ball")
	if $Pig.animation == "match":
		$Pig.position.y -= pig_offset
	$Pig.play("die")
	var _unused = $Pig.connect("animation_finished", self, "die")

func die():
	if drop:
		var instance = drop.instance()
		instance.position = $Pig.position
		add_child(instance)
	$Pig.queue_free()
	$CollisionShape2D.disabled = true
