extends Node2D
@onready var gui = $GUI
@onready var camera = $CanvasLayer/SubViewportContainer/SubViewport/Camera2D

var game_paused = false
# Called when the node enters the scene tree for the first time.
func _physics_process(_delta):
	camera.position = self.find_child("CharacterBody2D").position
func _ready():
	General.scene_before = "map"
func _unhandled_input(event):
	if event.is_action_pressed("esc"):
		game_paused = !game_paused
		if game_paused:
			Engine.time_scale = 0
			gui.visible = true
		else:
			Engine.time_scale = 1
			gui.visible = false
		get_tree().root.get_viewport().set_input_as_handled()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	get_tree().change_scene_to_file("res://settings.tscn")


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
