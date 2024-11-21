extends Area3D

@export var task: Task
@export var folded: bool = true

@onready var label: Label = $SubViewport/NoteUI/Label
@onready var stampTexture = $SubViewport/NoteUI/TextureRect

@onready var folded_angle_deg = randf_range(140, 175)
@onready var unfolded_angle_deg = randf_range(5, 35)

## Focus this note when clicked if the parent target is focused
func _on_input_event(camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("pick_object") and camera is CustomCamera:
		var parent := get_parent_node_3d() as ZoomTarget3D
		if parent == null or parent.focused:
			(camera as CustomCamera).zoom_in($ZoomTarget3D)

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

func _set_fold_angle(angle_deg):
	$Quad.get_active_material(0).set_shader_parameter("fold_rad", deg_to_rad(angle_deg))
