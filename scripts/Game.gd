extends Node

var day: int = 1

## All tasks of the game, in order
var all_tasks: Array[Task] = [
	preload("res://resources/tasks/hello.tres"),
]

var day_tasks: Array[Task] = []

func _ready() -> void:
	# TODO: Make this better
	for i in range(5):
		day_tasks.append(all_tasks[0].duplicate())

func end_day() -> void:
	# TODO: Switch to the "end day" scene
	pass
