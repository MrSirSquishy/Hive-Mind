class_name Bee_Sprite_Handler extends Sprite_Handler

@onready var left_wing : Sprite2D = get_node_or_null("left_wing")
@onready var right_wing : Sprite2D = get_node_or_null("right_wing")

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
## Just sets the velocity of the wing and the spring force is the animation
func play_flap_animation(strength : float = flap_strength) -> Bee_Sprite_Handler:
	if flap_timer > 0 or abs(wing_rotation) >= max_flap_rotation: return
	wing_velocity += strength
	flap_timer = flap_cooldown
	return self

func update_wing_rotation(new_rotation : float = wing_rotation) -> Bee_Sprite_Handler:
	left_wing.rotation = new_rotation
	right_wing.rotation = -new_rotation
	return self


## Active Functions

func _physics_process(dt : float) -> void:
	super._physics_process(dt)

	# Spring physics to bring the wings back to rest (this is the flap animation)
	if flap_timer > 0: flap_timer -= dt
	wing_rotation += wing_velocity * dt
	wing_velocity += -wing_rotation * dt * flap_spring_force
	wing_velocity *= flap_inverse_dampening
	wing_velocity = clamp(-20, wing_velocity, 20)
	update_wing_rotation(wing_rotation)

	# Random Flap animation
	if random_flap_timer > 0:
		random_flap_timer -= dt
	else:
		random_flap_timer = randf_range(min_random_flap_time, max_random_flap_time)
		play_flap_animation()
