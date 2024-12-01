extends Node2D

@onready var bottom_wheel: Sprite2D = $BottomWheel
@onready var area_2d: Area2D = $Area2D

var is_dragging: bool = false
var is_clicked: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				is_dragging = true
			elif event.is_released():
				is_dragging = false
				is_clicked = false
				bottom_wheel.reparent(self)
				
	if is_dragging and is_clicked:
		#breakpoint
		area_2d.look_at(event.global_position)
		bottom_wheel.reparent(area_2d)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("Area2DEvent: ", event)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				is_clicked = true
