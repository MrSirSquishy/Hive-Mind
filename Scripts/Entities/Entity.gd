@abstract class_name Entity extends RigidBody2D
## Made as parent for Bee and Enemy classes

##Default Bee has 10.0 health for refernce
@export var health : float = 10.0

##This determines the approximate "size" (in px) of the entity for things like distance and closeness calculations. Default Bee 150 px for reference
@export var radius : float = 150

##The team this entity is a part of, for example, "BEES" or "ENEMIES" Entities will attack non-team members
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
func damage(damage : float, source_identifier : String, i_frames : float) -> void:
	#checks if the i frames for the source are up, it not, no damage
	for source in i_frame_dictionary:
		if source == source_identifier:
			return
	#If not found, then continue with the attack and add start the i_frames
	i_frame_dictionary.set(source_identifier, i_frames)
	
	#Plays a flash to indicate getting hit
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WHITE * 3, 0.05)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	#The actual damage dealing
	health -= damage
	if health <= 0:
		kill()
		return
	

signal died
func kill():
	died.emit()
	queue_free()
		

## Moves to target_position if outside of it's margin
func move_to_target(target : Vector2, dt : float):
	var dif : Vector2 = position - target
	if dif.length() > target_margin: 
		#Reduces the force applied as it approaches within the slowdown margin
		var force_scale : float = clamp(0,  dif.length()/target_slowdown_margin, 1)

		# The difference between the angle to the target and the current angle
		var angleDif : float = wrapf(rotation - (-dif).angle() - PI/2, -PI, PI)
		# Reduces the force when the bee is not facing the target
		force_scale *= clamp(0.5, 1 - abs(angleDif), 1)
		var force : Vector2 = -dif.normalized() * speed * force_scale
		apply_force(force)

		## Turns to face direction of where it wants to go
		apply_torque(-clamp(angleDif, -1, 1)*dt * turn_speed)
		
		#Flaps wings when moving
		sprite_handler.play_flap_animation()


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
	for source in i_frame_dictionary:
		i_frame_dictionary[source] -= dt
		# removes the i_frames if it's up
		if i_frame_dictionary[source] <= 0:
			i_frame_dictionary.erase(source)
	
	# Runs upgrades
	for upgrade_type : String in upgrades:
		var upgrade : Upgrade = upgrades[upgrade_type]
		if upgrade and upgrade.has_method("physics_process_upgrade"):
			upgrade.physics_process_upgrade(self, dt)
	
	move_to_target(target_position, dt)
	
	# Finds enemy entities within it's awareness area, targets closest one
	var target_entity : Entity = null
	for entity : PhysicsBody2D in awareness_area.get_overlapping_bodies():
		if entity is Entity and entity.team != team:
			if not target_entity or (target_entity.position - position).length() > (entity.position - position).length():
				target_entity = entity
	
	
	if target_entity:
		target_position = target_entity.position
		var dif : Vector2 = position - target_position

		#Attacks when in range
		if dif.length() - radius - target_entity.radius <= attack_distance:
			if animations and animations.has_animation("Attack"):
				animations.play("Attack")
		
		if attack_box:
			for entity : PhysicsBody2D in attack_box.get_overlapping_bodies():
				if entity is Entity and entity.team != team:
					entity.damage(attack_damage, self.to_string(), attack_i_frames)
		
	
		## Updates eye look direction
		#the eye dir is relative, so we need to rotate the dif to be accurate
		
		sprite_handler.set_eye_dir(
			-dif.normalized().rotated(-rotation)
		)
	
	


## Signals

func _init() -> void:
	Signal_Bus.world_clicked.connect(set_target_position)

func set_target_position(new_target_position : Vector2) -> void:
	target_position = new_target_position
