extends Node3D

@onready var Camera = $PlayerCam as CustomCamera

var last_pressed: int = -1000

func _input(event):
	if event.is_action_pressed("debug_quit"):
		# Quickly exit the scene if stuck
		if Time.get_ticks_msec() < last_pressed + 500:
			get_tree().quit()
		elif Camera.state == Camera.State.LOCKED:
			Camera.zoom_out(0)
		last_pressed = Time.get_ticks_msec()
