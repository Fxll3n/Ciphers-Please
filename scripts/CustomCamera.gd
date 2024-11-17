extends Camera3D
class_name CustomCamera

@export_range(0, 180, 5, "radians") var maxFOV_x = deg_to_rad(90)
@export_range(0, 180, 5, "radians") var maxFOV_y = deg_to_rad(40)
@export var mouseSensitivity = Vector2(0.01, 0.01)
@export var stickSensitivity = Vector2(3, 3)
@export_range(0, 1, 0.05) var stickDeadzone = 0.15
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
				Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
				# Remove focus from current target if any
				if not targets.is_empty():
					targets.back().focused = false
					targets.back().disconnect("zoom_out", self.zoom_out)
			State.LOCKED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$Reticle.visible = (new_state == State.FREE)
		state = new_state

## List of global transforms to zoom back to
var origins: Array[Transform3D] = []
## List of zoom targets (last one is focused)
var targets: Array[ZoomTarget3D] = []

func _ready() -> void:
	# Start mouse capture if camera isn't locked
	if state == State.FREE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	# Camera movement (clamped to maxFOV)
	if event is InputEventMouseMotion and state == State.FREE:
		_rotate_camera(event.relative * mouseSensitivity)

func _physics_process(delta: float) -> void:
	# Camera movement using joystick
	var stickInput = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	if stickInput.length() > stickDeadzone:
		_rotate_camera(stickInput * stickSensitivity * delta)
	
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
func _rotate_camera(delta_rad: Vector2):
	if state == State.FREE:
		rotation.y = clamp(rotation.y - delta_rad.x, centerOfView.y - maxFOV_x, centerOfView.y + maxFOV_x)
		rotation.x = clamp(rotation.x - delta_rad.y, centerOfView.x - maxFOV_y, centerOfView.x + maxFOV_y)

## Focus the camera on a new target
func zoom_in(target: ZoomTarget3D) -> void:
	assert(state == State.FREE or state == State.LOCKED)
	
	# Store current position and target destination
	origins.push_back(global_transform)
	targets.push_back(target)
	var destination := target.target_transform
	
	# Hide cursor and animate translation
	state = State.ZOOM_IN
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_transform", destination, 1).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(self._zoom_finished)

## Make the camera go back to the nth target, with 0 being free camera
## Negative `target_level` means go to nth previous target
func zoom_out(target_level: int = -1) -> void:
	assert(state == State.LOCKED)
	if target_level < 0:
		target_level = origins.size() + target_level
	assert(0 <= target_level and target_level < origins.size())
	
	# Hide cursor and animate translation
	state = State.ZOOM_OUT
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_transform", origins[target_level], 1).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(self._zoom_finished)
	# Focus new target if any
	if target_level > 0:
		targets[target_level - 1].focused = true
	# Drop popped levels
	origins.resize(target_level)
	targets.resize(target_level)

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
