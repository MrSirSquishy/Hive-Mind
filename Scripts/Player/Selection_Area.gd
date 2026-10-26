extends Area2D

## The minimum distance between polygon points
## Lower values more precise but more intensive
@export var polygon_seg_margin : float = 50

@export_group("Time Slowdown")
## How much the time_scale will be divided/multiplied while selection held
@export var time_slowdown_multiplier : float = 5
## How long it takes to tween the time
@export var time_slowdown_transition_time : float = 0.5


@onready var collision_polygon : CollisionPolygon2D = get_child(0)
@onready var polygon : PackedVector2Array = []

func _ready() -> void:
	monitoring = false


func start_selection() -> void:
	monitoring = true
	Engine.time_scale /= time_slowdown_multiplier

func finish_selection() -> void:
	var selection : Array[Entity]
	for entity : PhysicsBody2D in get_overlapping_bodies():
		#Only selects bees
		if entity is Entity and entity.team == "BEE":
			selection.append(entity)
			#Makes all entities play a short flash, should prob be replaced with smthn better
			var tween : Tween = get_tree().create_tween()
			tween.tween_property(entity, "modulate", entity.modulate + Color.WHITE*4, 0.1)
			tween.tween_property(entity, "modulate", entity.modulate, 0.2)
	
	#Make sure not to override selection if there is none selected
	#Otherwise this breaks normal clicking on things
	if selection.size() > 0:
		var player : Player = get_parent()
		#we await so the player doesn't immediately clear selection on mouse click up
		await get_tree().physics_frame
		player.selected_entities = selection
		
	## Resets things
	monitoring = false
	polygon = []
	collision_polygon.set_polygon(polygon)
	Engine.time_scale *= time_slowdown_multiplier

func _process(_dt : float) -> void:
	if monitoring: 
		# Initiates selection polygon if it's empty
		var mouse_pos : Vector2 = get_local_mouse_position()
		if polygon.size() == 0:
			polygon = [mouse_pos]
			
		#Adds segment to the polygon as the user drags around the screen
		var dif : Vector2 = polygon[polygon.size() - 1] - mouse_pos
		if dif.length() > polygon_seg_margin:
			polygon.append(mouse_pos)

		collision_polygon.set_polygon(polygon)
	
	queue_redraw()

func _draw() -> void:
	if polygon.size() == 0: return
	#Closes loop
	var polyline : PackedVector2Array = polygon.duplicate()
	polyline.append(polyline[0])
	#Draws
	draw_polyline(polyline, Color.WHITE, 16.0, true)
		
	
func _unhandled_input(event: InputEvent) -> void:
	#Doesn't trigger anything if not in the selection state
	if get_parent().click_state != "SELECT": return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				start_selection()
			if event.is_released():
				finish_selection()
