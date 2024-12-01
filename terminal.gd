extends Control

@onready var NotesContainer: VBoxContainer = $"TabBarSplit/MainSplit/Section 3/MarginContainer/VBoxContainer"

@onready var transmission_text: RichTextLabel = $"TabBarSplit/MainSplit/TransmisionSplit/Section 1/MarginContainer/VBoxContainer/TransmissionText"
@onready var notes_text: RichTextLabel = $"TabBarSplit/MainSplit/Section 3/MarginContainer/VBoxContainer/NotesText"

## Emitted when the terminal is closed
signal terminal_closed

## Load a new task into the terminal
func load_task(task: Task) -> void:
	assert(task != null)
	transmission_text.text = task.input_text
	
	for child in NotesContainer.get_children():
			if child is not RichTextLabel and child is not HSeparator:
				child.queue_free()
	match task.cipher_type:
		Data.CipherType.Caesar:
			var tool = load("res://CeasarDisk.tscn")
			var created_tool = tool.new()
			NotesContainer.add_child(created_tool)

		

func _on_exit_pressed() -> void:
	terminal_closed.emit()
