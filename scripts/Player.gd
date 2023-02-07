extends KinematicBody2D

var score : int = 0
var dead : bool = false
var desired_animation : String = "idle"

# Movement
var vel : Vector2 = Vector2()
var speed : float = 200

# Jumping
# Calculate jump properties from easily reasonable concepts
# Tweak theses
export var jump_height : float = 3	# In tiles
export var jump_duration : float = 0.6	# In seconds

# Use these in code
var half_time = jump_duration/2	# Equations assume we'll only consider one-way travel
var jump_height_pixels = jump_height * 16;	# Tiles are 32 by 32, but for some reason this needs to be doubled
var gravity : float = 2*jump_height_pixels / pow(half_time, 2)
var jump_impulse : float = (gravity * half_time) + (jump_height_pixels / half_time)

onready var sprite = $AnimatedSprite
onready var ui = get_node("/root/MainScene/CanvasLayer/UI")

func _physics_process (delta):
	# reset horizontal velocity
	vel.x = 0
	if not dead:
		if Input.is_action_pressed("move_left"):
			vel.x -= speed
		if Input.is_action_pressed("move_right"):
			vel.x += speed
		if Input.is_action_pressed("jump") and is_on_floor():
			vel.y -= jump_impulse

	vel.y += gravity*delta
	vel = move_and_slide(vel, Vector2.UP)

func _process(delta):
	update_visual()

func update_visual():
	# sprite direction
	if vel.x < 0:
		sprite.flip_h = true
		sprite.offset.x = -abs(sprite.offset.x)
	elif vel.x > 0:
		sprite.flip_h = false
		sprite.offset.x = abs(sprite.offset.x)

	if dead:
		desired_animation = "die"
	elif not is_on_floor():
		desired_animation = "jump"
	elif abs(vel.x) > 0:
		desired_animation = "run"
	else:
		desired_animation = "idle"

	if sprite.animation != desired_animation:
		sprite.play(desired_animation)

func die ():
	# Can't die twice
	if not dead:
		dead = true
		# Wait some time so the animation plays out
		var tree = get_tree()
		yield(tree.create_timer(5), "timeout")
		tree.reload_current_scene()


# called when we run into a coin
func collect_coin (value):
	score += value
	ui.set_score_text(score)
