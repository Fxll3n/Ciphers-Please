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
			var note = RichTextLabel.new()
			NotesContainer.add_child(note)
			note.fit_content = true
			note.text = "The \"Ceasar Cipher\" is a monoalphabetic substitution cipher. Meaning it uses only the standard alphabet to substitute letters adn their positions.\nCesar cipher simply moves the letters an \"x\" amount of times to the right."
			var tool = preload("res://CeasarDisk.tscn")
			var created_tool = tool.instantiate()
			NotesContainer.add_child(created_tool)
		Data.CipherType.Vigenere:
			var note = RichTextLabel.new()
			NotesContainer.add_child(note)
			note.fit_content = true
			note.text = "The Vigenère Cipher is a polyalphabetic substitution cipher that shifts letters using multiple Caesar ciphers with varying keys. A keyword is used to determine the shifts. To decrypt, match each encrypted letter with the corresponding letter of the key to reverse the shift, repeating for the entire message."
			var table = VigenereTable.new()
			table.key = task.key
			table.encrypt = task.msg_type == Data.MessageType.Outgoing
			NotesContainer.add_child(table)
			table.custom_minimum_size = Vector2(300, 500)
		Data.CipherType.Rail:
			var note = RichTextLabel.new()
			NotesContainer.add_child(note)
			note.fit_content = true
			note.text = "The Rail Fence Cipher is a transposition cipher that arranges text in a zigzag pattern across a set number of \"rails.\" To encrypt, write the text row by row following the zigzag. To decrypt, reconstruct the zigzag pattern and read the text sequentially."
			var tool = RailTool.new()
			NotesContainer.add_child(tool)
			tool.message = task.input_text
			tool.create_letter_row()
		Data.CipherType.PigPen:
			var note = RichTextLabel.new()
			NotesContainer.add_child(note)
			note.fit_content = true
			note.text = "The Pigpen Cipher is a substitution cipher that replaces each letter with a symbol based on a simple grid or \"pigpen\" layout. To encrypt, substitute each letter with its corresponding symbol from the grid. To decrypt, reverse the process by matching symbols to their letters in the grid."
			var img = preload("res://img.tscn")
			var created_img = img.instantiate()
			print(created_img)
			NotesContainer.add_child(created_img)
		Data.CipherType.Atbash:
			var note = RichTextLabel.new()
			NotesContainer.add_child(note)
			note.fit_content = true
			note.text = "The Atbash Cipher is a substitution cipher that reverses the alphabet. Each letter is replaced with its opposite: A becomes Z, B becomes Y, and so on. To decrypt, apply the same process since it is symmetric."
	# text_edit.text = task.expected_text

func unload_task() -> void:
	if current_task != null:
		transmission_text.text = ''
		text_edit.text = ''
		current_task = null

	# Remove existing children (except RichTextLabel and HSeparator)
	for child in NotesContainer.get_children():
		if child is not RichTextLabel and child is not HSeparator:
			child.queue_free()

func _on_exit_pressed() -> void:
	terminal_closed.emit()

func _on_submit_pressed() -> void:
	if current_task != null:
		task_complete.emit()

func _on_trash_pressed() -> void:
	if current_task != null:
		task_deleted.emit()
