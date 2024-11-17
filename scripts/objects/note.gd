extends Area3D

## Focus this note when clicked if the parent target is focused
func _on_input_event(camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("pick_object") and camera is CustomCamera:
		var parent := get_parent_node_3d() as ZoomTarget3D
		if parent == null or parent.focused:
			(camera as CustomCamera).zoom_in($ZoomTarget3D)
