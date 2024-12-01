extends Node3D

@onready var Camera = $PlayerCam as CustomCamera
@onready var Board = $Board
@onready var Terminal = $Screen/Viewport/Terminal
@onready var Clock = $Clock
@onready var gui = $GUI
@onready var end_day_screen: Control = $Clock/EndDayScreen


@export var day_start: int = 6*60
@export var day_end: int = 18*60

var last_pressed: int = -1000
var last_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE

var stats_tasks_completed: int = 0
var stats_tasks_trashed: int = 0
var stats_money_gained: int = 0
var trashed_final_note: bool = false

## Note currently held by the player
var note_in_hand: Note = null
## Note currently on the side of the screen
var note_on_screen: Note = null
@onready var NoteScene = preload("res://scenes/objects/note.tscn")

func _ready() -> void:
	Game.connect("new_task", _on_new_task)
	Game.connect("day_tasks_finished", end_day_screen.show)
	
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
			stats_tasks_trashed += 1
			
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
			if note.task.day == Game.final_day:
				trashed_final_note = true
			Game.on_task_trashed()

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
	stats_tasks_completed += 1
	stats_money_gained += note_on_screen.task.pay
	if note_on_screen.task.day == Game.final_day:
		trashed_final_note = false
	
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
	stats_tasks_trashed += 1	
	if note_on_screen.task.day == Game.final_day:
		trashed_final_note = true
	
	$Trashcan/TrashcanStreamPlayer.play()
	Camera.zoom_out()
	note_on_screen.queue_free()
	note_on_screen = null
	Board.can_pick_tasks = true
	get_tree().create_timer(1).timeout.connect(Game.on_task_trashed)

func _on_clock_alarm_triggered(time: int) -> void:
	if time >= day_end:
		# Wait a bit so the player can realize the day is ending
		get_tree().create_timer(5).timeout.connect(end_day)


func start_day() -> void:
	end_day_screen.hide()
	stats_tasks_completed = 0
	stats_tasks_trashed = 0
	stats_money_gained = 0
	Clock.time = day_start
	Clock.alarm_time = day_end
	# No trashcan on final day
	$Trashcan.visible = Game.day != Game.final_day
	$Trashcan/CollisionShape3D.disabled = Game.day == Game.final_day
	# Fade from black
	$Black.modulate.a = 1
	get_tree().create_tween().tween_property($Black, "self_modulate:a", 0, 1.0)
	Game.start_day()


func end_day() -> void:
	end_day_screen.hide()
	var tween = get_tree().create_tween()
	tween.tween_callback(Camera.zoom_out)
	tween.tween_property($Black, "self_modulate:a", 1, 1.0)
	tween.tween_callback(_show_end_day_screen)

@onready var new_day_screen: VBoxContainer = $Black/NewDayScreen
@onready var day_over: Label = $Black/NewDayScreen/DayOver
@onready var stats_label: Label = $Black/NewDayScreen/StatsLabel
@onready var start_day_button: Button = $Black/NewDayScreen/StartDay

func _show_end_day_screen():
	get_tree().paused = true
	last_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Game.day == Game.final_day:
		_show_end_game_screen(trashed_final_note)
		return
	day_over.text = "DAY %d OVER" % Game.day
	stats_label.text = "Tasks completed: %d\nTasks trashed: %d\nMoney gained: %d" % [stats_tasks_completed, stats_tasks_trashed, stats_money_gained]
	Game.day += 1
	start_day_button.text = "START DAY %d" % Game.day
	new_day_screen.show()

@onready var final_day_screen: Control = $Black/FinalDayScreen
@onready var big_red_gradient: Sprite2D = $Black/FinalDayScreen/BigRedGradient
@onready var final_text: Label = $Black/FinalDayScreen/FinalText
@onready var thanks: Label = $Black/FinalDayScreen/Thanks
@onready var title_screen: Button = $Black/FinalDayScreen/TitleScreen

func _show_end_game_screen(saved_the_day: bool = false):
	final_day_screen.show()
	final_text.visible_ratio = 0
	thanks.visible_ratio = 0
	title_screen.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if saved_the_day:
		big_red_gradient.hide()
		final_text.add_theme_color_override("font_color", Color.WHITE)
		final_text.text = "The nuclear threat was a false alarm. Your decision saved the day, and prevented massive casualties."
	else:
		big_red_gradient.show()
		tween.parallel().tween_property(big_red_gradient, "modulate:a", 1, 5)
		tween.parallel().tween_property($MainMusic, "pitch_scale", 0.67, 5)
		tween.parallel().tween_property($MainMusic, "volume_db", -15, 8)
		final_text.add_theme_color_override("font_color", Color.DARK_RED)
		final_text.text = "Your actions caused nuclear retaliation across the globe, plunging humanity into a new era of darkness."
		thanks.text = "Nonetheless, thank you for playing!"
	tween.parallel().tween_property(final_text, "visible_ratio", 1, 8)
	tween.tween_interval(4)
	tween.tween_property(thanks, "visible_ratio", 1, 2)
	tween.tween_property(title_screen, "modulate:a", 1, 2)

func _on_start_day_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = last_mouse_mode
	new_day_screen.hide()
	# Hack to avoid note sound while still not breaking in case day ends while working
	var old_value = Board.can_pick_tasks
	Board.can_pick_tasks = false
	start_day()
	Board.can_pick_tasks = old_value

func _on_resume_pressed():
	get_tree().paused = false
	gui.hide()
	Input.mouse_mode = last_mouse_mode
func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/Scenes/main_menu.tscn")
func _on_settings_pressed():
	$GUI/Settings.show()
