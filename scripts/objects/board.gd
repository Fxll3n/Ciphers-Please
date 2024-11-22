extends ZoomTarget3D

## The note currently focused, may be null
var focused_note: Note = null

## The origin position of the focused note, used to tween back
var note_origin_position: Transform3D

## Whether or not picking tasks from the board is currently allowed
@export var can_pick_tasks: bool = true:
	set(value):
		if value:
			$UI/Panel/Label.text = "Pick a Task"
		else:
			$UI/Panel/Label.text = "Can't pick tasks right now"
		$UI/Buttons/PickTaskButton.visible = value
		can_pick_tasks = value

## Emitted when a note is picked (using the Pick button)
signal note_picked(Note)

func _ready() -> void:
	$UI.hide()
	$UI/Buttons.hide()
	
	for child in get_children():
		if child is Note:
			child.connect("note_clicked", _on_note_clicked)

func _on_note_clicked(note: Note) -> void:
	if not focused:
		return
	if focused_note == note:
		return
	unfocus_note()
	focus_note(note)

## Stop focusing the current note
func unfocus_note() -> void:
	if focused_note != null:
		focused_note.fold()
		var old_tween = get_tree().create_tween()
		old_tween.tween_property(focused_note, "transform", note_origin_position, 1.0).set_trans(Tween.TRANS_SINE)
		focused_note = null
		$UI/Buttons.hide()

## Bring a new note into focus
func focus_note(note: Note) -> void:
	note_origin_position = note.transform
	focused_note = note
	note.unfold()
	$NoteSFX.play()
	var tween = get_tree().create_tween()
	tween.tween_property(note, "transform", $NotePlaceholder.transform, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property($UI/Buttons, "visible", true, 0.0)

func _on_focus_gained() -> void:
	$UI.show()

func _on_focus_lost() -> void:
	$UI.hide()
	unfocus_note()

func _on_cancel_button_pressed() -> void:
	unfocus_note()

func _on_pick_task_button_pressed() -> void:
	if focused_note is Note and can_pick_tasks:
		## Give up ownership of note and signal picked
		var note = focused_note
		focused_note = null
		$UI/Buttons.hide()
		note.disconnect("note_picked", _on_note_clicked)
		note_picked.emit(note)
