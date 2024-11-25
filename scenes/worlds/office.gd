extends Node3D

@onready var Camera = $PlayerCam as CustomCamera
@onready var Board = $Board
@onready var Terminal = $UglyComputer/Screen/Viewport/Terminal
@onready var Clock = $Clock


@export var day_start: int = 6*60
@export var day_end: int = 18*60

var last_pressed: int = -1000

## Note currently held by the player
var note_in_hand: Note = null
## Note currently on the side of the screen
var note_on_screen: Note = null

@onready var NoteScene = preload("res://scenes/objects/note.tscn")

func _ready() -> void:
	# Add today's tasks to the board
	for task in Game.day_tasks:
		var note : Note = NoteScene.instantiate()
		note.task = task
		Board.attach_note(note)
	Clock.time = day_start
	Clock.alarm_time = day_end
	start_day()

func _input(event):
	if event.is_action_pressed("debug_quit"):
		# Quickly exit the scene if stuck
		if Time.get_ticks_msec() < last_pressed + 500:
			get_tree().quit()
		elif Camera.state == Camera.State.LOCKED:
			Camera.zoom_out(0)
		last_pressed = Time.get_ticks_msec()


func _on_board_note_picked(note: Note) -> void:
	assert(note_on_screen == null)
	note_in_hand = note
	
	# Move note to player "hand"
	note.reparent($PlayerCam/PickedNotePlaceholder)
	var tween = get_tree().create_tween()
	tween.tween_property(note, "transform", Transform3D(), 1.0)

	# Prevent picking new tasks from now on
	Board.can_pick_tasks = false
	Camera.zoom_out()


func _on_player_cam_focusing(node: Node3D) -> void:
	if node == $UglyComputer/Screen:
		if note_in_hand != null and note_on_screen == null:
			# Move variables around
			note_on_screen = note_in_hand
			note_in_hand = null
			
			# Move note to computer
			note_on_screen.reparent($UglyComputer/NotePlaceholder)
			var tween = get_tree().create_tween()
			tween.tween_property(note_on_screen, "transform", Transform3D(), 1.0)
			# Load the task when animation is over
			tween.tween_callback(Terminal.load_task.bind(note_on_screen.task))
	
	# TODO: Do we allow putting it back if player clicks the board?
	# TODO: If player clicks the trash, bye bye note


func _on_clock_alarm_triggered(time: int) -> void:
	if time >= day_end:
		end_day()


func start_day() -> void:
	# Fade from black
	get_tree().create_tween().tween_property($Black, "self_modulate:a", 0, 1.0)


func end_day() -> void:
	var tween = get_tree().create_tween()
	# Wait a bit so the player can realize the day is ending
	tween.tween_interval(5)
	tween.tween_callback(Camera.zoom_out)
	tween.tween_property($Black, "self_modulate:a", 1, 1.0)
	tween.tween_callback(Game.end_day)
