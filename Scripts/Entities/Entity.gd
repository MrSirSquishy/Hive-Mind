## Made as parent for Bee and Enemy classes
@abstract class_name Entity extends RigidBody2D


@onready var sprite_handler : Sprite_Handler = get_node("Sprite")

##Default Bee has 10.0 health for refernce
@export var health : float = 10.0

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
##The Area2D that defines what the bee is aware of/can see
@export var awareness_area : Area2D = get_node_or_null("Awareness_Area")


@onready var target_position : Vector2 = position

@onready var upgrades : Dictionary = {
	"HEAD" : null,
	"BODY" : null,
	"EQUIPMENT" : null
}


## Functions

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
	
	## Updates eye look direction
	#the eye dir is relative, so we need to rotate the dif to be accurate
	var dif : Vector2 = position - target_position
	sprite_handler.set_eye_dir(
		-dif.normalized().rotated(-rotation)
	)
	
	


## Signals

func _init() -> void:
	Signal_Bus.world_clicked.connect(set_target_position)

func set_target_position(new_target_position : Vector2) -> void:
	target_position = new_target_position
