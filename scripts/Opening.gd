extends Control

onready var bg_music = get_node("../../BackgroundMusic")

var messages = [
	"Oh?",
	"You're here",
	"Why?",
	"A game?",
	"Such a pointless endeavour",
	"I guess I could whip something up if you insist",
	"Why would you use your finite time on earth on this of all things is beyond me",
	"If you're still seriously considering this, press the left arrow to start",
]
var message_index = 0
var wait_per_message = 3
var last_message_change
var on_last_message = false

func _ready():
	set_text(0)

func _physics_process(_delta):
	var time_for_next = last_message_change + 1000*wait_per_message < OS.get_system_time_msecs()
	
	if on_last_message:
		if Input.is_action_just_pressed("move_left"):
			start_game()
	elif time_for_next or Input.is_action_just_pressed("ui_accept"):
		set_text(message_index + 1)

func set_text(index):
	message_index = index
	on_last_message = message_index == len(messages) - 1
	var text = messages[index]
	var processed = ""

	for chapter in text.split(";"):
		processed += "[center]"+chapter+"[/center]"
	$Text.bbcode_text = processed
	last_message_change = OS.get_system_time_msecs()

func start_game():
	bg_music.play()
	queue_free()
