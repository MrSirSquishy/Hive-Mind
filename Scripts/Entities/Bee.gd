class_name Bee extends Entity

@export var sprite_handler : Bee_Sprite_Handler

@export var turn_speed : float = 50000000.0

@export_group("Bee AI")
#How close it should be to the target_position to be considered reached
@export var target_margin : float = 200
#How close it should be to the target_position to begin slowing down
@export var target_slowdown_margin : float = 500
#The Area2D that defines what the bee is aware of/can see
@export var awareness_area : Area2D

#State Machine
enum states {
	IDLE,
	MOVING
}
@onready var state : states	= states.IDLE

@onready var target_position : Vector2 

func _ready() -> void:
	target_position = position
	

func _physics_process(dt : float) -> void:
	
	if state == states.IDLE:
		#State Changing
		if (position - target_position).length() > target_margin:
			state = states.MOVING
	
	elif state == states.MOVING:
		## Moves toward target position
		var dif : Vector2 = position - target_position
		#Reduces the force applied as it approaches within the slowdown margin
		var force_scale : float = clamp(0,  dif.length()/target_slowdown_margin, 1)
		apply_force(-dif.normalized() * speed * force_scale)

		## Turns to face direction of where it wants to go
		var angleDif : float = wrapf(rotation - (-dif).angle() - PI/2, -PI, PI)
		apply_torque(-clamp(angleDif, -1, 1)*dt * turn_speed)
		
		## Avoidance of other bees (not active)
		#var nearby_entities : Array[Node2D] = awareness_area.get_overlapping_bodies()
		#for entity in nearby_entities:
			#if entity != self and entity is Bee:
				#var dif_to_bee : Vector2 = position - entity.position
				##apply_force(dif_to_bee * 5)
		
		## Sprite update
		#the eye dir is relative, so we need to rotate the dif to be accuraet
		sprite_handler.set_eye_dir(
			-dif.normalized().rotated(-rotation)
		)
		
		# State Changing
		if dif.length() < target_margin:
			state = states.IDLE
		
		

func _process(_dt: float) -> void:
	pass


## Signals
func _enter_tree() -> void:
	Signal_Bus.world_clicked.connect(set_target_position)

func set_target_position(new_target_position : Vector2) -> void:
	target_position = new_target_position
