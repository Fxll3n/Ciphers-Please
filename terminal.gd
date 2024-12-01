extends Control

@onready var NotesContainer: VBoxContainer = $"TabBarSplit/MainSplit/Section 3/MarginContainer/VBoxContainer"

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
	
	# Remove existing children (except RichTextLabel and HSeparator)
	for child in NotesContainer.get_children():
		if child is not RichTextLabel and child is not HSeparator:
			child.queue_free()
	
	# Properly instantiate the scene based on cipher type
	match task.cipher_type:
		Data.CipherType.Caesar:
			var tool = preload("res://CeasarDisk.tscn")
			var created_tool = tool .instantiate()
			NotesContainer.add_child(created_tool)
		Data.CipherType.Vigenere:
			var table = VigenereTable.new()
			NotesContainer.add_child(table)
			table.custom_minimum_size = Vector2(300, 500)
		Data.CipherType.Rail:
			var tool = RailTool.new()
			NotesContainer.add_child(tool )
		Data.CipherType.PigPen:
			var img = preload("res://img.tscn")
			var created_img = img.instantiate()
			print(created_img)
			NotesContainer.add_child(created_img)
	# text_edit.text = task.expected_text

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
