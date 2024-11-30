extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	if General.scene_before != "Menu":
		General.scene_before = "Menu"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/worlds/office.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_credits_pressed():
	get_tree().change_scene_to_file("res://UI/Scenes/Credits.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://UI/Scenes/settings.tscn")
