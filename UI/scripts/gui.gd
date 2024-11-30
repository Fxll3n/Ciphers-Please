extends CanvasLayer

signal esc_pressed

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Esc"):
		get_viewport().set_input_as_handled()
		esc_pressed.emit()
