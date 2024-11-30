extends Control


@onready var transmission_text: RichTextLabel = $"TabBarSplit/MainSplit/TransmisionSplit/Section 1/MarginContainer/VBoxContainer/TransmissionText"
@onready var notes_text: RichTextLabel = $"TabBarSplit/MainSplit/Section 3/MarginContainer/VBoxContainer/NotesText"
@onready var text_edit: TextEdit = $"TabBarSplit/MainSplit/TransmisionSplit/Section 2/MarginContainer/VBoxContainer/TextEdit"

var current_task: Task = null

## Emitted when the terminal is closed
signal terminal_closed
## Emitted when a task is complete and submitted
signal task_complete
## Emitted when a task is complete but sent to trash
signal task_deleted

## Load a new task into the terminal
func load_task(task: Task) -> void:
	if current_task != null:
		return
	assert(task != null)
	current_task = task
	transmission_text.text = task.input_text
	text_edit.text = task.expected_text

func unload_task() -> void:
	if current_task != null:
		transmission_text.text = ''
		text_edit.text = ''
		current_task = null

func _on_exit_pressed() -> void:
	terminal_closed.emit()

func _on_submit_pressed() -> void:
	if current_task != null:
		task_complete.emit()

func _on_trash_pressed() -> void:
	if current_task != null:
		task_deleted.emit()
