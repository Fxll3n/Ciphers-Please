extends Control

@onready var option_button = $HBoxContainer/OptionButton as OptionButton

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	


func _on_button_pressed():
	if General.scene_before == "Menu":
		get_tree().change_scene_to_file("res://UI/Scenes/main_menu.tscn")
	elif General.scene_before == "Main":
		get_tree().change_scene_to_file("res://scenes/worlds/office.tscn")


func _on_button_2_pressed():
	$AudioStreamPlayer.play()
