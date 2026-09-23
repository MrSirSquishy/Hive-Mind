class_name Bee_Sprite_Handler extends Sprite2D

#Bees vary with upgrades, this should provide a unified interface
#for the bee object to interact with when dealing with sprites.
#for example seperated body, wing, eye, etc. sprites

@onready var left_eye : Sprite2D = get_node_or_null("left_eye")
@onready var left_pupil : Sprite2D = left_eye.get_node_or_null("left_pupil")
@onready var right_eye : Sprite2D = get_node_or_null("right_eye")
@onready var right_pupil : Sprite2D = right_eye.get_node_or_null("right_pupil")

@onready var left_wing : Sprite2D = get_node_or_null("left_wing")
@onready var right_wing : Sprite2D = get_node_or_null("right_wing")

@export var eye_movement_factor : float = 10.0
@export var eye_movement_speed : float = 10.0

@onready var eye_dir : Vector2 = Vector2.ZERO
@onready var target_eye_dir : Vector2 = Vector2.ZERO

func _physics_process(dt : float) -> void:
	eye_dir = lerp(eye_dir, target_eye_dir, dt * eye_movement_speed)
	
	left_pupil.position = eye_dir * eye_movement_factor
	right_pupil.position = left_pupil.position

func set_eye_dir(dir : Vector2) -> void:
	target_eye_dir = dir
