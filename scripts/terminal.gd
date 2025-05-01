extends Control

@onready var transmission_text: RichTextLabel = $"TabBarSplit/MainSplit/TransmisionSplit/Section 1/MarginContainer/VBoxContainer/TransmissionText"
@onready var notes_text: RichTextLabel = $"TabBarSplit/MainSplit/Section 3/MarginContainer/VBoxContainer/NotesText"
@onready var text_edit: TextEdit = $"TabBarSplit/MainSplit/TransmisionSplit/Section 2/MarginContainer/VBoxContainer/TextEdit"
@onready var tools_container: CenterContainer = $"TabBarSplit/MainSplit/Section 3/MarginContainer/VBoxContainer/ToolsContainer"

@onready var transmission_heading: Label = $"TabBarSplit/MainSplit/TransmisionSplit/Section 1/MarginContainer/VBoxContainer/TransmissionHeading"
@onready var user_entry_heading: Label = $"TabBarSplit/MainSplit/TransmisionSplit/Section 2/MarginContainer/VBoxContainer/UserEntryHeading"
@onready var notes_heading: Label = $"TabBarSplit/MainSplit/Section 3/MarginContainer/VBoxContainer/NotesHeading"

@onready var message_progress: ProgressBar = $"TabBarSplit/MainSplit/TransmisionSplit/Section 2/MarginContainer/VBoxContainer/HBoxContainer2/MessageProgress"
@onready var autofill_button: Button = $"TabBarSplit/MainSplit/TransmisionSplit/Section 2/MarginContainer/VBoxContainer/HBoxContainer2/Autofill"
@onready var submit_button: Button = $"TabBarSplit/MainSplit/TransmisionSplit/Section 2/MarginContainer/VBoxContainer/HBoxContainer/Submit"
@onready var trash_button: Button = $"TabBarSplit/MainSplit/TransmisionSplit/Section 2/MarginContainer/VBoxContainer/HBoxContainer/Trash"


var CaesarScene = preload("res://scenes/CaesarDisk.tscn")

var current_task: Task = null
var validator: Validator = null
var autofill_used: bool = false

const autofill_unlock_ratio: float = 0.20
const submit_unlock_ratio: float = 0.90
const autofill_speed: float = 12 # letters per second

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
	
	transmission_heading.text = "Input message:" if task.msg_type == Data.MessageType.Outgoing else "Encrypted message:"
	user_entry_heading.text = "Encrypt message:" if task.msg_type == Data.MessageType.Outgoing else "Decipher message:"
	notes_heading.text = "Notes: " + Data.GetCipherName(task.cipher_type)
	text_edit.clear()
	text_edit.grab_focus()
	
	# Remove existing children
	for child in tools_container.get_children():
		child.queue_free()
		
	var tool: CipherTool = null
	
	# Properly instantiate the scene based on cipher type
	match task.cipher_type:
		Data.CipherType.Caesar:
			notes_text.text = "The \"Caesar Cipher\" is a monoalphabetic substitution cipher. Meaning it uses only the standard alphabet to substitute letters and their positions.\nCaesar cipher simply moves the letters an \"x\" amount of times to the right."
			tool = CaesarScene.instantiate()
		Data.CipherType.Vigenere:
			notes_text.text = "The Vigenère Cipher is a polyalphabetic substitution cipher that shifts letters using multiple Caesar ciphers with varying keys. To decrypt, match each encrypted letter with the corresponding letter of the key to reverse the shift, repeating for the entire message."
			tool = VigenereTable.new()
		Data.CipherType.Rail:
			notes_text.text = "The Rail Fence Cipher is a transposition cipher that arranges text in a zigzag pattern across a set number of \"rails.\" To encrypt, write the text row by row following the zigzag. To decrypt, reconstruct the zigzag pattern and read the text sequentially."
			tool = RailTool.new()
		Data.CipherType.PigPen:
			notes_text.text = "The Pigpen Cipher is a substitution cipher that replaces each letter with a symbol based on a simple grid or \"pigpen\" layout. To encrypt, substitute each letter with its corresponding symbol from the grid. To decrypt, reverse the process by matching symbols to their letters in the grid."
			tool = PigPen.new()
		Data.CipherType.Atbash:
			notes_text.text = "The Atbash Cipher is a substitution cipher that reverses the alphabet. Each letter is replaced with its opposite: A becomes Z, B becomes Y, and so on. To decrypt, apply the same process since it is symmetric."
		Data.CipherType.Plaintext:
			notes_text.text = "Plain text message is the least secure form of communication. The input message is the output message."
			
	if tool != null:
		tool.encrypting = (task.msg_type == Data.MessageType.Outgoing)
		tool.key = task.key
		tool.message = task.input_text
		tool.letter_clicked.connect(_on_letter_clicked)
		tools_container.add_child(tool )
	
	validator = Validator.new()
	validator.expected = current_task.expected_text
	text_edit.syntax_highlighter = validator
	autofill_used = false

func unload_task() -> void:
	if current_task != null:
		transmission_text.text = ''
		text_edit.text = ''
		notes_heading.text = "Notes:"
		notes_text.text = ''
		current_task = null
		validator = null
		message_progress.value = 0
		autofill_button.disabled = true
		submit_button.disabled = true
		trash_button.disabled = true

	# Remove existing children
	for child in tools_container.get_children():
		child.queue_free()

func _on_exit_pressed() -> void:
	terminal_closed.emit()

func _on_autofill_pressed() -> void:
	if current_task != null:
		autofill_start()

func _on_submit_pressed() -> void:
	if current_task != null:
		task_complete.emit()

func _on_trash_pressed() -> void:
	if current_task != null:
		task_deleted.emit()

func _on_letter_clicked(letter: String) -> void:
	if text_edit.editable:
		text_edit.insert_text_at_caret(letter)

func _on_text_edit_text_changed() -> void:
	if current_task != null:
		var ratio = validator.similarity_index
		message_progress.value = ratio
		autofill_button.disabled = autofill_used or ratio < autofill_unlock_ratio
		submit_button.disabled = ratio < submit_unlock_ratio
		trash_button.disabled = ratio < submit_unlock_ratio

func autofill_start() -> void:
	if current_task == null or autofill_used:
		return
	autofill_button.disabled = true
	autofill_used = true
	validator.show_highlight = true
	var start = validator.last_index
	var end = current_task.expected_text.length()
	if start >= end:
		# Trigger updates to force highlight refresh
		validator.update_cache()
		text_edit.grab_focus()
		return
	text_edit.editable = false
	var tween = get_tree().create_tween()
	var duration = (end - start) / autofill_speed
	tween.tween_method(autofill_update.bind(text_edit.text, start), start, end, duration)
	tween.tween_callback(autofill_finished)

func autofill_update(index: int, initial_text: String, start_index: int):
	if current_task != null:
		var new_text = initial_text + current_task.expected_text.substr(start_index, index - start_index)
		if new_text != text_edit.text:
			text_edit.text = new_text
			_on_text_edit_text_changed.call_deferred()

func autofill_finished() -> void:
	text_edit.editable = true
