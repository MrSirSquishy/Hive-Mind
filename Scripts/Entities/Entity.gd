@abstract class_name Entity extends RigidBody2D
## Made as parent for Bee and Enemy classes

##Default Bee has 10.0 health for refernce
@export var health : float = 10.0

##This determines the approximate "size" (in px) of the entity for things like distance and closeness calculations. Default Bee 150 px for reference
@export var radius : float = 150

##The team this entity is a part of, for example, "BEE" or "ENEMY" Entities will attack non-team members
@export var team : String = "NONE"

@export_group("Movement")
##The strength of the force when moving
@export var speed : float = 10000.0
##The strength of the torque when rotating
@export var turn_speed : float = 50000000.0

@export_group("AI")
##How close it should be to the target_position to be considered reached
@export var target_margin : float = 200
##How close it should be to the target_position to begin slowing down
@export var target_slowdown_margin : float = 2000

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

@onready var target_position : Vector2 = position
@onready var i_frame_dictionary : Dictionary[String, float] = {}

@onready var upgrades : Dictionary = {
	"HEAD" : null,
	"BODY" : null,
	"EQUIPMENT" : null
}

## Functions

## inflicts damage on the entity.
## [br]
## source_identifier and i_frames are to specify the local i_frames for an 
## entity or attack, defined by source_identifier. If the i_frames for the
## source_identifier aren't up, the entity does not take damage.
## [br]
## Returns weather or not the attack managed to hit
func damage(damage_amount : float, source_identifier : String, i_frames : float) -> bool:
	#checks if the i frames for the source are up, it not, no damage
	for source : String in i_frame_dictionary:
		if source == source_identifier:
			return false
	#If not found, then continue with the attack and add start the i_frames
	i_frame_dictionary.set(source_identifier, i_frames)
	
	#Plays a flash to indicate getting hit
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WHITE * 3, 0.05)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	#The actual damage dealing
	health -= damage_amount
	if health <= 0:
		kill()
	
	return true
	

signal died
func kill() -> void:
	died.emit()
	queue_free()
		


### Active Functions

func _ready() -> void:
	#Initializes Upgrades
	#doesn't check for duplicates, so only last one of same type is stored
	var child_upgrades : Array[Node] = find_children("", "Upgrade")
	for upgrade : Upgrade in child_upgrades:
		upgrades[upgrade.upgrade_type] = upgrade
		upgrade.init(self)

func _physics_process(dt : float) -> void:
	
	# Updates all sets of i_frames:
	for source : String in i_frame_dictionary.keys():
		i_frame_dictionary[source] -= dt
		# removes the i_frames if it's up
		if i_frame_dictionary[source] <= 0:
			i_frame_dictionary.erase(source)
	
	# Runs upgrades
	for upgrade_type : String in upgrades:
		var upgrade : Upgrade = upgrades[upgrade_type]
		if upgrade and upgrade.has_method("physics_process_upgrade"):
			upgrade.physics_process_upgrade(self, dt)
	
	
	# Moves to Target
	var dif : Vector2 = position - target_position
	if dif.length() > target_margin: 
		#Reduces the force applied as it approaches within the slowdown margin
		var force_scale : float = clamp(0,  dif.length()/target_slowdown_margin, 1)

		# The difference between the angle to the target_position and the current angle
		var angleDif : float = wrapf(rotation - (-dif).angle() - PI/2, -PI, PI)
		# Reduces the force when the bee is not facing the target_position
		force_scale *= clamp(0.5, 1 - abs(angleDif), 1)
		var force : Vector2 = -dif.normalized() * speed * force_scale
		apply_force(force)

		## Turns to face direction of where it wants to go
		apply_torque(-clamp(angleDif, -1, 1) * dt * turn_speed)
		
		#Flaps wings when moving
		sprite_handler.play_flap_animation()
	
	
	
	# Finds enemy entities within it's awareness area, targets closest one
	var target_entity : PhysicsBody2D = null
	for entity : PhysicsBody2D in awareness_area.get_overlapping_bodies():
		if entity is Entity and entity.team != team:
			if not target_entity or (target_entity.position - position).length() > (entity.position - position).length():
				target_entity = entity
	
	
	if target_entity:
		target_position = target_entity.position
		dif = position - target_position

		#Attacks when in range
		if dif.length() - radius - target_entity.radius <= attack_distance:
			if animations and animations.has_animation("Attack"):
				animations.play("Attack")
		
		if attack_box:
			for body : PhysicsBody2D in attack_box.get_overlapping_bodies():
				if body is Entity and body.team != team:
					if body.damage(attack_damage, self.to_string(), attack_i_frames):
						Signal_Bus.trigger_cam_shake.emit(20, position)
				elif body is Hive and body.team != team:
					body.damage(attack_damage, self.to_string(), attack_i_frames)
	
		## Updates eye look direction
		#the eye dir is relative, so we need to rotate the dif to be accurate
		
		sprite_handler.set_eye_dir(
			-dif.normalized().rotated(-rotation)
		)
	
	


## Signals

func is_hostile(body: PhysicsBody2D) -> bool:
	if body is Entity:
		return body.team != team
	if body is Hive:
		return body.team != team
	return false
