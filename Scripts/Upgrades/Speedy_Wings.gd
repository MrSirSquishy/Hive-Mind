extends Upgrade

@export var speed_multipler : float = 2.0
@export_group("Visuals")
#Larger values increase the strength/intensity of the flap
@export var wing_flap_strength_multipler : float = 2.0
#Smaller values increase how often the wings flap
@export var wing_flap_random_multipler : float = 0.5

#This upgrade will make a copy of each wing and make them move the inverse of the bees
# normal wings, making them look faster.
@onready var left_wing_copy : Sprite2D
@onready var right_wing_copy : Sprite2D

func init():
	entity.speed *= speed_multipler
	left_wing_copy = entity.sprite_handler.left_wing.duplicate()
	entity.sprite_handler.add_child(left_wing_copy)
	right_wing_copy = entity.sprite_handler.right_wing.duplicate()
	entity.sprite_handler.add_child(right_wing_copy)
	
	entity.sprite_handler.flap_strength *= wing_flap_strength_multipler
	entity.sprite_handler.min_random_flap_time *= wing_flap_random_multipler
	entity.sprite_handler.max_random_flap_time *= wing_flap_random_multipler

func _physics_process(dt : float):
	if not left_wing_copy: return
	
	left_wing_copy.rotation = -entity.sprite_handler.left_wing.rotation
	right_wing_copy.rotation = -left_wing_copy.rotation
	
	
func exit():
	left_wing_copy.reparent(self)
	right_wing_copy.reparent(self)
	entity.speed /= speed_multipler
	
	entity.sprite_handler.flap_strength /= wing_flap_strength_multipler
	entity.sprite_handler.min_random_flap_time /= wing_flap_random_multipler
	entity.sprite_handler.max_random_flap_time /= wing_flap_random_multipler
