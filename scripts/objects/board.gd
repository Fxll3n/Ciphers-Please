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

## Lists all available slots for attaching notes, excluding zones with post-it notes
var available_slots: Array = range(1, 11)

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
		if note.board_slot >= 0:
			available_slots.append(note.board_slot)
		note.disconnect("note_clicked", _on_note_clicked)
		note_picked.emit(note)

## Gets the (slightly randomized) transform for a certain board slot
func _get_slot_transform(index: int) -> Transform3D:
	var col = index % 3
	@warning_ignore("integer_division")
	var row = int(index / 3)
	var x = (col - 1) * -0.60 / 4.0 + randf_range(-0.02, 0.02)
	var y = (row - 1.5) * 0.80 / 5.0 + randf_range(-0.04, 0.04)
	return Transform3D(Basis.IDENTITY, Vector3(x, y, 0.03))

## Attach a new note to the board
func attach_note(note: Note) -> void:
	if available_slots.is_empty():
		print_debug("Cannot show note, no slots left: ", note)
		return
	var i = randi_range(0, available_slots.size() - 1)
	var slot = available_slots[i]
	available_slots.remove_at(i)
	
	if note.get_parent() == null:
		add_child(note)
	else:
		note.reparent(self, false)
	note.board_slot = slot
	note.transform = _get_slot_transform(slot)
	note.connect("note_clicked", _on_note_clicked)
	
	# Play sound if needed
	if can_pick_tasks:
		$NoteSFX.play()
