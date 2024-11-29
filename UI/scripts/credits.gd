extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func back_button_pressed():
	if General.scene_before == "Main":
		get_tree().change_scene_to_file("res://scenes/worlds/office.tscn")
	elif General.scene_before == "Menu":
		get_tree().change_scene_to_file("res://UI/Scenes/main_menu.tscn")
