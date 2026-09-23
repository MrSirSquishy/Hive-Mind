class_name Bee extends Entity

@export var sprite_handler : Bee_Sprite_Handler

@export var turn_speed : float = 5000000.0

@export_group("Bee AI")

#How close it should be to the target_position to be considered reached
@export var target_margin : float = 100.0

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
		# Moves toward target position
		var dif : Vector2 = position - target_position
		apply_force(-dif.normalized() * speed)

		# Turns to face direction of it's velocity
		var angleDif : float = wrapf(rotation - (linear_velocity).angle() - PI/2, -PI, PI)
		apply_torque(-clamp(angleDif, -1, 1)*dt * turn_speed)
		
		# State Changing
		if dif.length() < target_margin:
			state = states.IDLE
		
		

func _process(dt: float) -> void:
	pass




func upgrade() -> void:
	pass

#DEBUG
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		target_position = get_global_mouse_position()
