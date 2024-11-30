extends Node

var day: int = 1

## All tasks of the game, in order
var all_tasks: Array[Task] = [
	preload("res://resources/tasks/day1note1.tres"),
	preload("res://resources/tasks/day1note2.tres"),
	preload("res://resources/tasks/day1note3.tres"),
	preload("res://resources/tasks/day1note4.tres"),
	preload("res://resources/tasks/day1note5.tres"),
	preload("res://resources/tasks/day1note6.tres"),
	preload("res://resources/tasks/day2note1.tres"),
	preload("res://resources/tasks/day2note2.tres"),
	preload("res://resources/tasks/day2note3.tres"),
	preload("res://resources/tasks/day2note4.tres"),
	preload("res://resources/tasks/day2note5.tres"),
	preload("res://resources/tasks/day2note6.tres"),
	preload("res://resources/tasks/day3note1.tres"),
	preload("res://resources/tasks/day3note2.tres"),
	preload("res://resources/tasks/day3note3.tres"),
	preload("res://resources/tasks/day3note4.tres"),
	preload("res://resources/tasks/day3note5.tres"),
	preload("res://resources/tasks/day3note6.tres"),
	preload("res://resources/tasks/day4note1.tres"),
	preload("res://resources/tasks/day4note2.tres"),
	preload("res://resources/tasks/day4note3.tres"),
	preload("res://resources/tasks/day4note4.tres"),
	preload("res://resources/tasks/day5note1.tres"),
]

## Emitted to add a task to the board
signal new_task(task: Task)

func start_day() -> void:
	for task in all_tasks:
		if task.day == day and task.unlocked:
			new_task.emit(task)

func end_day() -> void:
	# TODO: Switch to the "end day" scene
	pass

func on_task_completed() -> void:
	# Check for newly available tasks
	for task in all_tasks:
		if task.day == day and task.unlocked and not task.available:
			new_task.emit(task)
