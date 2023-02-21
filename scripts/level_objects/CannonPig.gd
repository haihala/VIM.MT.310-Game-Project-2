extends Node2D

export var cannon_ball : PackedScene

# Idle animation is from a different sized tile sheet
# This causes the pig to move when it changes animations
var pig_offset = 13
export var drop : PackedScene
var health = 1

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
		$GunshotSound.play()
		$Pig.position.y -= pig_offset
		spawn_projectile()

func fire_ball():
	if $Cannon.animation == "shoot":
		$Cannon.play("idle")

func spawn_projectile():
	var instance = cannon_ball.instance()
	add_child(instance)

func get_hit():
	if health:
		health = 0

		$Timer.disconnect("timeout", self, "shoot")
		$Pig.disconnect("animation_finished", self, "activate_cannon")
		$Cannon.disconnect("animation_finished", self, "fire_ball")
		
		$Cannon.play("idle")

		if $Pig.animation == "match":
			$Pig.position.y -= pig_offset
		$Pig.play("hit")
		$CharacterAudio.death()

		var _unused = $Pig.connect("animation_finished", self, "death_animation")

func death_animation():
	$Pig.play("die")
	$Pig.disconnect("animation_finished", self, "death_animation")
	var _unused = $Pig.connect("animation_finished", self, "finish_dying")

func finish_dying():
	if drop and last_enemy_alive():
		var instance = drop.instance()
		instance.position = $Pig.position
		add_child(instance)
	$Pig.queue_free()
	$CollisionShape2D.disabled = true

func is_dead():
	return health > 0

func last_enemy_alive():
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy == self:
			continue
		if not enemy.is_dead():
			return false
	return true
