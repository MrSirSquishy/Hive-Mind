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
@export var min_zoom: float = 0.2
@export var max_zoom: float = 2.5
@export var select_radius: float = 24.0
@export var click_drag_limit_px: float=8

var _left_down: bool = false
var _left_press_px: Vector2 = Vector2.ZERO

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


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var middle_held: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
		var right_held: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		if middle_held or right_held:
			position -= event.relative * drag_speed / zoom.x
			return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_apply_zoom(zoom_step)
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_apply_zoom(-zoom_step)
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_left_down = true
				_left_press_px = event.position
			else:
				if not _left_down:
					return
				_left_down = false
				if event.position.distance_to(_left_press_px) > click_drag_limit_px:
					return
				_scan_at_cursor()

# Helper that changes zoom by amount, clamped to [min_zoom, max_zoom].
# The leading underscore is a convention meaning "private to this file".
func _apply_zoom(amount: float) -> void:
	# Work out what the zoom would be after adding amount.
	var new_zoom_val: float = zoom.x + amount
	# clamp() forces it to stay inside the min/max range.
	new_zoom_val = clamp(new_zoom_val, min_zoom, max_zoom)
	# Zoom is a Vector2(x, y). Keep x and y equal or the image stretches.
	zoom = Vector2(new_zoom_val, new_zoom_val)

func _scan_at_cursor() -> void:
	var world_pos: Vector2 = get_global_mouse_position()
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = select_radius
	var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, world_pos)
	params.collide_with_areas = false
	params.collide_with_bodies = true
	var hits: Array[Dictionary] = space.intersect_shape(params, 8)
	var best: Node2D = null
	var best_d: float = INF
	for h: Dictionary in hits:
		var c: Object = h.get("collider")
		if c is Node2D:
			var n: Node2D = c as Node2D
			var d: float = n.global_position.distance_squared_to(world_pos)
			if d < best_d:
				best_d = d
				best = n
	Signal_Bus.area_scanned.emit(best, world_pos)
