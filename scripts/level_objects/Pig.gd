extends KinematicBody2D

export var resurrect_after_death : bool
export var drop : PackedScene
export var king_level = 0

onready var player = get_node("/root/MainScene/Common/Player")
onready var sprite = $AnimatedSprite
onready var state_machine = $StateMachine
onready var speech_bubble = $SpeechBubble

export var health = 3
export var speed = 90
export var attack_range = 50
export var knockback_multiplier = 1.0

var wait_before_acting = 0
var vel : Vector2 = Vector2()
var facing = 1
var start_time
var distance

func _ready():
	state_machine.set_state($StateMachine/Idle)
	sprite.connect("animation_finished", self, "animation_done")
	start_time = OS.get_system_time_msecs()
	if king_level == 1:
		wait_before_acting = 3

func _physics_process(delta):
	distance = abs(player.global_position.x-global_position.x)
	
	var can_flip = true
	# Done this way as regular pigs use the same script and don't have the charge states
	var charge_attack = get_node_or_null("StateMachine/ChargeAttack")
	if charge_attack:
		if state_machine.current == $StateMachine/ChargeAttack:
			can_flip = false

	if can_flip:
		flip_character()

	if is_on_floor() and state_machine.current in [
		$StateMachine/Jump,
		$StateMachine/Fall,
	]:
		state_machine.set_state($StateMachine/Land)
	elif can_act():
		if distance < attack_range:
			state_machine.set_state($StateMachine/Attack)
		elif should_jump():
			state_machine.set_state($StateMachine/Jump)
			vel.y -= Constants.jump_impulse
		elif king_level >= 3 and distance > 2*attack_range:
			if state_machine.current != $StateMachine/Charge:
				state_machine.set_state($StateMachine/Charge)
		elif state_machine.current == $StateMachine/Idle:
			state_machine.set_state($StateMachine/Run)

	if state_machine.current == $StateMachine/Run:
		vel.x = speed * facing
	elif should_stop_momentum():
		vel.x = 0
	elif state_machine.current == charge_attack:
		vel.x *= 0.97

	vel.y += Constants.gravity * delta
	vel = move_and_slide(vel, Vector2.UP)

	# Disable collision with other enemies when in the air
	# This is mostly for letting the bosses pass each other while charging
	set_collision_mask_bit(3, is_on_floor())
	set_collision_layer_bit(3, not is_dead())

func can_act():
	var in_legal_state = state_machine.current in [$StateMachine/Idle, $StateMachine/Run]
	var waiting = OS.get_system_time_msecs() < start_time + 1000*wait_before_acting
	return is_on_floor() and in_legal_state and not waiting

func flip_character():
	facing = sign(player.global_position.x- global_position.x)
	if can_act():
		$Hitbox.scale.x = -facing
		SpriteUtils.flip_sprite(sprite, facing > 0)

		for optional in ["ParryParticle", "ParrySound"]:
			var node = get_node_or_null(optional)
			if node:
				node.position.x = abs(node.position.x)*facing

func should_stop_momentum():
	var states = [$StateMachine/Attack, $StateMachine/Die, $StateMachine/Land]
	var charge_state = get_node_or_null("StateMachine/Charge")
	if charge_state:
		states.append(charge_state)
	return state_machine.current in states

func get_hit():
	if state_machine.current == $StateMachine/Die:
		return

	if king_level >= 2:
		# Prevent hitting kings out of attack startup or hitstun
		var invincible_states = [
			$StateMachine/Hit,
			$StateMachine/Attack, 
		]
		if king_level >= 4:
			invincible_states.append($StateMachine/ChargeAttack)

		# Can't get hit out of attack startup or when already being hit
		if state_machine.current in invincible_states and sprite.frame <= 1:
			return

		# Parry if both hitboxes are active
		if $Hitbox.active:
			vel.x = 0
			$ParrySound.play()
			$ParryParticle.restart()
			$Hitbox.active = false
			HitStop.hit_stop(get_tree(), 0.4)
			return
			
	state_machine.set_state($StateMachine/Hit, true)
	health -= 1

	if health > 0:
		$CharacterAudio.hit()
	else:
		$CharacterAudio.death()


func animation_done():
	if health > 0:
		if is_on_floor():
			if state_machine.current == get_node_or_null("StateMachine/Charge"):
				if $StateMachine/Charge.done_charging():
					state_machine.set_state($StateMachine/ChargeAttack)
					vel.x = 6*speed*facing
			elif state_machine.current != $StateMachine/Idle:
				state_machine.set_state($StateMachine/Idle)
		else:
			if state_machine.current != $StateMachine/Fall:
				state_machine.set_state($StateMachine/Fall)
	else:
		# After getting hit animation is done, it gets here
		if state_machine.current != $StateMachine/Die:
			# Starts dying animation
			state_machine.set_state($StateMachine/Die)

			if resurrect_after_death:
				speech_bubble.say("exclaim")
		else:
			# After dying animation is done, it gets here
			yield(get_tree().create_timer(2), "timeout")
			if resurrect_after_death:
				health = 3
				speech_bubble.say("grumble")
				state_machine.set_state($StateMachine/Resurrect)
			else:
				if drop and last_enemy_alive():
					var instance = drop.instance()
					instance.position = position
					get_parent().add_child(instance)
				queue_free()

func is_dead():
	return health <= 0

func should_jump():
	if is_on_wall():
		return true

	for enemy in get_tree().get_nodes_in_group("King"):
		if enemy == self:
			continue

		var enemy_charge_state = enemy.get_node("StateMachine/ChargeAttack")
		var other_king_charging = enemy.state_machine.current == enemy_charge_state
		var blocking_other_king = distance < enemy.distance
		var other_king_moving = abs(enemy.vel.x) > 10
		if other_king_charging and blocking_other_king and other_king_moving:
			return true
	return false


func last_enemy_alive():
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy == self:
			continue
		if not enemy.is_dead():
			return false
	return true
