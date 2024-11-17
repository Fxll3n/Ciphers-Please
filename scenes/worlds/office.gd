extends Node3D

@onready var Camera = $PlayerCam as CustomCamera

func _input(event):
	if event.is_action_pressed("debug_quit"):
		# Quickly exit the scene if stuck
		get_tree().quit()
	
	if event.is_action_pressed("debug_toggle_capture"):
		if Camera.state == Camera.State.FREE:
			Camera.zoom_in($UglyComputer/Screen)
		elif Camera.state == Camera.State.LOCKED:
			Camera.zoom_out(0)
