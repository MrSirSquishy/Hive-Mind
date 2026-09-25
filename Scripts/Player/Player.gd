class_name GameCamera extends Camera2D
# GameCamera is an RTS-style camera for HM-9.
# Attach this script to a Camera2D node inside world.tscn.
# Controls: WASD / arrows = pan, middle- or right-mouse drag = pan,
# mouse wheel = zoom, left-click = emit SignalBus.world_clicked.

@export_group("Camera Movement")
@export var pan_speed: float = 600.0
@export var drag_speed: float = 1.0
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.2
@export var max_zoom: float = 2.5
@export var select_radius: float = 24.0
@export var click_drag_limit_px: float=8

@onready var click_area : Area2D = get_node("Click_Area")
@onready var selected_entity : Entity = null

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


func _process(delta: float) -> void:
		
	#Adjusts the position and scale of the click area to the camera and mouse
	click_area.position = get_global_mouse_position()
	click_area.scale = Vector2.ONE * clamp(0.01 , 1 / zoom.x, 10000)
	
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

#this feature is a forgiveness mechanic for clicking near but not directly under the cursor
func _scan_at_cursor() -> void:
	#gets all the bodies within a margin of the cursor
	var bodies : Array[Node2D] = click_area.get_overlapping_bodies()
	var mouse_pos : Vector2 = get_global_mouse_position()
	
	#Gets the closest body to the cursor within the selection if there are more than one
	var closest_body : PhysicsBody2D
	var closest_distance : float = -1
	for body : PhysicsBody2D in bodies:
		if body is Entity:
			var distance : float = (body.position - mouse_pos).length()
			if closest_body == null or distance < closest_distance:
				closest_body = body
	
	#Updates selected_entity, will be null if no bodies were within click range
	selected_entity = closest_body
	
	#If no bodies selected, then just emit the default click signal
	if closest_body == null:
		Signal_Bus.world_clicked.emit(mouse_pos)
	
