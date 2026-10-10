class_name GameCamera extends Camera2D
# GameCamera is an RTS-style camera for HM-9.
# Attach this script to a Camera2D node inside world.tscn.
# Controls: WASD / arrows = pan, middle- or right-mouse drag = pan,
# mouse wheel = zoom, left-click = emit SignalBus.world_clicked.

@export_group("Camera Movement")
@export var pan_speed: float = 600.0
@export var drag_speed: float = 1.0
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.1
@export var max_zoom: float = 2.5
@export var select_radius: float = 24.0
@export var click_drag_limit_px: float=8

@export_group("Drawing")
@export var crosshair_radius : float = 10.0
@export var arrow_width : float = 20
@export var arrow_height : float = 32
# How far away from the selected entity the mouse needs to be to display arrow
@export var distance_to_show_arrow : float = 300
# How big the circle around the selected entity should be
@export var selection_circle_radius : float = 100
@export var selection_circle_thickness : float = 5

@onready var arrow_angle : float  = 0.0
@onready var current_angle : float = 0.0
@onready var arrow_scale : float = 0

@onready var click_area : Area2D = get_node("Click_Area")
@onready var selected_entities : Array[Entity] = []
@onready var target_pos : Vector2 = Vector2.ZERO
@onready var lock_on_selected : bool = false

@onready var left_down: bool = false
@onready var left_press_px: Vector2 = Vector2.ZERO


# Helper that changes zoom by amount, clamped to [min_zoom, max_zoom].
# The leading underscore is a convention meaning "private to this file".
func apply_zoom(amount: float) -> void:
	#Stores mouse pos before zoom change
	var old_mouse_pos : Vector2 = get_global_mouse_position()

	var new_zoom_val: float = clamp(zoom.x + amount, min_zoom, max_zoom)
	zoom = Vector2(new_zoom_val, new_zoom_val)

	# Zooms toward the mouse position
	position +=  old_mouse_pos - get_global_mouse_position()


#this function is a forgiveness mechanic for clicking near but not directly under the cursor
func scan_at_cursor() -> void:
	#gets all the bodies within a margin of the cursor
	var bodies : Array[Node2D] = click_area.get_overlapping_bodies()
	var mouse_pos : Vector2 = get_global_mouse_position()
	
	#Gets the closest body to the cursor within the selection if there are more than one
	var closest_body : PhysicsBody2D = null
	var closest_distance : float = -1
	for body : PhysicsBody2D in bodies:
		if body is Entity:
			var distance : float = (body.position - mouse_pos).length()
			if closest_body == null or distance < closest_distance:
				closest_body = body
	
	#Updates selected entity, will be null if no bodies were within click range
	if closest_body != null:
		selected_entities = [closest_body]
	else:
		selected_entities = []
	
	#If no bodies selected, then just emit the default click signal
	if closest_body == null:
		Signal_Bus.world_clicked.emit(mouse_pos)
	


## Input Handler
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var middle_held: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
		var right_held: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		if middle_held or right_held:
			position -= event.relative * drag_speed / zoom.x
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			apply_zoom(zoom_step)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			apply_zoom(-zoom_step)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				left_down = true
				left_press_px = event.position
			else:
				if not left_down:
					return
				left_down = false
				scan_at_cursor()


## Active Functions

# _ready runs ONCE when this node enters the scene tree.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	# If several cameras exist, this one becomes the active view.
	make_current()
	# Smooth out position changes so panning glides instead of snapping.
	position_smoothing_enabled = false
	# Higher number = catches up faster. 8 is a calm RTS feel.
	position_smoothing_speed = 8.0


func _process(dt: float) -> void:
		
	#Adjusts the position and scale of the click area to the camera and mouse
	click_area.position = get_local_mouse_position()
	click_area.scale = Vector2.ONE * clamp(0.01 , 1 / zoom.x, 10000)
	
	# Start with no movement; we add direction below based on keys held.
	var move_dir : Vector2 = Vector2.ZERO
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

	# Move the camera. Multiply by dt so speed is pixels-per-second,
	# not pixels-per-frame. Divide by zoom so panning feels the same
	# whether zoomed in (zoom 2.0) or out (zoom 0.5).
	position += move_dir * pan_speed * dt / zoom.x

	## Drawing
	
	# Scales and directs the display arrow
	var target_scale : float = 0.0
	target_pos = Vector2.ZERO
	if selected_entities.size() > 0:
		
		#Removes any invalid entities from array(for example ones that have been freed)
		@warning_ignore("untyped_declaration")
		selected_entities = selected_entities.filter(
			func(entity) -> bool: 
				return is_instance_valid(entity)
		)
		#Gets the target position, if only 1 entity then this is just the entities position
		#If more than 1, it gets the average position(think center of mass)
		for entity : Entity in selected_entities:
			target_pos += entity.position
		target_pos /= selected_entities.size()
		
		var dif : Vector2 = get_global_mouse_position() - target_pos
		if dif.length() > distance_to_show_arrow:
			#we only need to update the rotation if the arrow should be visible
			arrow_angle = atan2(dif.y, dif.x) - PI/2
			current_angle = lerp_angle(current_angle, arrow_angle,  min(dt*30, 1.0))
			target_scale = 1

	arrow_scale = lerp(arrow_scale, target_scale, min(dt*10, 1))

	queue_redraw()



## Draws certain visuals

@onready var arrowDimensions : Array[Vector2] = [
	Vector2(-arrow_width*0.5, -crosshair_radius - arrow_height*0.25), 
	Vector2(0, -arrow_height), 
	Vector2(arrow_width*0.5, -crosshair_radius - arrow_height*0.25), 
	Vector2(0, -arrow_height*0.66)
]

@export var crosshairRadius : float = 8.0
@export var crosshairThickness : float = 4.0

func _draw() -> void:
	draw_set_transform(get_global_mouse_position() - position, 0, Vector2.ONE / zoom.x)
	draw_circle(Vector2.ZERO, crosshairRadius, Color.WHITE, false, crosshairThickness, true)

	#Draws Arrow
	draw_set_transform(get_global_mouse_position() - position, current_angle, Vector2.ONE * arrow_scale / zoom.x)
	draw_polygon(arrowDimensions, [Color.WHITE])
	
	if selected_entities.size() > 0:
		draw_set_transform(target_pos - position, 0, Vector2.ONE)
		draw_circle(
			Vector2.ZERO, 
			selection_circle_radius/zoom.x, 
			Color.WHITE, false, 
			selection_circle_thickness/zoom.x, true
		)




##User Interface Buttons taking the user to different menus
func _on_tutorial_button_pressed() -> void:
	#get_tree().change_scene_to_file("")
	print("Point to Tutorial") #checks if button pressed

func _on_settings_button_pressed() -> void:
	#get_tree().change_scene_to_file("")
	print("Point to Settings") #checks if button pressed

func _on_shop_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/shop_menu.tscn")
	print("Shop Button Pressed") #checks if button pressed

func _on_upgrade_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/Upgrade Menu/upgrade_menu.tscn")
	print("Upgrade Button Pressed") #checks if button pressed

func _on_pause_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/pause_menu.tscn")
	print("Pause Menu Pressed") #checks if button pressed

func _on_cheats_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/cheat_menu.tscn")
	print("Cheats Pressed") #checks if button pressed
