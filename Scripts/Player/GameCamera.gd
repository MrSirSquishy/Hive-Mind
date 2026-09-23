class_name GameCamera extends Camera2D
# GameCamera is an RTS-style camera for HM-9.
# Attach this script to a Camera2D node inside world.tscn.
# Controls: WASD / arrows = pan, middle- or right-mouse drag = pan,
# mouse wheel = zoom, left-click = emit SignalBus.world_clicked.

# @export exposes a variable in the Inspector so you can tweak
# it without editing code. Current value is the default.
@export var pan_speed: float = 600.0
@export var drag_speed: float = 1.0
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.4
@export var max_zoom: float = 2.5


# _ready runs ONCE when this node enters the scene tree.
func _ready() -> void:
	# If several cameras exist, this one becomes the active view.
	make_current()
	# Smooth out position changes so panning glides instead of snapping.
	position_smoothing_enabled = true
	# Higher number = catches up faster. 8 is a calm RTS feel.
	position_smoothing_speed = 8.0


# _process runs EVERY FRAME. delta is seconds since last frame.
func _process(delta: float) -> void:
	# Start with no movement; we add direction below based on keys held.
	var move_dir := Vector2.ZERO
	# In Godot 2D, -y is UP and +y is DOWN, -x is LEFT and +x is RIGHT.
	# Input.is_key_pressed is true the whole time a key is held down.
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move_dir.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move_dir.x += 1.0
	# Pressing W+D gives length ~1.41, which would move faster diagonally.
	# normalized() shrinks it back to length 1 so all directions match.
	if move_dir.length() > 1.0:
		move_dir = move_dir.normalized()
	# Do nothing if no keys are held; avoids smoothing jitter.
	if move_dir == Vector2.ZERO:
		return
	# Move the camera. Multiply by delta so speed is pixels-per-second,
	# not pixels-per-frame. Divide by zoom so panning feels the same
	# whether zoomed in (zoom 2.0) or out (zoom 0.5).
	position += move_dir * pan_speed * delta / zoom.x


# _unhandled_input runs only when an input event happens (mouse move,
# click, wheel). "Unhandled" means UI buttons get first dibs on clicks.
func _unhandled_input(event: InputEvent) -> void:
	# Case 1: the mouse moved. event.relative is how many pixels it moved.
	if event is InputEventMouseMotion:
		# Check if a drag button is currently held down.
		var middle_held := Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
		var right_held := Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		if middle_held or right_held:
			# Move opposite to the mouse for a grab-the-world feel.
			position -= event.relative * drag_speed / zoom.x
			# Stop here so this motion is not also treated as a click.
			return
	# Case 2: a mouse button was pressed, or the wheel was ticked.
	if event is InputEventMouseButton and event.pressed:
		# Wheel up zooms IN (world looks bigger).
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(zoom_step)
		# Wheel down zooms OUT (world looks smaller).
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(-zoom_step)
		# Left click is gameplay only. Middle/right are reserved for drag
		# above, so the two never fight each other.
		elif event.button_index == MOUSE_BUTTON_LEFT:
			# Convert screen pixels to world coordinates using camera pos + zoom.
			var world_pos := get_global_mouse_position()
			# Announce the click. Bee / Wave code listens for this later.
			# SignalBus.world_clicked.emit(world_pos)


# Helper that changes zoom by amount, clamped to [min_zoom, max_zoom].
# The leading underscore is a convention meaning "private to this file".
func _apply_zoom(amount: float) -> void:
	# Work out what the zoom would be after adding amount.
	var new_zoom_val: float = zoom.x + amount
	# clamp() forces it to stay inside the min/max range.
	new_zoom_val = clamp(new_zoom_val, min_zoom, max_zoom)
	# Zoom is a Vector2(x, y). Keep x and y equal or the image stretches.
	zoom = Vector2(new_zoom_val, new_zoom_val)
