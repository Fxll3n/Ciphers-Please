class_name Note extends Area3D

@export var task: Task
@export var folded: bool = true

@onready var label: Label = $SubViewport/NoteUI/Label
@onready var stampTexture = $SubViewport/NoteUI/TextureRect

@onready var folded_angle_deg = randf_range(140, 175)
@onready var unfolded_angle_deg = randf_range(5, 20)

var board_slot: int = -1 # Used only for board management

signal note_clicked(note: Note)

## Focus this note when clicked if the parent target is focused
func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("pick_object"):
		note_clicked.emit(self)

func _ready() -> void:
	# Initialise note UI based on task contents
	if task is Task:
		var labelText = ""
		
		# Sender / recipient
		if task.msg_type == Data.MessageType.Outgoing:
			labelText += "To: " + task.from_to
		else:
			labelText += "From: " + task.from_to
		
		# Cipher kind
		labelText += "\n\nCipher: " + Data.GetCipherName(task.cipher_type)
		
		# Difficulty and reward
		labelText += "\n\nDifficulty: " + String.num(task.difficulty)
		labelText += "           Reward: " + String.num(task.pay) + Data.MoneyUnit
		
		# Secret stuff
		labelText += "\n\n-- CONFIDENTIAL MESSAGE BELOW --"
		
		if Data.CipherHasKey(task.cipher_type):
			labelText += "\n\nKey: " + task.key
		
		labelText += "\n\n" + task.input_text
		label.text = labelText
		
		# Find length of longest word and force wrap if it's too long
		var longest = 0
		for word in task.input_text.split(" ", false):
			longest = max(longest, len(word))
		if longest > 30:
			label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		
		# Initialize stamp
		var textureRegion = stampTexture.texture.region as Rect2
		if textureRegion != null:
			textureRegion.position.y = textureRegion.size.y * task.msg_type
			stampTexture.texture.region = textureRegion
		
	# Initialize shader for folding
	if folded:
		_set_fold_angle(folded_angle_deg)
	else:
		_set_fold_angle(unfolded_angle_deg)

func _set_fold_angle(angle_deg) -> void:
	$Quad.get_active_material(0).set_shader_parameter("fold_rad", deg_to_rad(angle_deg))

func fold(time: float = 1.0) -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(_set_fold_angle, unfolded_angle_deg, folded_angle_deg, time).set_trans(Tween.TRANS_SINE)
	
func unfold(time: float = 1.0) -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(_set_fold_angle, folded_angle_deg, unfolded_angle_deg, time).set_trans(Tween.TRANS_SINE)
