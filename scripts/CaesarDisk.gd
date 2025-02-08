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
				area_2d.look_at(event.global_position)
			elif event.is_released():
				is_dragging = false
				is_clicked = false
				bottom_wheel.rotation = (_get_value() / 26.0 * TAU)
				
	if is_dragging and is_clicked:
		var old = area_2d.rotation
		area_2d.look_at(event.global_position)
		bottom_wheel.rotate(area_2d.rotation - old)
		$Label.text = String.num(_get_value())


func _get_value() -> int:
	var rounded = int(fposmod(bottom_wheel.rotation, TAU) * 26 / TAU + 0.5) % 26
	return 26 if rounded == 0 else rounded


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				is_clicked = true
