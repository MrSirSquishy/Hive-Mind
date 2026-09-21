class_name Bee extends Entity

@export var sprite_handler : Bee_Sprite_Handler

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
	super._physics_process(dt)
	
	if state == states.IDLE:
		if (position - target_position).length() > target_margin:
			state = states.MOVING
	
	elif state == states.MOVING:
		var dif = position - target_position
		position += -dif.normalized() * speed
		
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
