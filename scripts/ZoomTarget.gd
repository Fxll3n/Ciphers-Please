extends Node3D
class_name ZoomTarget3D
"""Class defining a zoom target for the custom camera."""

## Where the zoomed camera will go
@export var cam_target: Node3D = null
var target_transform: Transform3D:
	get():
		if cam_target is Node3D:
			return cam_target.global_transform
		for child in get_children():
			if child is Camera3D:
				return child.global_transform
		return self.global_transform

## Emitted to signal that the camera should leave
## Autoconnected when a camera locks on this target
signal zoom_out

## Whether the camera is locked on this target
var focused: bool = false:
	set(value):
		focused = value
		if value:
			_on_focus_gained()
		else:
			_on_focus_lost()

## Called when the node gains focus
func _on_focus_gained() -> void:
	pass

## Called when the node loses focus
func _on_focus_lost() -> void:
	pass
