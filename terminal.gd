extends Control


@onready var transmission_text: RichTextLabel = $"TabBarSplit/MainSplit/TransmisionSplit/Section 1/MarginContainer/VBoxContainer/TransmissionText"
@onready var notes_text: RichTextLabel = $"TabBarSplit/MainSplit/Section 3/MarginContainer/VBoxContainer/NotesText"

## Emitted when the terminal is closed
signal terminal_closed


var loaded_task = func():
	var task = load("res://scripts/CurrentTask/CurrentTask.tres")
	
	if task as CeasarTask:
		return task as CeasarTask
	elif task as AtbashTask:
		return task as AtbashTask
	elif task as VigenereTask:
		return task as VigenereTask
	elif task as PigPenTask:
		return task as PigPenTask
	elif task as RailTask:
		return task as RailTask
	else:
		return task as EmptyTask

func _ready() -> void:
	ResourceSaver.save(EmptyTask.new(), "res://scripts/CurrentTask/CurrentTask.tres")

func _process(delta: float) -> void:
	var task = loaded_task.call()
	transmission_text.text = task.text

func _on_exit_pressed() -> void:
	terminal_closed.emit()
