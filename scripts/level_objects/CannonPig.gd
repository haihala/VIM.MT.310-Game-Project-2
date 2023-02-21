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
	if not is_dead():
		$Timer.disconnect("timeout", self, "shoot")
		$Pig.disconnect("animation_finished", self, "activate_cannon")
		$Cannon.disconnect("animation_finished", self, "fire_ball")
		if $Pig.animation == "match":
			$Pig.position.y -= pig_offset
		$Pig.play("die")
		$Cannon.play("idle")
		$CharacterAudio.death()
		var _unused = $Pig.connect("animation_finished", self, "die")

func die():
	if drop and last_enemy_alive():
		var instance = drop.instance()
		instance.position = $Pig.position
		add_child(instance)
	$Pig.queue_free()
	$CollisionShape2D.disabled = true


func is_dead():
	var pig = get_node_or_null("Pig")
	return pig == null or not pig.animation in ["match", "idle"]

func last_enemy_alive():
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy == self:
			continue
		if not enemy.is_dead():
			return false
	return true
