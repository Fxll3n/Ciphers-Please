extends Control


var loaded_task = func():
	var task = load("res://scripts/CurrentTask/CurrentTask.tres")
	
	if task as CeasarTask:
		return task as CeasarTask
	elif task as AtbashTask:
		return task as AtbashTask
	elif task as VigenereTask:
		return task as VigenereTask
	elif task as PigPenTask:
		return task as PigPenTask
	elif task as RailTask:
		return task as RailTask
	else:
		return task as EmptyTask




func _on_exit_pressed() -> void:
	pass # Replace with leaving terminal code
