extends ZoomTarget3D

func _ready() -> void:
	$Viewport.size = $Viewport/Terminal.size
	$Viewport/Terminal.connect("terminal_closed", zoom_out.emit)

## Forwards any non-mouse InputEvent to the viewport
func _input(event: InputEvent) -> void:
	if not focused:
		return
	if event is InputEventMouse:
		return
	if event.is_action("go_back"):
		return
	$Viewport.push_input(event)

## Forwards any InputEventMouse to the viewport
## Drag events may 
func _on_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not focused:
		return

	var size_3d = ($QuadMesh.mesh as QuadMesh).size
	var pos_3d: Vector3 = $QuadMesh.global_transform.affine_inverse() * event_position
	
	# Compute 2D position
	var relative_pos = Vector2(pos_3d.x / size_3d.x, -pos_3d.y / size_3d.y) + Vector2(0.5, 0.5)
	var pos_2d = relative_pos * Vector2($Viewport.size)
	
	# Send event
	event.position = pos_2d
	if event is InputEventMouse:
		event.global_position = pos_2d
	$Viewport.push_input(event)
