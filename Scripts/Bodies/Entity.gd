@abstract class_name Entity extends Body
## Made as parent for Bee and Enemy classes

@export_group("Movement")
##The strength of the force when moving
@export var speed : float = 10000.0
##The strength of the torque when rotating
@export var turn_speed : float = 50000000.0
#The maximum angle before the entity can move toward target
@export var angle_dif_before_moving : float = PI/2

@export_group("AI")
##When it has no other target position, it will go to the hive.
##This defines the radius that would be considered near enough to the hive
@export var default_hive_radius : float = 800
##How close it should be to the target_position to be considered reached
@export var target_margin : float = 200
##How close it should be to the final target_position to begin slowing down
@export var target_slowdown_margin : float = 2000
##How close it should be to a non-final target_position(points on the path to target) before slowing down
@export var sub_target_slowdown_margin : float = 500
##The interval before the entity rechecks it's navigation path in seconds
@export var navigation_cooldown : float = 1
@onready var navigation_timer : float = navigation_cooldown

@export_group("Combat")
##How close to be to the target entity before attacking(note it takes into account the radius of each entity)
@export var attack_distance : float = 50
@export var attack_damage : float = 1.0
@export var attack_i_frames : float = 0.2

@onready var sprite_handler : Sprite_Handler = get_node("Sprite")
@onready var animations : AnimationPlayer = get_node_or_null("Animations")
##The Area2D that defines what the bee is aware of/can see
@onready var awareness_area : Area2D = get_node_or_null("Awareness_Area")
@onready var attack_box : Area2D = get_node_or_null("Attack_Box")
@onready var raycast : RayCast2D = get_node_or_null("RayCast2D")

#First element is target position, others are points on the nav path to the target
@onready var target_positions : Array[Vector2] = [position]
@onready var target_body : Body
#Entity will prioritize attacking these bodies before doing anything else
@onready var attack_bodies : Array[Body]

@onready var assigned_detection_area : Detection_Area

@onready var upgrades : Dictionary = {
	"HEAD" : null,
	"BODY" : null,
	"EQUIPMENT" : null
}

## Functions

func get_target_body_from_array(body_array : Array[Node2D], nearest_to_position : Vector2 = position) -> bool:
	# Finds enemy bodies within it's awareness area, targets closest one
	var new_target : Body = null
	for entity : PhysicsBody2D in body_array:
		if entity is Body and entity.team != team:
			#Sets the target body if it is null, or if the new target body is closer
			if not new_target or (new_target.position - nearest_to_position).length() > (entity.position - nearest_to_position).length():
				new_target = entity
		
	target_body = new_target
	return not (new_target == null)

## Frees itself from the current detection area before assigning itself to the new one
func set_detection_area(new_detection_area : Detection_Area) -> void:
	if assigned_detection_area is Detection_Area:
		assigned_detection_area.linked_entities.erase(self)
	
	assigned_detection_area = new_detection_area
	assigned_detection_area.linked_entities.append(self)

## Resets back to the default detection area, in this case none.(for bees it is hive)
func reset_detection_area() -> void:
	if assigned_detection_area is Detection_Area:
		assigned_detection_area.linked_entities.erase(self)
	assigned_detection_area = null

### Active Functions
func _ready() -> void:
	#Initial detection area
	reset_detection_area()
	
	#Initializes Upgrades
	#doesn't check for duplicates, so only last one of same type is stored
	var child_upgrades : Array[Node] = find_children("", "Upgrade")
	for upgrade : Upgrade in child_upgrades:
		upgrades[upgrade.upgrade_type] = upgrade
		upgrade.init(self)

func _physics_process(dt : float) -> void:
	
	update_i_frames(dt)
	
	# Runs upgrades
	for upgrade_type : String in upgrades:
		var upgrade : Upgrade = upgrades[upgrade_type]
		if upgrade and upgrade.has_method("physics_process_upgrade"):
			upgrade.physics_process_upgrade(self, dt)
	
	
	## Moves to Target
	var dif : Vector2 = position - target_positions[target_positions.size() - 1]
	if dif.length() > target_margin: 
		# Reduces the force applied as it approaches within the slowdown margin
		# Less range if it's not the final target
		var slowdown_margin : float = target_slowdown_margin
		if target_positions.size() > 1:
			slowdown_margin = sub_target_slowdown_margin
		var force_scale : float = clamp(0,  dif.length()/slowdown_margin, 1)

		# The difference between the angle to the target_position and the current angle
		var angleDif : float = wrapf(rotation - (-dif).angle() - PI/2, -PI, PI)
		if angleDif < angle_dif_before_moving:
			# Reduces the force when the bee is not facing the target_position
			force_scale *= clamp(0.5, 1 - abs(angleDif), 1)
			var force : Vector2 = -dif.normalized() * speed * force_scale
			apply_force(force)

		## Turns to face direction of where it wants to go
		apply_torque(-clamp(angleDif, -1, 1) * dt * turn_speed)
		
		#Flaps wings when moving
		sprite_handler.play_flap_animation()
	else:
		if target_positions.size() > 1:
			target_positions.pop_back()
	
	## Entity Avoidance
	if raycast:
		raycast.target_position = dif.rotated(PI - rotation)
		if raycast.is_colliding():
			var hit_object : PhysicsBody2D = raycast.get_collider()
			if hit_object is Body and hit_object != target_body:
				var safe_radius_from_entity : float = radius + hit_object.radius
				#Sets a a new nav point to the side of the entity in the way(randomly chooses left or right)
				var perpendicular_dir : Vector2 = (dif.normalized().rotated(90 * ((randi() & 2) - 1)))
				target_positions.push_back(
					hit_object.position + perpendicular_dir * safe_radius_from_entity
				)

	#Attack it's priotized targets above all else
	if attack_bodies.size() > 0:
		#Removes any invalid entities from array(for example ones that have been freed)
		@warning_ignore("untyped_declaration")
		attack_bodies = attack_bodies.filter(
			func(entity) -> bool: 
				return is_instance_valid(entity)
		)
		var attack_bodies_recast : Array[Node2D]
		attack_bodies_recast.assign(attack_bodies)
		get_target_body_from_array(attack_bodies_recast)
	else:
		var scan_near : bool = true
		if assigned_detection_area: #priortizes assigned detection area
			#if something is found, scan_near set to false
			scan_near = not get_target_body_from_array(assigned_detection_area.get_overlapping_bodies(), assigned_detection_area.position)	
		else:
			#If no detection area, reset to the default detection area
			reset_detection_area()
		
		if scan_near: #Don't need to scan if already found in detection area
			get_target_body_from_array(awareness_area.get_overlapping_bodies())
		
	var current_target_position : Vector2
	if target_body:
		current_target_position = target_body.position
	elif assigned_detection_area:
		#Sets the current target to the edge the assigned_detection_area
		var dir_to_area : Vector2 = (position - assigned_detection_area.position).normalized()
		current_target_position = assigned_detection_area.position + dir_to_area * assigned_detection_area.inner_radius
		
		##The target circle is defined at pos default_target_position with the respective radius
		#var dir_to_default : Vector2 = (position - default_target_position).normalized()
		#current_target_position = default_target_position + dir_to_default * default_target_radius
	#
	#Updates Navigation timer
	if navigation_timer > 0:
		navigation_timer -= dt
		target_positions[0] = current_target_position
	else:
		navigation_timer = navigation_cooldown
		#resets the pathfinding
		target_positions = [current_target_position]
	
	
	if target_body: #if target_body exists
		dif = position - target_positions[0]

		#Attacks when in range
		if dif.length() - radius - target_body.radius <= attack_distance:
			if animations and animations.has_animation("Attack"):
				animations.play("Attack")
		
		if attack_box:
			for body : PhysicsBody2D in attack_box.get_overlapping_bodies():
				if body is Body and body.team != team:
					# damages the body, returns weather or not the hit landed
					if body.damage(attack_damage, self.to_string(), attack_i_frames):
						#triggers cam shake if hit landed
						Signal_Bus.trigger_cam_shake.emit(20, position)
	
		## Updates eye look direction
		#the eye dir is relative, so we need to rotate the dif to be accurate
		sprite_handler.set_eye_dir(
			-dif.normalized().rotated(-rotation)
		)


### Debug Drawing
	#queue_redraw()
#
#func _draw() -> void:
	#var polyline : Array[Vector2] = target_positions.duplicate()
	#polyline.push_back(position)
	#if polyline.size() > 1:
		#draw_set_transform_matrix(global_transform.affine_inverse())
		#draw_polyline(target_positions, Color.AQUA)
