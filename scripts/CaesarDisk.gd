extends CipherTool

@onready var bottom_wheel: Sprite2D = $BottomWheel
@onready var area_2d: Area2D = $OutsideArea

## Whether the mouse is currently dragging
var is_dragging: bool = false
## Whether the initial mouse click was on the wheel
var is_clicked: bool = false
## Total distance dragged (used to detect clicks)
var drag_distance: float = 0
## Whether the mouse is on the outer wheel
var outer_hover: bool = false
## Whether the mouse is on the inner wheel
var inner_hover: bool = false:
	set(value):
		if inner_hover != value:
			inner_hover = value
			queue_redraw()
## Whether the mouse is on the center area
var center_hover: bool = false:
	set(value):
		if center_hover != value:
			center_hover = value
			queue_redraw()
## The value currently hovered, 0 if not applicable
var current_value: int = 0:
	set(value):
		if current_value != value:
			current_value = value
			queue_redraw()

func _ready() -> void:
	var bottom_offset = randi_range(0, 25)
	var top_offset = (bottom_offset + key.to_int()) % 26
	$BottomWheel/Hint.rotation = bottom_offset * TAU / 26
	$TopWheel/Hint.rotation = top_offset * TAU / 26
	for child in find_children("*crypt*"):
		child.visible = (child.name.contains("Encrypt")) == encrypting

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				is_dragging = true
				area_2d.look_at(event.global_position)
			elif event.is_released():
				set_default_cursor_shape(Control.CURSOR_POINTING_HAND if outer_hover and not center_hover else Control.CURSOR_ARROW)
				is_dragging = false
				is_clicked = false
				bottom_wheel.rotation = (_get_value() / 26.0 * TAU)
				
				if drag_distance <= 5 and outer_hover:
					if center_hover:
						letter_clicked.emit(' ')
					else:
						var value = 7 + _get_value_from(bottom_wheel.global_position.angle_to_point(event.global_position))
						if not inner_hover:
							value += 26 - _get_value()
						letter_clicked.emit(char((value % 26) + 65))
				drag_distance = 0

	if event is InputEventMouseMotion:
		if is_dragging and is_clicked:
			set_default_cursor_shape(Control.CURSOR_MOVE)
			current_value = 0
			drag_distance += event.relative.length()
			var old = area_2d.rotation
			area_2d.look_at(event.global_position)
			bottom_wheel.rotate(area_2d.rotation - old)
			$NumberLabel.text = String.num(_get_value())
		else:
			current_value = _get_value_from(bottom_wheel.global_position.angle_to_point(event.global_position)) if outer_hover else 0

func _draw() -> void:
	if current_value > 0 and not center_hover:
		var radius_from = 73 if inner_hover else 120
		var radius_to = 114 if inner_hover else 178
		var angle = (current_value * TAU / 26)
		var points = _arc_polygon(bottom_wheel.position, radius_from, radius_to, angle, angle + TAU / 26)
		draw_colored_polygon(points, Color(0, 0, 0, 0.25))

func _arc_polygon(center: Vector2, radius_from: float, radius_to: float, angle_from: float, angle_to: float, segments: int = 32) -> Array[Vector2]:
	var first : Array[Vector2] = []
	var second: Array[Vector2]  = []
	for i in range(segments):
		var angle = remap(i, 0, segments - 1, angle_from, angle_to)
		first.append(center + Vector2.from_angle(angle) * radius_from)
		second.insert(0, center + Vector2.from_angle(angle) * radius_to)
	return first + second

func _get_value() -> int:
	return _get_value_from(bottom_wheel.rotation + TAU / 26 / 2)

func _get_value_from(angle: float) -> int:
	var rounded = int(fposmod(angle, TAU) * 26 / TAU) % 26
	return 26 if rounded == 0 else rounded

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				is_clicked = true

func _on_outside_area_mouse_entered() -> void:
	if not is_dragging:
		set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	outer_hover = true

func _on_outside_area_mouse_exited() -> void:
	if not is_dragging:
		set_default_cursor_shape(Control.CURSOR_ARROW)
	outer_hover = false

func _on_inside_area_mouse_entered() -> void:
	inner_hover = true

func _on_inside_area_mouse_exited() -> void:
	inner_hover = false

func _on_center_area_mouse_entered() -> void:
	if not is_dragging:
		set_default_cursor_shape(Control.CURSOR_ARROW)
	center_hover = true

func _on_center_area_mouse_exited() -> void:
	if not is_dragging:
		set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	center_hover = false
