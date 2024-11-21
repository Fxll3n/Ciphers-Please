extends Control


@onready var transmission_text: RichTextLabel = $"TabBarSplit/MainSplit/TransmisionSplit/Section 1/MarginContainer/VBoxContainer/TransmissionText"
@onready var notes_text: RichTextLabel = $"TabBarSplit/MainSplit/Section 3/MarginContainer/VBoxContainer/NotesText"

## Emitted when the terminal is closed
signal terminal_closed

## Load a new task into the terminal
func load_task(task_path: String) -> void:
	var task = load(task_path) as Task
	assert(task != null)
	transmission_text.text = task.input_text

func _ready() -> void:
	load_task("res://resources/tasks/hello.tres")

func _on_exit_pressed() -> void:
	terminal_closed.emit()
