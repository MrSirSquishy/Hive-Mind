extends Upgrade

@export var speed_multipler : float = 2.0
@export_group("Visuals")
#How many px offset the secondary wings are
@export var wing_offset : Vector2 = Vector2(20, 40)
#Larger values increase the strength/intensity of the flap
@export var wing_flap_strength_multipler : float = 2.0
#Smaller values increase how often the wings flap
@export var wing_flap_random_multipler : float = 0.5

#This upgrade will make a copy of each wing and make them move the inverse of the bees
# normal wings, making them look faster.
@onready var left_wing_copy : Sprite2D
@onready var right_wing_copy : Sprite2D

func init(entity : Entity) -> void:
	var sprite : Sprite_Handler = entity.sprite_handler
	entity.speed *= speed_multipler
	left_wing_copy = sprite.left_wing.duplicate()
	sprite.add_child(left_wing_copy)
	right_wing_copy = sprite.right_wing.duplicate()
	sprite.add_child(right_wing_copy)
	left_wing_copy.position += wing_offset
	right_wing_copy.position += Vector2(-wing_offset.x, wing_offset.y)
	
	sprite.flap_strength *= wing_flap_strength_multipler
	sprite.min_random_flap_time *= wing_flap_random_multipler
	sprite.max_random_flap_time *= wing_flap_random_multipler

func physics_process_upgrade(entity : Entity, _dt : float) -> void:
	if not left_wing_copy: return
	
	left_wing_copy.rotation = -entity.sprite_handler.left_wing.rotation
	right_wing_copy.rotation = -left_wing_copy.rotation
	
	
func exit(entity : Entity) -> void:
	left_wing_copy.reparent(self)
	right_wing_copy.reparent(self)
	entity.speed /= speed_multipler
	
	entity.sprite_handler.flap_strength /= wing_flap_strength_multipler
	entity.sprite_handler.min_random_flap_time /= wing_flap_random_multipler
	entity.sprite_handler.max_random_flap_time /= wing_flap_random_multipler
