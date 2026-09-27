class_name Bee extends Entity

@onready var sprite_handler : Bee_Sprite_Handler = get_node("Sprite")


func _ready() -> void:
	#Initializes Upgrades
	#doesn't check for duplicates, so only last one of same type is stored
	var child_upgrades : Array[Node] = find_children("", "Upgrade")
	for upgrade : Upgrade in child_upgrades:
		upgrades[upgrade.upgrade_type] = upgrade
		upgrade.init()
	

func _physics_process(dt : float) -> void:
	
	if state == "IDLE":
		#State Changing
		if (position - target_position).length() > target_margin:
			state = "MOVING"
	
	elif state == "MOVING":
		## Moves toward target position
		var dif : Vector2 = position - target_position
		#Reduces the force applied as it approaches within the slowdown margin
		var force_scale : float = clamp(0,  dif.length()/target_slowdown_margin, 1)

		# The difference between the angle to the target and the current angle
		var angleDif : float = wrapf(rotation - (-dif).angle() - PI/2, -PI, PI)
		
		# Reduces the force when the bee is not facing the target
		force_scale *= clamp(0.5, 1 - abs(angleDif), 1)
		
		apply_force(-dif.normalized() * speed * force_scale)

		## Turns to face direction of where it wants to go
		apply_torque(-clamp(angleDif, -1, 1)*dt * turn_speed)
		
		
		## Sprite update
		#the eye dir is relative, so we need to rotate the dif to be accurate
		sprite_handler.set_eye_dir(
			-dif.normalized().rotated(-rotation)
		)
		sprite_handler.play_flap_animation()
		
		# State Changing
		if dif.length() < target_margin:
			state = "IDLE"
		
		

func _process(_dt: float) -> void:
	pass


## Signals
func _init() -> void:
	Signal_Bus.world_clicked.connect(set_target_position)

func set_target_position(new_target_position : Vector2) -> void:
	target_position = new_target_position
