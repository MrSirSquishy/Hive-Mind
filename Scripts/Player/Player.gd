class_name Player extends Camera2D
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

@onready var click_area: Area2D = $Click_Area
@onready var click_shape: CircleShape2D = $Click_Area/CollisionShape2D.shape
@onready var selected_entities : Array[Entity] = []
@onready var target_pos : Vector2 = Vector2.ZERO
# Controls weather the camera should lock on to seleced entities
@onready var lock_on_selected : bool = false
# What action to preform on click
@onready var click_state : String = "SELECT"

@onready var left_down: bool = false
@onready var left_press_px: Vector2 = Vector2.ZERO

@onready var detection_area_scene : PackedScene = preload("res://Scenes/Visual_Detection_Area.tscn")

# Helper that changes zoom by amount, clamped to [min_zoom, max_zoom].
# The leading underscore is a convention meaning "private to this file".
func apply_zoom(amount: float) -> void:
	#Stores mouse pos before zoom change
	var old_mouse_pos : Vector2 = get_global_mouse_position()

	var new_zoom_val: float = clamp(zoom.x + amount, min_zoom, max_zoom)
	if is_equal_approx(new_zoom_val, zoom.x):
		return
	zoom = Vector2(new_zoom_val, new_zoom_val)

	# Zooms toward the mouse position
	position +=  old_mouse_pos - get_global_mouse_position()
	Tutorial.done("zoom")


func recenter_on_hive() -> void:
	lock_on_selected = false
	var hives : Array[Node] = get_tree().get_nodes_in_group("hive")
	var hive_pos : Vector2 = Vector2.ZERO
	if not hives.is_empty():
		var hive : Node2D = hives[0] as Node2D
		hive_pos = hive.global_position
	position = hive_pos


#this function is a forgiveness mechanic for clicking near but not directly under the cursor
func scan_at_cursor(mouse_pos: Vector2) -> void:
	var query : PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	query.shape = click_shape
	query.collision_mask = click_area.collision_mask
	query.transform = Transform2D(0.0, Vector2.ONE / zoom.x, 0.0, mouse_pos)
	var hits: Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(query)
	
	#Gets the closest body to the cursor within the selection if there are more than one
	var closest_body : PhysicsBody2D = null
	var closest_distance : float = -1
	for hit: Dictionary in hits:
		var body: Object = hit["collider"]
		if body is Entity:
			var distance: float = body.global_position.distance_squared_to(mouse_pos)
			if closest_body == null or distance < closest_distance:
				closest_body = body
				closest_distance = distance
	
	#Updates selected entity, will be null if no bodies were within click range
	if closest_body != null:
		selected_entities = [closest_body]
		Tutorial.bees_selected(selected_entities)
		
		# Opens up menu for entity/entities
		Signal_Bus.open_sub_menu.emit(selected_entities)	
	else:
		selected_entities = []
		#Closes sub menu
		Signal_Bus.close_sub_menu.emit()
	
	#If no bodies selected, then just emit the default click signal
	if closest_body == null:
		Signal_Bus.world_clicked.emit(mouse_pos)
	
	
	
## Camera Shaking

@export var cam_shake_distance_falloff : float = 4000.0
@export var cam_shake_fade_multiplier : float = 2.0

@onready var shake_strength : float = 0.0

func _trigger_cam_shake(strength : float, target_position : Vector2) -> void:
	var distance : float = (position - target_position).length()
	#Strength falls off with distance and zoom
	shake_strength = strength * zoom.x * (1 - min(distance/cam_shake_distance_falloff, 1))

func process_cam_shake(dt: float) -> void:
	# Fades out
	shake_strength = lerp(shake_strength, 0.0, cam_shake_fade_multiplier * dt)
	# Shake by adjusting camera.offset so we can move the camera around the level via it's position
	offset = Vector2(
		randf_range(-shake_strength, shake_strength),
		randf_range(-shake_strength, shake_strength)
	)





## Input Handler

func _init() -> void:
	Signal_Bus.attack_signal.connect(_attack_signal)
	Signal_Bus.defend_area_signal.connect(_defend_area_signal)
	Signal_Bus.defend_hive_signal.connect(_defend_hive_signal)
	Signal_Bus.selection_signal.connect(_selection_signal)
	
	
func _attack_signal() -> void:
	click_state = "ATTACK"
	
func _defend_area_signal() -> void:
	click_state = "GUARD_AT"

func _defend_hive_signal() -> void:
	var bees: Array[Entity] = _selected_bees()
	if bees.is_empty():
		return
	for entity: Entity in bees:
		var detection_area : Detection_Area = entity.assigned_detection_area
		entity.reset_detection_area()
		if is_instance_valid(detection_area) and not detection_area.persistent:
			detection_area.remove_if_empty()
	Tutorial.done("defend")

func _selected_bees() -> Array[Entity]:
	var bees: Array[Entity] = []
	for entity: Entity in selected_entities:
		if is_instance_valid(entity) and entity is Bee:
			bees.append(entity)
	return bees

func _selection_signal() -> void:
	click_state = "SELECT"

func _unhandled_input(event: InputEvent) -> void:
	## Dragging
	if event is InputEventMouseMotion:
		var pan_buttons: int = MOUSE_BUTTON_MASK_MIDDLE | MOUSE_BUTTON_MASK_RIGHT
		if not lock_on_selected and event.relative != Vector2.ZERO and (event.button_mask & pan_buttons) != 0:
			position -= event.relative * drag_speed / zoom.x
			Tutorial.done("pan")
	
	if event is InputEventMouseButton:
		## Scrolling
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			apply_zoom(zoom_step)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			apply_zoom(-zoom_step)
		## Mouse Click
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos: Vector2 = get_canvas_transform().affine_inverse() * event.position
			if event.pressed:
				left_down = true
				left_press_px = mouse_pos
			else:
				if not left_down:
					return
				left_down = false
				if click_state == "SELECT":
					scan_at_cursor(mouse_pos)
					# Locks on to entities if holding ctrl
					if Input.is_key_pressed(KEY_CTRL):
						lock_on_selected = true
					else:
						lock_on_selected = false
				
				elif click_state == "GUARD_AT":
					var radius: float = left_press_px.distance_to(mouse_pos)
					var bees: Array[Entity] = _selected_bees()
					if bees.is_empty() or is_zero_approx(radius):
						return
					var detection_area : Detection_Area = detection_area_scene.instantiate()
					get_tree().current_scene.add_child(detection_area)
					detection_area.init_area(left_press_px, radius, bees)
					Tutorial.done("command")

				elif click_state == "ATTACK":
					pass
				
	
	if event is InputEventKey:
		## Click State
		if event.pressed:
			if event.keycode == KEY_E:
				click_state = "SELECT"
			elif event.keycode == KEY_G:
				_defend_area_signal()
			elif event.keycode == KEY_F:
				_attack_signal()
			elif event.keycode== KEY_R: # RETURN
				_defend_hive_signal()
			elif event.keycode == KEY_H:
				recenter_on_hive()
	
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
	
	Signal_Bus.trigger_cam_shake.connect(_trigger_cam_shake)


func _process(dt: float) -> void:
	
	process_cam_shake(dt)
		
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

	
	## Cam Movement
	# * pan_speed_multiplier moves it faster if holding shift
	# /zoom.x keeps the speed relative to the cameras scale(zoomed out move faster)
	# /Engine.time_scale ignores effects of time slowdown/speedup
	var pan_speed_multiplier : float = 1
	if Input.is_key_pressed(KEY_SHIFT):
		pan_speed_multiplier = 2
	position += move_dir * pan_speed * pan_speed_multiplier * dt / zoom.x / Engine.time_scale
	if move_dir != Vector2.ZERO and not lock_on_selected:
		Tutorial.done("pan")

	## Selection
	
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
		#When the entities within the selection are freed
		if selected_entities.size() == 0:
			lock_on_selected = false
		
		#Gets the target position, if only 1 entity then this is just the entities position
		#If more than 1, it gets the average position(think center of mass)
		for entity : Entity in selected_entities:
			target_pos += entity.position
		target_pos /= selected_entities.size()
		
		if lock_on_selected:
			position = target_pos
		
		## Arrow Drawing
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
	
	if click_state == "GUARD_AT" and left_down and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var radius : float = (left_press_px - get_local_mouse_position() - position).length()
		draw_circle(left_press_px - position, radius, Color.WHITE, false, crosshairThickness/zoom.x, true)
	
	
	draw_set_transform(get_global_mouse_position() - position, 0, Vector2.ONE / zoom.x)
	#Crosshair
	draw_circle(Vector2.ZERO, crosshairRadius, Color.WHITE, false, crosshairThickness, true)

	#Draws Arrow
	draw_set_transform(get_global_mouse_position() - position, current_angle, Vector2.ONE * arrow_scale / zoom.x)
	draw_polygon(arrowDimensions, [Color.WHITE])
	
	if selected_entities.size() > 0:
		#Bounding box if more than 1
		if selected_entities.size() > 1:
			draw_set_transform(-position, 0, Vector2.ONE)
			## Generates Bounding Box
			var bounds : Rect2 = Rect2(selected_entities[0].position, Vector2.ZERO)
			var max_radius : float = 0
			for entity: Entity in selected_entities:
				bounds = bounds.expand(entity.position)
				if entity.radius > max_radius:
					max_radius = entity.radius
			
			draw_rect(bounds.grow(max_radius), Color.WHITE, false, selection_circle_radius/2)
				
		
		#Circle if just one
		else:
			var min_radius : float = selected_entities[0].radius*2
			draw_set_transform(target_pos - position, 0, Vector2.ONE)
			draw_circle(
				Vector2.ZERO, 
				max(selection_circle_radius/zoom.x, min_radius), 
				Color.WHITE, false, 
				selection_circle_thickness/zoom.x, true
			)




##User Interface Buttons taking the user to different menus
func _on_settings_button_pressed() -> void:
	Global.open_settings()

func _on_shop_button_pressed() -> void:
	Signal_Bus.hide_shop_button.emit()
	Global.open_overlay("res://Scenes/UI/shop_menu.tscn")
	Signal_Bus.toast_requested.emit("Spend your honey in the shop!", false)


#func _on_upgrade_button_pressed() -> void:
#	get_tree().change_scene_to_file("res://Scenes/UI/upgrade_menu.tscn")
#	print("Upgrade Button Pressed") #checks if button pressed

func _on_pause_button_pressed() -> void:
	Global.open_overlay("res://Scenes/UI/pause_menu.tscn")

func _on_cheats_button_pressed() -> void:
	Global.open_overlay("res://Scenes/UI/cheat_menu.tscn")
