extends Camera3D
class_name CustomCamera

@export_group("Gameplay settings")
@export_range(0, 180, 5, "radians") var maxFOV_x = deg_to_rad(90)
@export_range(0, 180, 5, "radians") var maxFOV_y = deg_to_rad(40)
@onready var centerOfView = rotation

## Current state of the camera zoom/lock animation
enum State {FREE, ZOOM_IN, LOCKED, ZOOM_OUT}
@export var state := State.FREE:
	## Automatically set mouse_mode and reticle visibility on state change
	set(new_state):
		if new_state == state:
			return
		# Mouse capture
		match new_state:
			State.FREE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			State.ZOOM_IN, State.ZOOM_OUT:
				Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
				# Remove focus from current target if any
				if not targets.is_empty():
					targets.back().focused = false
					targets.back().disconnect("zoom_out", self.zoom_out)
			State.LOCKED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$Reticle.visible = (new_state == State.FREE)
		state = new_state

@export_group("Controls")
@export var mouseSensitivity = Vector2(0.2, 0.2)
@export var stickSensitivity = Vector2(3, 3)
@export var experimentalRotationSmoothing: bool = true
@export_range(0, 1, 0.05) var stickDeadzone = 0.15

## Signal emitted when the camera starts moving toward a new target
signal focusing(Node3D)

## List of global transforms to zoom back to
var origins: Array[Transform3D] = []
## List of zoom targets (last one is focused)
var targets: Array[ZoomTarget3D] = []

func _ready() -> void:
	# Start mouse capture if camera isn't locked
	if state == State.FREE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## Accumulator for relative mouse movement in-between physics ticks
var mouseRelativeDelta := Vector2.ZERO

func _input(event):
	# Camera movement (clamped to maxFOV)
	if event is InputEventMouseMotion and state == State.FREE:
		mouseRelativeDelta += event.relative

func _physics_process(delta: float) -> void:
	# Camera movement using mouse
	if !mouseRelativeDelta.is_zero_approx():
		_rotate_camera(mouseRelativeDelta * mouseSensitivity, delta)
		mouseRelativeDelta = Vector2.ZERO
	
	# Camera movement using joystick
	var stickInput = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	if stickInput.length() > stickDeadzone:
		_rotate_camera(stickInput * stickSensitivity, delta)
	
	# Target picking, only works when camera is free
	if state == State.FREE and Input.is_action_just_pressed("pick_object"):
		var collider = $ObjectPickerRay.get_collider()
		if collider is ZoomTarget3D:
			zoom_in(collider)
		elif collider is Node3D:
			for child in collider.get_children():
				if child is ZoomTarget3D:
					zoom_in(child)
					return
			print_debug("Collider", collider, "has no valid target children")
			
	if state == State.LOCKED and Input.is_action_just_pressed("go_back"):
		zoom_out()

## Rotate the camera within the maxFOV bounds
func _rotate_camera(delta_rad: Vector2, time_delta: float):
	if state == State.FREE:
		var new_rot = Vector3(
			clamp(rotation.x - time_delta * delta_rad.y, centerOfView.x - maxFOV_y, centerOfView.x + maxFOV_y),
			clamp(rotation.y - time_delta * delta_rad.x, centerOfView.y - maxFOV_x, centerOfView.y + maxFOV_x),
			rotation.z)
		if experimentalRotationSmoothing:
			get_tree().create_tween().tween_property(self, "rotation", new_rot, time_delta)
		else:
			rotation = new_rot

## Focus the camera on a new target
func zoom_in(target: ZoomTarget3D) -> void:
	if not (state == State.FREE or state == State.LOCKED):
		push_warning("zoom_in called while camera was not free nor locked")
		return
	state = State.ZOOM_IN
	
	# Store current position and target destination
	origins.push_back(global_transform)
	targets.push_back(target)
	var destination := target.target_transform
	
	# Hide cursor and animate translation
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_transform", destination, 1).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(self._zoom_finished)
	
	focusing.emit(target)

## Make the camera go back to the nth target, with 0 being free camera
## Negative `target_level` means go to nth previous target
func zoom_out(target_level: int = -1) -> void:
	if state != State.LOCKED:
		push_warning("zoom_out called while camera was not locked")
		return
	if target_level < 0:
		target_level = origins.size() + target_level
	assert(0 <= target_level and target_level < origins.size())
	
	state = State.ZOOM_OUT
	
	# Hide cursor and animate translation
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_transform", origins[target_level], 1).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(self._zoom_finished)
	# Drop popped levels
	origins.resize(target_level)
	targets.resize(target_level)

## Make the camera change its current target
func swap_to(new_target: ZoomTarget3D) -> void:
	if state != State.LOCKED:
		push_warning("swap_to called while camera was not locked")
		return
	assert(targets.size() > 0)
	
	# Drop previous target
	var old_target := targets[targets.size() - 1]
	old_target.focused = false
	old_target.disconnect("zoom_out", self.zoom_out)
	targets[targets.size() - 1] = new_target
	var destination := new_target.target_transform
	
	state = State.ZOOM_IN
	
	# Hide cursor and animate translation
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_transform", destination, 1).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(self._zoom_finished)

	focusing.emit(new_target)


## Called when the zoom_out animation is finished
func _zoom_finished() -> void:
		assert(state == State.ZOOM_IN or state == State.ZOOM_OUT)
		# Set state
		state = State.FREE if origins.is_empty() else State.LOCKED
		
		# Focus target if any
		if not targets.is_empty():
			var target := targets[targets.size() - 1]
			target.focused = true
			target.connect("zoom_out", self.zoom_out, CONNECT_ONE_SHOT)
