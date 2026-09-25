class_name Bee_Sprite_Handler extends Sprite2D


@onready var left_eye : Sprite2D = get_node_or_null("left_eye")
@onready var left_pupil : Sprite2D = left_eye.get_node_or_null("left_pupil")
@onready var right_eye : Sprite2D = get_node_or_null("right_eye")
@onready var right_pupil : Sprite2D = right_eye.get_node_or_null("right_pupil")

@onready var left_wing : Sprite2D = get_node_or_null("left_wing")
@onready var right_wing : Sprite2D = get_node_or_null("right_wing")

@export_group("Eye Movement")
@export var eye_movement_factor : float = 10.0
@export var eye_movement_speed : float = 10.0

@onready var eye_dir : Vector2 = Vector2.ZERO
@onready var target_eye_dir : Vector2 = Vector2.ZERO
# Sets the eye positions based on a given dir. Use set_eye_dir for a smoother change.
func update_eye_dir(dir) -> void:
	left_pupil.position = dir * eye_movement_factor
	right_pupil.position = left_pupil.position

# Sets the target eye offset in px. This is relative to the bee, and isn't immediate.
func set_eye_dir(dir : Vector2) -> void:
	target_eye_dir = dir

@export_group("Flap Animation")
@export var flap_cooldown : float = 0.15
@export var flap_spring_force : float = 1000.0
@export var flap_inverse_dampening : float = 0.8
@export var flap_strength : float = 10.0
@export var max_flap_rotation : float = 45

@export_subgroup("Random Flap Animation")
@export var min_random_flap_time : float = 1
@export var max_random_flap_time : float = 3

@onready var random_flap_timer : float = randf_range(min_random_flap_time, max_random_flap_time)
@onready var flap_timer : float = 0.0
@onready var wing_rotation : float = 0.0
@onready var wing_velocity : float = 0.0
#Just sets the velocity of the wing and the spring force is the animation
func play_flap_animation(strength : float = flap_strength) -> void:
	if flap_timer > 0 or abs(wing_rotation) >= max_flap_rotation: return
	wing_velocity += strength
	flap_timer = flap_cooldown

func update_wing_rotation(rotation : float = wing_rotation) -> void:
	left_wing.rotation = rotation
	right_wing.rotation = -rotation



## Active Functions
func _ready() -> void:
	update_eye_dir(eye_dir)

func _physics_process(dt : float) -> void:

	# Spring physics to bring the wings back to rest (this is the flap animation)
	if flap_timer > 0: flap_timer -= dt
	wing_rotation += wing_velocity * dt
	wing_velocity += -wing_rotation * dt * flap_spring_force
	wing_velocity *= flap_inverse_dampening
	update_wing_rotation(wing_rotation)

	# Random Flap animation
	if random_flap_timer > 0:
		random_flap_timer -= dt
	else:
		random_flap_timer = randf_range(min_random_flap_time, max_random_flap_time)
		play_flap_animation()

	# Interplates the eyes
	if (eye_dir - target_eye_dir).length() > 0.01:
		eye_dir = lerp(eye_dir, target_eye_dir, dt * eye_movement_speed)
		update_eye_dir(eye_dir)
	
