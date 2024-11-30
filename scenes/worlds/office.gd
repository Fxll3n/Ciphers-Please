extends Node3D

@onready var Camera = $PlayerCam as CustomCamera
@onready var Board = $Board
@onready var Terminal = $Screen/Viewport/Terminal
@onready var Clock = $Clock
@onready var gui = $GUI


@export var day_start: int = 6*60
@export var day_end: int = 18*60

var last_pressed: int = -1000
var last_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE

## Note currently held by the player
var note_in_hand: Note = null
## Note currently on the side of the screen
var note_on_screen: Note = null
@onready var NoteScene = preload("res://scenes/objects/note.tscn")

func _ready() -> void:
	Game.connect("new_task", _on_new_task)
	
	# Required so that PickedNotePlaceholder is visible
	Camera.visible = true
	
	Clock.time = day_start
	Clock.alarm_time = day_end
	Board.can_pick_tasks = false # Disable sound upon adding new notes
	start_day()
	Board.can_pick_tasks = true
	General.scene_before = "Main"
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	# this is for the pause menu
	if event.is_action_pressed("Esc"):
		gui.show()
		get_tree().paused = true
		last_mouse_mode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

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


func _on_player_cam_node_clicked(node: Node3D) -> void:
	if node == $Screen:
		if note_in_hand != null and note_on_screen == null:
			# Move variables around
			note_on_screen = note_in_hand
			note_in_hand = null
			
			# Move note to computer
			note_on_screen.reparent($Screen/NotePlaceholder)
			var tween = get_tree().create_tween()
			tween.tween_property(note_on_screen, "transform", Transform3D(), 1.0)
			# Load the task when animation is over
			tween.tween_callback(Terminal.load_task.bind(note_on_screen.task))
	
	# TODO: Do we allow putting it back if player clicks the board?

	# If player clicks the trash, bye bye note
	if node == $Trashcan:
		if note_in_hand != null:
			note_in_hand.task.trashed = true
			
			# Move variables around
			var note : Node3D = note_in_hand
			note_in_hand = null

			# Drop animation for note along with trash SFX
			var tween = get_tree().create_tween()
			tween.tween_property(note, "position:y", -1, 1.0)
			tween.tween_callback(note.queue_free)
			$Trashcan/TrashcanStreamPlayer.play()
			
			if note_on_screen == null:
				Board.can_pick_tasks = true

func _on_new_task(task: Task):
	task.available = true
	# Add task to the board
	var note : Note = NoteScene.instantiate()
	note.task = task
	Board.attach_note(note)

func _on_terminal_task_complete() -> void:
	Terminal.unload_task()
	assert(note_on_screen != null)
	note_on_screen.task.completed = true
	
	$Screen/Viewport/Terminal/SubmitSound.play()
	Camera.zoom_out()
	note_on_screen.queue_free()
	note_on_screen = null
	Board.can_pick_tasks = true
	get_tree().create_timer(1).timeout.connect(Game.on_task_completed)

func _on_terminal_task_deleted() -> void:
	Terminal.unload_task()
	assert(note_on_screen != null)
	note_on_screen.task.trashed = true
	
	$Trashcan/TrashcanStreamPlayer.play()
	Camera.zoom_out()
	note_on_screen.queue_free()
	note_on_screen = null
	Board.can_pick_tasks = true

func _on_clock_alarm_triggered(time: int) -> void:
	if time >= day_end:
		end_day()


func start_day() -> void:
	# Fade from black
	$Black.modulate.a = 1
	get_tree().create_tween().tween_property($Black, "self_modulate:a", 0, 1.0)
	Game.start_day()


func end_day() -> void:
	var tween = get_tree().create_tween()
	# Wait a bit so the player can realize the day is ending
	tween.tween_interval(5)
	tween.tween_callback(Camera.zoom_out)
	tween.tween_property($Black, "self_modulate:a", 1, 1.0)
	tween.tween_callback(Game.end_day)

func _on_resume_pressed():
	get_tree().paused = false
	gui.hide()
	Input.mouse_mode = last_mouse_mode
func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/Scenes/main_menu.tscn")
func _on_settings_pressed():
	$GUI/Settings.show()
