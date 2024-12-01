extends ZoomTarget3D

@onready var end_day_button: Button = $"../../EndDayScreen/EndDayButton"


func _on_focus_gained() -> void:
	end_day_button.show()

func _on_focus_lost() -> void:
	end_day_button.hide()
